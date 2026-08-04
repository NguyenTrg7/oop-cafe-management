#include "IngredientManager.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

IngredientManager::IngredientManager(QObject *parent)
    : QObject(parent)
{
}

bool IngredientManager::loadIngredientsCSV(const QString &path, bool clearFirst)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open ingredients file:" << path;
        return false;
    }

    QTextStream in(&file);

    // Một số file có header, một số không → đọc dòng đầu để kiểm tra
    QString firstLine = in.readLine().trimmed();
    bool hasHeader = firstLine.contains("IngredientID", Qt::CaseInsensitive)
                     || firstLine.contains("ID", Qt::CaseInsensitive);

    if (!hasHeader) {
        // Quay lại đầu file nếu không có header
        file.seek(0);
        in.seek(0);
    }

    if (clearFirst)
        m_ingredients.clear();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList data = line.split(",");
        if (data.size() < 7) continue;

        QString id   = data[0].trimmed();
        QString name = data[1].trimmed();
        QString unit = data[4].trimmed();
        double qty   = data[5].toDouble();
        double minTh = data[6].toDouble();

        // Chỉ thêm nếu chưa tồn tại (tránh ghi đè)
        if (!m_ingredients.contains(id)) {
            Ingredient ing(id, name, qty, unit, minTh);
            m_ingredients.insert(id, ing);
        }
        else{
            m_ingredients[id].setQuantity(qty);
            m_ingredients[id].setMinThreshold(minTh);
        }
    }
    file.close();
    emit ingredientsChanged();
    return true;
}

bool IngredientManager::loadRecipesCSV(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open recipes file:" << path;
        return false;
    }

    QTextStream in(&file);
    in.readLine(); // skip header
    m_recipes.clear();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList data = line.split(",");
        if (data.size() < 4) continue;

        QString menuId = data[0].trimmed();
        QString size   = data[1].trimmed().toUpper();
        QString ingId  = data[2].trimmed();
        double amount  = data[3].toDouble();

        m_recipes[menuId][size].append({ingId, amount});
    }
    file.close();
    return true;
}

// F001 → ING101, F002 → ING102, ... F015 → ING115
QString IngredientManager::resolveStockId(const QString &menuId) const{
    if (menuId.isEmpty())
        return menuId;

    if (m_ingredients.contains(menuId))
        return menuId;

    if (menuId.startsWith("F", Qt::CaseInsensitive) && menuId.length() >= 2) {
        bool ok = false;
        int num = menuId.mid(1).toInt(&ok);
        if (ok && num > 0) {
            QString ingId = QString("ING%1").arg(100 + num, 3, 10, QChar('0'));
            if (m_ingredients.contains(ingId))
                return ingId;
        }
    }
    return menuId;
}

bool IngredientManager::checkAvailability(const QString &menuId,
                                          const QString &size,
                                          int quantity) const
{
    if (!m_recipes.contains(menuId)) {
        QString stockId = resolveStockId(menuId);   // F001 → ING101
        if (!m_ingredients.contains(stockId))
            return true;   // không quản lý kho → cho bán
        return m_ingredients.value(stockId).getQuantity() >= quantity;
    }

    auto sizeMap = m_recipes.value(menuId);
    QString s = size.isEmpty() ? "M" : size.toUpper();

    if (!sizeMap.contains(s)) {
        // fallback size đầu tiên
        if (sizeMap.isEmpty()) return false;
        s = sizeMap.keys().first();
    }

    const QList<RecipeItem> recipe = sizeMap.value(s); // Lấy bản sao an toàn
    for (const auto &item : recipe) {
        if (!m_ingredients.contains(item.ingredientId))
            return false;

        double needed = item.requiredAmount * quantity;
        if (m_ingredients.value(item.ingredientId).getQuantity() < needed)
            return false;
    }
    return true;
}


int IngredientManager::getMaxServings(const QString &menuId,
                                      const QString &size) const
{
    if (!m_recipes.contains(menuId)) {
        QString stockId = resolveStockId(menuId);   // F001 → ING101
        if (!m_ingredients.contains(stockId))
            return 999;
        return static_cast<int>(m_ingredients.value(stockId).getQuantity());
    }

    auto sizeMap = m_recipes.value(menuId);
    QString s = size.isEmpty() ? "M" : size.toUpper();

    if (!sizeMap.contains(s)) {
        if (sizeMap.isEmpty()) return 0;
        s = sizeMap.keys().first();
    }

    int maxServings = 999;
    const QList<RecipeItem> recipe = sizeMap.value(s); // Lấy bản sao an toàn

    for (const auto &item : recipe) {
        if (!m_ingredients.contains(item.ingredientId) || item.requiredAmount <= 0)
            return 0;

        double stock = m_ingredients.value(item.ingredientId).getQuantity();
        int possible = static_cast<int>(stock / item.requiredAmount);
        if (possible < maxServings)
            maxServings = possible;
    }
    return maxServings;
}

bool IngredientManager::deductIngredientsForOrder(const QString &menuId,
                                                  const QString &size,
                                                  int quantity)
{
    if (menuId.isEmpty() || quantity <= 0)
        return false;

    // Không có công thức → bỏ qua, không crash
    if (!m_recipes.contains(menuId)) {
        QString stockId = resolveStockId(menuId);
        if (!m_ingredients.contains(stockId)) {
            qWarning() << "Không có tồn kho cho món:" << menuId << "→ bỏ qua trừ kho";
            return true;
        }
        if (m_ingredients.value(stockId).getQuantity() < quantity) {
            qWarning() << "Không đủ tồn kho:" << menuId
                       << "cần" << quantity
                       << "còn" << m_ingredients.value(stockId).getQuantity();
            return false;
        }
        m_ingredients[stockId].consume(quantity); // Được phép dùng [] vì đây không phải hàm const và muốn chỉnh sửa map
        emit ingredientsChanged();
        autoSave();
        return true;
    }

    auto sizeMap = m_recipes.value(menuId);
    QString s = size.isEmpty() ? "M" : size.toUpper();

    if (!sizeMap.contains(s)) {
        if (sizeMap.isEmpty()) {
            qWarning() << "Recipe rỗng cho" << menuId;
            return false;
        }
        s = sizeMap.keys().first();
    }

    const QList<RecipeItem> recipe = sizeMap.value(s);
    for (const auto &item : recipe) {
        if (m_ingredients.contains(item.ingredientId)) {
            m_ingredients[item.ingredientId].consume(item.requiredAmount * quantity);
        }
    }

    emit ingredientsChanged();
    autoSave();
    return true;
}

QVariantList IngredientManager::getAllIngredients() const
{
    QVariantList list;
    for (auto it = m_ingredients.constBegin(); it != m_ingredients.constEnd(); ++it) {
        const Ingredient &ing = it.value();
        QVariantMap m;
        m["id"]           = ing.getId();
        m["name"]         = ing.getName();
        m["quantity"]     = ing.getQuantity();
        m["unit"]         = ing.getUnit();
        m["minThreshold"] = ing.getMinThreshold();
        m["isLow"]        = ing.getQuantity() < ing.getMinThreshold();
        list.append(m);
    }
    return list;
}

void IngredientManager::setQuantity(const QString &id, double quantity)
{
    if (m_ingredients.contains(id)) {
        m_ingredients[id].setQuantity(qMax(0.0, quantity));
        emit ingredientsChanged();
        autoSave();
    }
}

void IngredientManager::restock(const QString &id, double amount)
{
    if (m_ingredients.contains(id)) {
        m_ingredients[id].restock(amount);
        emit ingredientsChanged();
        autoSave();
    }
}

bool IngredientManager::saveIngredientsCSV(const QString &path) const
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << "IngredientID,IngredientName,Type,Category,Unit,Quantity,MinimumQuantity\n";

    for (auto it = m_ingredients.constBegin(); it != m_ingredients.constEnd(); ++it) {
        const Ingredient &ing = it.value();
        out << ing.getId() << ","
            << ing.getName() << ","
            << "Raw,,"                       // Type, Category tạm
            << ing.getUnit() << ","
            << ing.getQuantity() << ","
            << ing.getMinThreshold() << "\n";
    }
    file.close();
    return true;
}

bool IngredientManager::deductExtra(const QString &ingredientId, double amount) {
    if (!m_ingredients.contains(ingredientId)) return false;
    bool ok = m_ingredients[ingredientId].consume(amount);
    if (ok) {
        emit ingredientsChanged();
        autoSave();
    }
    return ok;
}

void IngredientManager::setPaths(const QString &drinkPath, const QString &foodPath)
{
    m_drinkPath = drinkPath;
    m_foodPath  = foodPath;
}

void IngredientManager::autoSave()
{
    if (!m_drinkPath.isEmpty())
        saveFiltered(m_drinkPath, "ING0");   // Drink
    if (!m_foodPath.isEmpty())
        saveFiltered(m_foodPath, "ING1");    // Food
}

bool IngredientManager::saveFiltered(const QString &path, const QString &idPrefix) const
{

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Cannot save ingredients to" << path;
        return false;
    }

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out << "IngredientID,IngredientName,Type,Category,Unit,Quantity,MinimumQuantity\n";

    for (auto it = m_ingredients.constBegin(); it != m_ingredients.constEnd(); ++it) {
        if (!it.key().startsWith(idPrefix))
            continue;

        const Ingredient &ing = it.value();
        out << ing.getId() << ","
            << ing.getName() << ","
            << "Raw,,"
            << ing.getUnit() << ","
            << ing.getQuantity() << ","
            << ing.getMinThreshold() << "\n";
    }
    file.close();
    return true;
}