#include "Customer.h"
#include <QDebug>

Customer::Customer(const QString &id, const QString &name, int points, QObject *parent)
    : User(id, name, parent)
    , m_phoneNumber("")
    , m_loyaltyPoints(points)
{
}

int Customer::loyaltyPoints() const { return m_loyaltyPoints; }

void Customer::setLoyaltyPoints(int points)
{
    if (points < 0) points = 0;
    if (m_loyaltyPoints != points) {
        m_loyaltyPoints = points;
        emit loyaltyPointsChanged();
    }
}

void Customer::setPhoneNumber(const QString &phone)
{
    if (m_phoneNumber != phone) {
        m_phoneNumber = phone;
        emit phoneNumberChanged();
    }
}

QString Customer::role() const { return QStringLiteral("Customer"); }

void Customer::displayInfo() const
{
    qDebug() << "Khach:" << m_name << "| Diem:" << m_loyaltyPoints;
}

void Customer::addPoints(int points)
{
    if (points <= 0) return;
    m_loyaltyPoints += points;
    emit loyaltyPointsChanged();
}

QVariantList Customer::voucherTiers() const
{
    QVariantList list;
    auto add = [&](int pts, int pct, const QString &label) {
        QVariantMap m;
        m["points"] = pts;
        m["percent"] = pct;
        m["label"] = label;
        list << m;
    };
    add(50,  10, QStringLiteral("Giam 10%"));
    add(100, 15, QStringLiteral("Giam 15%"));
    add(150, 20, QStringLiteral("Giam 20%"));
    add(200, 30, QStringLiteral("Giam 30%"));
    return list;
}

QVariantMap Customer::redeemVoucher(int pointsRequired)
{
    QVariantMap result;
    result["success"] = false;
    result["discountPercent"] = 0;

    int percent = 0;
    QString label;
    for (const QVariant &v : voucherTiers()) {
        QVariantMap t = v.toMap();
        if (t["points"].toInt() == pointsRequired) {
            percent = t["percent"].toInt();
            label = t["label"].toString();
            break;
        }
    }

    if (percent <= 0) {
        result["message"] = QStringLiteral("Moc diem khong hop le!");
        return result;
    }
    if (m_loyaltyPoints < pointsRequired) {
        result["message"] = QStringLiteral("Khong du diem! Can %1, co %2.")
        .arg(pointsRequired).arg(m_loyaltyPoints);
        return result;
    }

    m_loyaltyPoints -= pointsRequired;
    emit loyaltyPointsChanged();

    result["success"] = true;
    result["discountPercent"] = percent;
    result["message"] = QStringLiteral("Doi thanh cong: %1 (-%2 diem)")
                            .arg(label).arg(pointsRequired);
    return result;
}

void Customer::loadFrom(const QString &phone, const QString &name, int points)
{
    setPhoneNumber(phone);
    setName(name.isEmpty() ? phone : name);
    setLoyaltyPoints(points);
}

void Customer::resetToGuest()
{
    setPhoneNumber("");
    setName(QStringLiteral("Khach vang lai"));
    setLoyaltyPoints(0);
}