#ifndef SEATING_H
#define SEATING_H

class Seating {
private:
    int tableNumber;
    int capacity; // Số ghế ngồi
    bool isOccupied; // Trạng thái có khách hay không

public:
    Seating();
    ~Seating();

    // Gợi ý hàm thao tác
    // void occupyTable();
    // void clearTable();
};

#endif // SEATING_H