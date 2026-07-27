#include "Seating.h"

Seating::Seating()
    : tableNumber(0)
    , capacity(4)
    , isOccupied(false)
    , position("")
    , shape("Vuông")
{
}

Seating::Seating(int tableNumber, int capacity, bool isOccupied,
                 const QString& position, const QString& shape)
    : tableNumber(tableNumber)
    , capacity(capacity)
    , isOccupied(isOccupied)
    , position(position)
    , shape(shape)
{
}

// ========== GETTERS ==========
int Seating::getTableNumber() const { return tableNumber; }
int Seating::getCapacity() const { return capacity; }
bool Seating::isTableOccupied() const { return isOccupied; }
bool Seating::isAvailable() const { return !isOccupied; }
QString Seating::getPosition() const { return position; }
QString Seating::getShape() const { return shape; }

// ========== SETTERS ==========
void Seating::setTableNumber(int tableNumber) { this->tableNumber = tableNumber; }
void Seating::setCapacity(int capacity) { this->capacity = capacity; }
void Seating::setOccupied(bool occupied) { this->isOccupied = occupied; }
void Seating::setPosition(const QString& position) { this->position = position; }
void Seating::setShape(const QString& shape) { this->shape = shape; }

// ========== HÀNH ĐỘNG ==========
void Seating::occupyTable() { isOccupied = true; }
void Seating::clearTable() { isOccupied = false; }

bool Seating::canSeat(int guestCount) const
{
    return !isOccupied && (guestCount <= capacity);
}