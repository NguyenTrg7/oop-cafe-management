#include "Seating.h"

Seating::Seating()
    : tableNumber(0)
    , capacity(4)
    , isOccupied(false)
    , shape(QStringLiteral("Vuông"))
    , m_note()
{}

Seating::Seating(int tableNumber, int capacity, bool isOccupied,
                 const QString &shape, const QString &note)
    : tableNumber(tableNumber)
    , capacity(capacity)
    , isOccupied(isOccupied)
    , shape(shape)
    , m_note(note)
{}

int Seating::getTableNumber() const { return tableNumber; }
int Seating::getCapacity() const { return capacity; }
bool Seating::isTableOccupied() const { return isOccupied; }
bool Seating::isAvailable() const { return !isOccupied; }
QString Seating::getShape() const { return shape; }
QString Seating::getNote() const { return m_note; }

void Seating::setTableNumber(int n) { tableNumber = n; }
void Seating::setCapacity(int c) { capacity = c; }
void Seating::setOccupied(bool o) { isOccupied = o; }
void Seating::setShape(const QString &s) { shape = s; }
void Seating::setNote(const QString &n) { m_note = n; }

void Seating::occupyTable() { isOccupied = true; }

void Seating::clearTable()
{
    isOccupied = false;
    m_note.clear();   // Xóa ghi chú khi trả bàn
}

bool Seating::canSeat(int guestCount) const
{
    return !isOccupied && (guestCount <= capacity);
}

void Seating::setOriginalCapacities(const QList<int> &caps) { m_originalCapacities = caps; }
QList<int> Seating::getOriginalCapacities() const { return m_originalCapacities; }
void Seating::clearOriginalCapacities() { m_originalCapacities.clear(); }

void Seating::setOriginalNumbers(const QList<int> &nums) { m_originalNumbers = nums; }
QList<int> Seating::getOriginalNumbers() const { return m_originalNumbers; }
void Seating::clearOriginalNumbers() { m_originalNumbers.clear(); }

void Seating::setOriginalShapes(const QList<QString> &shapes) { m_originalShapes = shapes; }
QList<QString> Seating::getOriginalShapes() const { return m_originalShapes; }
void Seating::clearOriginalShapes() { m_originalShapes.clear(); }