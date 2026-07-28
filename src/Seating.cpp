#include "Seating.h"

Seating::Seating()
    : tableNumber(0)
    , capacity(4)
    , isOccupied(false)
    , shape("Vuông")
    , m_originalCapacities()
{
}

Seating::Seating(int tableNumber, int capacity, bool isOccupied, const QString& shape)
    : tableNumber(tableNumber)
    , capacity(capacity)
    , isOccupied(isOccupied)
    , shape(shape)
    , m_originalCapacities()
{
}

// ========== GETTERS ==========
int Seating::getTableNumber() const { return tableNumber; }
int Seating::getCapacity() const { return capacity; }
bool Seating::isTableOccupied() const { return isOccupied; }
bool Seating::isAvailable() const { return !isOccupied; }
QString Seating::getShape() const { return shape; }

// ========== SETTERS ==========
void Seating::setTableNumber(int tableNumber) { this->tableNumber = tableNumber; }
void Seating::setCapacity(int capacity) { this->capacity = capacity; }
void Seating::setOccupied(bool occupied) { this->isOccupied = occupied; }
void Seating::setShape(const QString& shape) { this->shape = shape; }

// ========== HÀNH ĐỘNG ==========
void Seating::occupyTable() { isOccupied = true; }
void Seating::clearTable() { isOccupied = false; }

bool Seating::canSeat(int guestCount) const
{
    return !isOccupied && (guestCount <= capacity);
}