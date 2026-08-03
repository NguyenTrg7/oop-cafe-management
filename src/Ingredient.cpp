#include "Ingredient.h"

Ingredient::Ingredient()
    : m_id(""), m_name(""), m_quantity(0.0), m_unit(""), m_minThreshold(0.0)
{
}

Ingredient::Ingredient(const QString &id, const QString &name, double quantity,
                       const QString &unit, double minThreshold)
    : m_id(id), m_name(name), m_quantity(quantity),
    m_unit(unit), m_minThreshold(minThreshold)
{
}

bool Ingredient::consume(double amount)
{
    if (m_quantity >= amount) {
        m_quantity -= amount;
        return true;
    }
    return false;
}

void Ingredient::restock(double amount)
{
    m_quantity += amount;
}