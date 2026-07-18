#ifndef CUSTOMER_H
#define CUSTOMER_H

#include "User.h"

class Customer : public User {
    Q_OBJECT
    Q_PROPERTY(int loyaltyPoints READ loyaltyPoints WRITE setLoyaltyPoints NOTIFY loyaltyPointsChanged)
    Q_PROPERTY(QString phoneNumber READ phoneNumber CONSTANT)
    Q_PROPERTY(QString rank READ rank NOTIFY rankChanged)
public:
    explicit Customer(const QString& id, const QString& name, int points = 0, QObject *parent = nullptr);

    int loyaltyPoints() const;
    void setLoyaltyPoints(int points);

    QString role() const override;
    void displayInfo() const override;
    void updateProfile(const QString& newName, const QString& newPhone);
    void addPoints(int points);
    void redeemPoints(int pointsToRedeem);


signals:
    void loyaltyPointsChanged();

private:
    QString m_phoneNumber; //[cite: 2]
    QString m_rank;        //[cite: 2]
    int m_loyaltyPoints;
};

#endif // CUSTOMER_H

