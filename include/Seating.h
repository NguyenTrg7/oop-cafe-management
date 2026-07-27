#ifndef SEATING_H
#define SEATING_H

#include <QString>

class Seating
{
private:
    int tableNumber;        // Số bàn
    int capacity;           // Số ghế
    bool isOccupied;        // Đang có khách hay không
    QString position;       // Vị trí (ví dụ: "Khu A", "Gần cửa sổ")
    QString shape;          // "Tròn" hoặc "Vuông"

public:
    Seating();
    Seating(int tableNumber, int capacity, bool isOccupied = false,
            const QString& position = "", const QString& shape = "Vuông");

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
};

#endif // SEATING_H