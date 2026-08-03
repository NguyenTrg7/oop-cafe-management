#include "Customer.h"
#include <QDebug>
#include <QRandomGenerator>
#include <QFile>
#include <QTextStream>
#include <QMap>
#include <QCoreApplication>

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
             << "| SĐT:" << m_phoneNumber
             << "| Điểm:" << m_loyaltyPoints
             << "| Voucher:" << m_vouchers.size();
}

void Customer::addPoints(int points)
{
    if (points <= 0)
        return;
    m_loyaltyPoints += points;
    emit loyaltyPointsChanged();
    qDebug() << "[Loyalty] +" << points << " -> Tổng:" << m_loyaltyPoints << "| SĐT:" << m_phoneNumber;
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
        result["message"] = QStringLiteral("Mốc điểm không hợp lệ!");
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
             << "| Còn điểm:" << m_loyaltyPoints;
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
    // Ưu tiên load từ file theo số điện thoại
    if (!phone.trimmed().isEmpty()) {
        loadByPhone(phone);
    } else {
        setPhoneNumber(QString());
        setName(name.isEmpty() ? QStringLiteral("Khách vãng lai") : name);
        setLoyaltyPoints(points);
        m_vouchers.clear();
        emit vouchersChanged();
    }
}

void Customer::resetToGuest()
{
    setPhoneNumber(QString());
    setName(QStringLiteral("Khách vãng lai"));
    setLoyaltyPoints(0);
    m_vouchers.clear();
    emit vouchersChanged();
}

// ====================== LOYALTY CSV ======================

static QString loyaltyFilePath()
{
    return QCoreApplication::applicationDirPath() + "/data/loyalty.csv";
}

bool Customer::loadByPhone(const QString &phone)
{
    QString cleanPhone = phone.trimmed();
    if (cleanPhone.isEmpty()) {
        resetToGuest();
        return false;
    }

    QFile file(loyaltyFilePath());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        // File chưa tồn tại → tạo khách mới
        setPhoneNumber(cleanPhone);
        setName(cleanPhone);
        setLoyaltyPoints(0);
        m_vouchers.clear();
        emit vouchersChanged();
        return true;
    }

    QTextStream in(&file);
    QString firstLine = in.readLine();
    bool hasHeader = firstLine.startsWith("phone");

    if (!hasHeader) {
        // Quay lại đầu file nếu không có header
        file.seek(0);
        in.seek(0);
    }

    bool found = false;
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList parts = line.split(",");
        if (parts.size() < 2) continue;

        QString csvPhone = parts[0].trimmed();
        if (csvPhone == cleanPhone) {
            int points = parts[1].toInt();
            QString vouchersStr = (parts.size() >= 3) ? parts[2] : "";

            setPhoneNumber(cleanPhone);
            setName(cleanPhone);
            setLoyaltyPoints(points);
            vouchersFromString(vouchersStr);
            found = true;
            break;
        }
    }
    file.close();

    if (!found) {
        // Chưa có trong file → khách mới
        setPhoneNumber(cleanPhone);
        setName(cleanPhone);
        setLoyaltyPoints(0);
        m_vouchers.clear();
        emit vouchersChanged();
    }

    return true;
}

bool Customer::save()
{
    QString cleanPhone = m_phoneNumber.trimmed();
    if (cleanPhone.isEmpty())
        return false;

    QString path = loyaltyFilePath();
    QFile file(path);

    // Đọc toàn bộ dữ liệu hiện có
    QMap<QString, QString> allData; // phone → "points,vouchers"

    if (file.exists() && file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString firstLine = in.readLine();
        bool hasHeader = firstLine.startsWith("phone");

        if (!hasHeader && !firstLine.trimmed().isEmpty()) {
            QStringList parts = firstLine.split(",");
            if (parts.size() >= 2)
                allData[parts[0].trimmed()] = parts.mid(1).join(",");
        }

        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty()) continue;
            QStringList parts = line.split(",");
            if (parts.size() >= 2)
                allData[parts[0].trimmed()] = parts.mid(1).join(",");
        }
        file.close();
    }

    // Cập nhật hoặc thêm khách hiện tại
    QString vouchersStr = vouchersToString();
    allData[cleanPhone] = QString("%1,%2").arg(m_loyaltyPoints).arg(vouchersStr);

    // Ghi lại toàn bộ file
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        qWarning() << "Không thể mở file loyalty.csv để ghi";
        return false;
    }

    QTextStream out(&file);
    out << "phone,points,vouchers\n";

    for (auto it = allData.constBegin(); it != allData.constEnd(); ++it) {
        out << it.key() << "," << it.value() << "\n";
    }
    file.close();

    qDebug() << "[Loyalty] Đã lưu SĐT:" << cleanPhone << "| Điểm:" << m_loyaltyPoints;
    return true;
}