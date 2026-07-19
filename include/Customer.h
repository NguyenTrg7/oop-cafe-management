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
    QString phoneNumber() const { return m_phoneNumber; }
    QString rank() const { return m_rank; }


signals:
    void loyaltyPointsChanged();
    void phoneNumberChanged();
    void rankChanged();

private:
    QString m_phoneNumber; //[cite: 2]
    QString m_rank;        //[cite: 2]
    int m_loyaltyPoints;
};

#endif // CUSTOMER_H

