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
    QString shape; // "Vuong" | "Tron"
    QList<int> m_originalCapacities;

public:
    Seating();
    Seating(int tableNumber, int capacity, bool isOccupied = false,
            const QString &shape = QStringLiteral("Vuong"));
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
};

#endif // SEATING_H