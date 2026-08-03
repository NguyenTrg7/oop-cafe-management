// Seating.h (thay thế toàn bộ)
#ifndef SEATING_H
#define SEATING_H

#include <QString>
#include <QList>

class Seating
{
private:
    int tableNumber;
    int capacity;
    bool isOccupied;
    QString shape; // "Vuông" | "Tròn"
    QList<int> m_originalCapacities;
    QList<int> m_originalNumbers;   // <-- THÊM MỚI: lưu số bàn gốc
    QList<QString> m_originalShapes; // <-- THÊM MỚI

public:
    Seating();
    Seating(int tableNumber, int capacity, bool isOccupied = false,
            const QString &shape = QStringLiteral("Vuông"));
    ~Seating() = default;

    int getTableNumber() const;
    int getCapacity() const;
    bool isTableOccupied() const;
    bool isAvailable() const;
    QString getShape() const;

    void setTableNumber(int tableNumber);
    void setCapacity(int capacity);
    void setOccupied(bool occupied);
    void setShape(const QString &shape);

    void occupyTable();
    void clearTable();
    bool canSeat(int guestCount) const;

    void setOriginalCapacities(const QList<int> &caps);
    QList<int> getOriginalCapacities() const;
    void clearOriginalCapacities();

    // === MỚI ===
    void setOriginalNumbers(const QList<int> &nums);
    QList<int> getOriginalNumbers() const;
    void clearOriginalNumbers();

    void setOriginalShapes(const QList<QString> &shapes);
    QList<QString> getOriginalShapes() const;
    void clearOriginalShapes();
};

#endif // SEATING_H