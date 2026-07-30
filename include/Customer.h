#ifndef CUSTOMER_H
#define CUSTOMER_H

#include "User.h"
#include <QVariantList>
#include <QVariantMap>

class Customer : public User {
    Q_OBJECT
    Q_PROPERTY(int loyaltyPoints READ loyaltyPoints WRITE setLoyaltyPoints NOTIFY loyaltyPointsChanged)
    Q_PROPERTY(QString phoneNumber READ phoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged)

public:
    explicit Customer(const QString &id = QStringLiteral("GUEST"),
                      const QString &name = QStringLiteral("Khach vang lai"),
                      int points = 0,
                      QObject *parent = nullptr);

    int loyaltyPoints() const;
    void setLoyaltyPoints(int points);

    QString role() const override;
    void displayInfo() const override;

    Q_INVOKABLE void addPoints(int points);
    Q_INVOKABLE QVariantMap redeemVoucher(int pointsRequired);
    Q_INVOKABLE QVariantList voucherTiers() const;

    QString phoneNumber() const { return m_phoneNumber; }
    void setPhoneNumber(const QString &phone);

    Q_INVOKABLE void loadFrom(const QString &phone, const QString &name, int points);
    Q_INVOKABLE void resetToGuest();

signals:
    void loyaltyPointsChanged();
    void phoneNumberChanged();

private:
    QString m_phoneNumber;
    int m_loyaltyPoints;
};

#endif // CUSTOMER_H