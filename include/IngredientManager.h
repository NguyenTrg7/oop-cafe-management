#ifndef INGREDIENTMANAGER_H
#define INGREDIENTMANAGER_H

#include <QObject>
#include <QMap>
#include <QList>
#include <QVariantList>
#include <QString>
#include "Ingredient.h"

struct RecipeItem {
    QString ingredientId;
    double  requiredAmount;
};

// menuId → (size → list RecipeItem)
using SizeRecipeMap = QMap<QString, QList<RecipeItem>>;

class IngredientManager : public QObject
{
    Q_OBJECT

private:
    QMap<QString, Ingredient>   m_ingredients;
    QMap<QString, SizeRecipeMap> m_recipes;    // menuId → size → ingredients

    QString m_drinkPath;
    QString m_foodPath;
    QString resolveStockId(const QString &menuId) const;
    void autoSave();
public:
    explicit IngredientManager(QObject *parent = nullptr);

    // Load data
    Q_INVOKABLE bool loadIngredientsCSV(const QString &path, bool clearFirst);
    Q_INVOKABLE bool loadRecipesCSV(const QString &path);

    // Kiểm tra & tính toán
    Q_INVOKABLE bool checkAvailability(const QString &menuId,
                                       const QString &size,
                                       int quantity) const;

    Q_INVOKABLE int getMaxServings(const QString &menuId,
                                   const QString &size) const;

    // Trừ kho khi bán
    Q_INVOKABLE bool deductIngredientsForOrder(const QString &menuId,
                                               const QString &size,
                                               int quantity);

    // Dành cho InventoryPage
    Q_INVOKABLE QVariantList getAllIngredients() const;
    Q_INVOKABLE void setQuantity(const QString &id, double quantity);
    Q_INVOKABLE void restock(const QString &id, double amount);

    // Lưu tồn kho ra file (tuỳ chọn)
    Q_INVOKABLE bool saveIngredientsCSV(const QString &path) const;
    Q_INVOKABLE bool deductExtra(const QString &ingredientId, double amount);
    void setPaths(const QString &drinkPath, const QString &foodPath);
    Q_INVOKABLE bool saveFiltered(const QString &path, const QString &idPrefix) const;

signals:
    void ingredientsChanged();   // QML lắng nghe để refresh menu

};

#endif // INGREDIENTMANAGER_H