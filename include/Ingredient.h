#ifndef INGREDIENT_H
#define INGREDIENT_H

#include <QString>

class Ingredient
{
private:
    QString m_id;
    QString m_name;
    double  m_quantity;
    QString m_unit;
    double  m_minThreshold;

public:
    Ingredient();
    Ingredient(const QString &id, const QString &name, double quantity,
               const QString &unit, double minThreshold);

    QString getId() const { return m_id; }
    QString getName() const { return m_name; }
    double getQuantity() const { return m_quantity; }
    QString getUnit() const { return m_unit; }
    double getMinThreshold() const { return m_minThreshold; }

    void setQuantity(double qty) { m_quantity = qty; }
    void setName(const QString &name) { m_name = name; }
    void setUnit(const QString &unit) { m_unit = unit; }
    void setMinThreshold(double th) { m_minThreshold = th; }

    bool consume(double amount);
    void restock(double amount);

};

#endif // INGREDIENT_H