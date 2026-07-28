#ifndef SEATING_H
#define SEATING_H

#include <QString>
#include <QList>

class Seating
{
private:
    int tableNumber;        // Số bàn
    int capacity;           // Số ghế
    bool isOccupied;        // Đang có khách hay không
    QString shape;          // "Tròn" hoặc "Vuông"
    QList<int> m_originalCapacities; // Lưu sức chứa gốc khi gộp bàn (để tách đúng số ghế)

public:
    Seating();
    Seating(int tableNumber, int capacity, bool isOccupied = false, const QString& shape = "Vuông");

    ~Seating() = default;

    // Getters
    int getTableNumber() const;
    int getCapacity() const;
    bool isTableOccupied() const;
    bool isAvailable() const;
    QString getPosition() const;
    QString getShape() const;

    // Setters
    void setTableNumber(int tableNumber);
    void setCapacity(int capacity);
    void setOccupied(bool occupied);
    void setPosition(const QString& position);
    void setShape(const QString& shape);

    // Hành động
    void occupyTable();
    void clearTable();
    bool canSeat(int guestCount) const;

    void setOriginalCapacities(const QList<int>& caps) { m_originalCapacities = caps; }
    QList<int> getOriginalCapacities() const { return m_originalCapacities; }
    void clearOriginalCapacities() { m_originalCapacities.clear(); }
};

#endif // SEATING_H