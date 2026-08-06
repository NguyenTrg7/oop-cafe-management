#include "MenuManager.h"
#include "IngredientManager.h"
#include <QDebug>
#include <QString>

MenuManager::MenuManager(QObject *parent)
    : QObject(parent)
{}

bool MenuManager::loadDrinksCSV(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QTextStream in(&file);
    in.readLine();
    m_drinks.clear();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty())
            continue;

        QStringList data = line.split(",");

        if (data.size() < 6)
            continue;

        Menu drink(data[0].trimmed(),
                   data[1].trimmed(),
                   data[2].trimmed(),
                   data[3].trimmed().toDouble(),
                   data[4].trimmed().split("|"),
                   data[5].trimmed());
        m_drinks.append(drink);
    }
    file.close();
    return true;
}

bool MenuManager::loadFoodsCSV(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QTextStream in(&file);
    in.readLine();
    m_foods.clear();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty())
            continue;

        QStringList data = line.split(",");
        if (data.size() < 5)
            continue;

        Menu food(data[0].trimmed(),
                  data[1].trimmed(),
                  data[2].trimmed(),
                  data[3].trimmed().toDouble(),
                  QStringList({"Standard"}),
                  data[4].trimmed());
        m_foods.append(food);
    }
    file.close();
    return true;
}

QList<Menu> MenuManager::getDrinks() const
{
    return m_drinks;
}

QList<Menu> MenuManager::getFoods() const
{
    return m_foods;
}

bool MenuManager::addDrink(const Menu &drink)
{
    for (const Menu &item : m_drinks) {
        if (item.getId() == drink.getId())
            return false;
    }

    m_drinks.append(drink);
    return true;
}

bool MenuManager::addFood(const Menu &food)
{
    for (const Menu &item : m_foods) {
        if (item.getId() == food.getId())
            return false;
    }
    m_foods.append(food);
    return true;
}

Menu MenuManager::searchDrink(const QString &id) const
{
    for (const Menu &item : m_drinks) {
        if (item.getId() == id)
            return item;
    }
    return Menu();
}

Menu MenuManager::searchFood(const QString &id) const
{
    for (const Menu &item : m_foods)
        if (item.getId() == id)
            return item;
    return Menu();
}

bool MenuManager::updateDrinkStatus(const QString &id, const QString &status)
{
    for (Menu &item : m_drinks) {
        if (item.getId() == id) {
            item.setStatus(status);
            return true;
        }
    }
    return false;
}

bool MenuManager::updateFoodStatus(const QString &id, const QString &status)
{
    for (Menu &item : m_foods) {
        if (item.getId() == id) {
            item.setStatus(status);
            return true;
        }
    }
    return false;
}

QList<Menu> MenuManager::getDrinkByCategory(const QString &category) const
{
    QList<Menu> result;

    for (const Menu &item : m_drinks) {
        if (item.getCategory() == category && item.getStatus() == "Available")
            result.append(item);
    }
    return result;
}

QList<Menu> MenuManager::getFoodByCategory(const QString &category) const
{
    QList<Menu> result;

    for (const Menu &item : m_foods) {
        if (item.getCategory() == category && item.getStatus() == "Available")
            result.append(item);
    }
    return result;
}

bool MenuManager::saveDrinksCSV(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;

    QTextStream out(&file);

    out << "ID, Name, Category, BasePrice, Sizes, Status\n";

    for (const Menu &item : m_drinks) {
        out << item.getId() << "," << item.getName() << "," << item.getCategory() << ","
            << item.getPrice() << "," << item.getSizes().join("|") << "," << item.getStatus()
            << "\n";
    }
    file.close();
    return true;
}

bool MenuManager::saveFoodsCSV(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;

    QTextStream out(&file);

    out << "ID, Name, Category, BasePrice, Status\n";

    // Đã dùng m_foods (Sửa lỗi dùng nhầm m_drinks ở Source 6)
    for (const Menu &item : m_foods) {
        out << item.getId() << "," << item.getName() << "," << item.getCategory() << ","
            << item.getPrice() << "," << item.getStatus() << "\n";
    }
    file.close();
    return true;
}

void MenuManager::setIngredientManager(IngredientManager *manager)
{
    m_ingredientManager = manager;
}

QVariantList MenuManager::getMenuByCategory(const QString &type) const
{
    QVariantList list;
    const QList<Menu> &targetList = (type == "Drink") ? m_drinks : m_foods;

    for (const Menu &item : targetList) {
        QVariantMap map;
        map["id"]       = item.getId();
        map["name"]     = item.getName();
        map["category"] = item.getCategory();
        map["price"]    = item.getPrice();
        map["sizes"]    = item.getSizes();
        map["status"]   = item.getStatus();

        int maxStock = 999;
        bool isAvailable = (item.getStatus() == "Available");

        // Liên kết dữ liệu tồn kho từ IngredientManager (Lấy từ Source 5)
        if (m_ingredientManager) {
            QString defaultSize = item.getSizes().isEmpty() ? "M" : item.getSizes().first();
            maxStock = m_ingredientManager->getMaxServings(item.getId(), defaultSize);
            isAvailable = (maxStock > 0) && (item.getStatus() == "Available");
        }

        map["maxStock"]    = maxStock;
        map["isAvailable"] = isAvailable;
        list.append(map);
    }
    return list;
}