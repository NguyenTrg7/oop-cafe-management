#include "Customer.h"
#include <QDebug>
#include <QRandomGenerator>

Customer::Customer(const QString &id, const QString &name, int points, QObject *parent)
    : User(id, name, parent)
    , m_phoneNumber("")
    , m_loyaltyPoints(points)
{
}

int Customer::loyaltyPoints() const
{
    return m_loyaltyPoints;
}

void Customer::setLoyaltyPoints(int points)
{
    if (points < 0)
        points = 0;
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

QString Customer::role() const
{
    return QStringLiteral("Customer");
}

void Customer::displayInfo() const
{
    qDebug() << "Khách:" << m_name
             << "| Điểm:" << m_loyaltyPoints
             << "| Voucher:" << m_vouchers.size();
}

void Customer::addPoints(int points)
{
    if (points <= 0)
        return;
    m_loyaltyPoints += points;
    emit loyaltyPointsChanged();
    qDebug() << "[Loyalty] +" << points << " -> Tổng:" << m_loyaltyPoints;
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
    add(50,  10, QStringLiteral("Giảm 10%"));
    add(100, 15, QStringLiteral("Giảm 15%"));
    add(150, 20, QStringLiteral("Giảm 20%"));
    add(200, 30, QStringLiteral("Giảm 30%"));
    return list;
}

QString Customer::generateVoucherCode() const
{
    const QString chars = QStringLiteral("ABCDEFGHJKLMNPQRSTUVWXYZ23456789");
    QString code = QStringLiteral("VC-");
    for (int i = 0; i < 6; ++i) {
        const int idx = QRandomGenerator::global()->bounded(chars.size());
        code += chars.at(idx);
    }
    return code;
}

QVariantMap Customer::redeemVoucher(int pointsRequired)
{
    QVariantMap result;
    result["success"] = false;
    result["discountPercent"] = 0;
    result["code"] = QString();

    int percent = 0;
    QString label;
    for (const QVariant &v : voucherTiers()) {
        const QVariantMap t = v.toMap();
        if (t["points"].toInt() == pointsRequired) {
            percent = t["percent"].toInt();
            label = t["label"].toString();
            break;
        }
    }

    if (percent <= 0) {
        result["message"] = QStringLiteral("Móc điểm không hợp lệ!");
        return result;
    }

    if (m_loyaltyPoints < pointsRequired) {
        result["message"] = QStringLiteral("Không đủ điểm! Cần %1, Có %2.")
        .arg(pointsRequired)
            .arg(m_loyaltyPoints);
        return result;
    }

    m_loyaltyPoints -= pointsRequired;

    Voucher vc;
    vc.code = generateVoucherCode();
    vc.percent = percent;
    vc.pointsSpent = pointsRequired;
    vc.used = false;
    m_vouchers.append(vc);

    emit loyaltyPointsChanged();
    emit vouchersChanged();

    result["success"] = true;
    result["discountPercent"] = percent;
    result["code"] = vc.code;
    result["message"] = QStringLiteral("Nhận voucher %1 (%2%) - Mã: %3")
                            .arg(label)
                            .arg(percent)
                            .arg(vc.code);

    qDebug() << "[Loyalty]" << result["message"].toString()
             << "| Còn điểm::" << m_loyaltyPoints;
    return result;
}

QVariantList Customer::activeVouchers() const
{
    QVariantList list;
    for (const Voucher &v : m_vouchers) {
        if (v.used)
            continue;
        QVariantMap m;
        m["code"] = v.code;
        m["percent"] = v.percent;
        m["pointsSpent"] = v.pointsSpent;
        m["label"] = QStringLiteral("Giảm %1%").arg(v.percent);
        list << m;
    }
    return list;
}

double Customer::applyVoucher(const QString &code, double totalAmount)
{
    if (code.isEmpty() || totalAmount <= 0)
        return 0.0;

    for (const Voucher &v : m_vouchers) {
        if (!v.used && v.code == code)
            return totalAmount * (static_cast<double>(v.percent) / 100.0);
    }
    return 0.0;
}

bool Customer::useVoucher(const QString &code)
{
    for (Voucher &v : m_vouchers) {
        if (!v.used && v.code == code) {
            v.used = true;
            emit vouchersChanged();
            qDebug() << "[Loyalty] Đã dùng voucher" << code;
            return true;
        }
    }
    return false;
}

void Customer::setVouchers(const QList<Voucher> &list)
{
    m_vouchers = list;
    emit vouchersChanged();
}

QString Customer::vouchersToString() const
{
    QStringList parts;
    for (const Voucher &v : m_vouchers) {
        parts << QStringLiteral("%1:%2:%3:%4")
        .arg(v.code)
            .arg(v.percent)
            .arg(v.pointsSpent)
            .arg(v.used ? 1 : 0);
    }
    return parts.join(QLatin1Char('|'));
}

void Customer::vouchersFromString(const QString &s)
{
    m_vouchers.clear();
    if (s.trimmed().isEmpty()) {
        emit vouchersChanged();
        return;
    }

    const QStringList parts = s.split(QLatin1Char('|'), Qt::SkipEmptyParts);
    for (const QString &p : parts) {
        const QStringList f = p.split(QLatin1Char(':'));
        if (f.size() < 4)
            continue;
        Voucher v;
        v.code = f[0];
        v.percent = f[1].toInt();
        v.pointsSpent = f[2].toInt();
        v.used = (f[3].toInt() != 0);
        m_vouchers.append(v);
    }
    emit vouchersChanged();
}

void Customer::loadFrom(const QString &phone, const QString &name, int points)
{
    setPhoneNumber(phone);
    setName(name.isEmpty() ? phone : name);
    setLoyaltyPoints(points);
}

void Customer::resetToGuest()
{
    setPhoneNumber(QString());
    setName(QStringLiteral("Khách vãng lai"));
    setLoyaltyPoints(0);
    m_vouchers.clear();
    emit vouchersChanged();
}