#include "Seating.h"

Seating::Seating()
    : tableNumber(0)
    , capacity(4)
    , isOccupied(false)
    , shape(QStringLiteral("Vuong"))
    , m_originalCapacities()
{}

Seating::Seating(int tableNumber, int capacity, bool isOccupied, const QString &shape)
    : tableNumber(tableNumber)
    , capacity(capacity)
    , isOccupied(isOccupied)
    , shape(shape)
    , m_originalCapacities()
{}

int Seating::getTableNumber() const
{
    return tableNumber;
}
int Seating::getCapacity() const
{
    return capacity;
}
bool Seating::isTableOccupied() const
{
    return isOccupied;
}
bool Seating::isAvailable() const
{
    return !isOccupied;
}
QString Seating::getShape() const
{
    return shape;
}

void Seating::setTableNumber(int n)
{
    tableNumber = n;
}
void Seating::setCapacity(int c)
{
    capacity = c;
}
void Seating::setOccupied(bool o)
{
    isOccupied = o;
}
void Seating::setShape(const QString &s)
{
    shape = s;
}

void Seating::occupyTable()
{
    isOccupied = true;
}
void Seating::clearTable()
{
    isOccupied = false;
}

bool Seating::canSeat(int guestCount) const
{
    return !isOccupied && (guestCount <= capacity);
}

void Seating::setOriginalCapacities(const QList<int> &caps)
{
    m_originalCapacities = caps;
}

QList<int> Seating::getOriginalCapacities() const
{
    return m_originalCapacities;
}

void Seating::clearOriginalCapacities()
{
    m_originalCapacities.clear();
}