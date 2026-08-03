#ifndef MENUMANAGER_H
#define MENUMANAGER_H

#include <QObject>
#include <QList>
#include <QString>
#include <QFile>
#include <QTextStream>
#include <QVariantList>
#include <QVariantMap>

#include "Menu.h"

class MenuManager : public QObject{
    Q_OBJECT;
private:
    QList<Menu> m_drinks;
    QList<Menu> m_foods;
public:
    explicit MenuManager(QObject *parent = nullptr);

    Q_INVOKABLE bool loadDrinksCSV(const QString &path);
    Q_INVOKABLE bool loadFoodsCSV(const QString &path);

    Q_INVOKABLE bool saveDrinksCSV(const QString &path);
    Q_INVOKABLE bool saveFoodsCSV(const QString &path);

    QList<Menu> getDrinks() const;
    QList<Menu> getFoods() const;

    bool addDrink(const Menu &drink);
    bool addFood(const Menu &food);

    Menu searchDrink(const QString &id) const;
    Menu searchFood(const QString &id) const;

    bool updateDrinkStatus(const QString &id,const QString &status);
    bool updateFoodStatus(const QString &id,const QString &status);

    QList<Menu> getDrinkByCategory(const QString &category) const;
    QList<Menu> getFoodByCategory(const QString &category) const;

    Q_INVOKABLE QVariantList getMenuByCategory(const QString &type) const;
};


#endif // MENUMANAGER_H
