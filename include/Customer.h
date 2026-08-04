#ifndef CUSTOMER_H
#define CUSTOMER_H

#include "User.h"
#include <QVariantList>
#include <QVariantMap>
#include <QList>

struct Voucher {
    QString code;      // VD: VC-A1B2C3
    int percent;       // 10, 15, 20, 30
    int pointsSpent;
    bool used;
};

class Customer : public User {
    Q_OBJECT
    Q_PROPERTY(int loyaltyPoints READ loyaltyPoints WRITE setLoyaltyPoints NOTIFY loyaltyPointsChanged)
    Q_PROPERTY(QString phoneNumber READ phoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged)
    Q_PROPERTY(QVariantList activeVouchers READ activeVouchers NOTIFY vouchersChanged)

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

    // Voucher dang co (chua dung)
    QVariantList activeVouchers() const;

    // Ap dung voucher: tra ve so tien giam. totalAmount = tong don
    Q_INVOKABLE double applyVoucher(const QString &code, double totalAmount);

    // Danh dau da dung (goi sau khi thanh toan xong)
    Q_INVOKABLE bool useVoucher(const QString &code);

    QString phoneNumber() const { return m_phoneNumber; }
    void setPhoneNumber(const QString &phone);

    Q_INVOKABLE void loadFrom(const QString &phone, const QString &name, int points);
    Q_INVOKABLE void resetToGuest();

    // Load/save voucher cung customers (Account se goi)
    QList<Voucher> vouchers() const { return m_vouchers; }
    void setVouchers(const QList<Voucher> &list);
    QString vouchersToString() const;          // luu CSV
    void vouchersFromString(const QString &s); // doc CSV

    // Doc sdt
    Q_INVOKABLE bool loadByPhone(const QString &phone);
    Q_INVOKABLE bool save();

signals:
    void loyaltyPointsChanged();
    void phoneNumberChanged();
    void vouchersChanged();

private:
    QString generateVoucherCode() const;

    QString m_phoneNumber;
    int m_loyaltyPoints;
    QList<Voucher> m_vouchers;
};

#endif // CUSTOMER_H