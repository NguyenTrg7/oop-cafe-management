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
    QString shape;
    QString m_note;   // <-- Ghi chú khách đặt bàn
    QList<int> m_originalCapacities;
    QList<int> m_originalNumbers;
    QList<QString> m_originalShapes;

public:
    Seating();
    Seating(int tableNumber, int capacity, bool isOccupied = false,
            const QString &shape = QStringLiteral("Vuông"),
            const QString &note = QString());
    ~Seating() = default;

    int getTableNumber() const;
    int getCapacity() const;
    bool isTableOccupied() const;
    bool isAvailable() const;
    QString getShape() const;
    QString getNote() const;

    void setTableNumber(int tableNumber);
    void setCapacity(int capacity);
    void setOccupied(bool occupied);
    void setShape(const QString &shape);
    void setNote(const QString &note);

    void occupyTable();
    void clearTable();
    bool canSeat(int guestCount) const;

    void setOriginalCapacities(const QList<int> &caps);
    QList<int> getOriginalCapacities() const;
    void clearOriginalCapacities();

    void setOriginalNumbers(const QList<int> &nums);
    QList<int> getOriginalNumbers() const;
    void clearOriginalNumbers();

    void setOriginalShapes(const QList<QString> &shapes);
    QList<QString> getOriginalShapes() const;
    void clearOriginalShapes();
};

#endif // SEATING_H