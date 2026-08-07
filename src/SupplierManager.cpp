#include "SupplierManager.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QFileInfo>
#include <QUrl>
#include <QDebug>
#include <utility>

#ifndef SAVE_DIR_PATH
#define SAVE_DIR_PATH "./saves"
#endif

SupplierManager::SupplierManager(QObject *parent)
    : QAbstractListModel(parent)
{
    loadFromCSV();
}

QString SupplierManager::getFilePath() const {
    return QString(SAVE_DIR_PATH) + "/Supplier.csv";
}

QString SupplierManager::getSavePath() const {
    return getFilePath();
}

int SupplierManager::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_suppliers.size();
}

QVariant SupplierManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_suppliers.size())
        return QVariant();

    const auto &supplier = m_suppliers[index.row()];

    switch (role) {
    case IdRole:
        return supplier.getID();
    case NameRole:
        return supplier.getName();
    case ContactPersonRole:
        return supplier.getContactPerson();
    case PhoneRole:
        return supplier.getPhone();
    case EmailRole:
        return supplier.getEmail();
    case AddressRole:
        return supplier.getAddress();
    case ItemsSuppliedRole:
        return supplier.getItemsSupplied();
    case StatusRole:
        return supplier.getStatus();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> SupplierManager::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[ContactPersonRole] = "contactPerson";
    roles[PhoneRole] = "phone";
    roles[EmailRole] = "email";
    roles[AddressRole] = "address";
    roles[ItemsSuppliedRole] = "itemsSupplied";
    roles[StatusRole] = "status";
    return roles;
}

QStringList SupplierManager::parseCsvLine(const QString &line) {
    QStringList result;
    QString currentField;
    bool inQuotes = false;

    for (int i = 0; i < line.length(); ++i) {
        QChar c = line.at(i);
        if (c == '"') {
            if (inQuotes && i + 1 < line.length() && line.at(i + 1) == '"') {
                currentField += '"';
                i++;
            } else {
                inQuotes = !inQuotes;
            }
        } else if (c == ',' && !inQuotes) {
            result.append(currentField.trimmed());
            currentField.clear();
        } else {
            currentField += c;
        }
    }
    result.append(currentField.trimmed());
    return result;
}

QString SupplierManager::escapeCsvField(const QString &field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
        QString escaped = field;
        escaped.replace('"', "\"\"");
        return "\"" + escaped + "\"";
    }
    return field;
}

void SupplierManager::loadFromCSV() {
    beginResetModel();
    m_suppliers.clear();

    QString path = getFilePath();
    QFile file(path);

    if (!file.exists()) {
        m_suppliers.append(Supplier("SUP001", "Công ty Cà phê Nguyên Chất Trường Quyền", "Nguyễn Văn An", "0901234567", "beans@truongquyen.vn", "Quận 7 - TP.HCM", "Cà phê hạt / Cà phê bột", "Hoạt động"));
        m_suppliers.append(Supplier("SUP002", "Công ty Trà Bảo Lộc", "Trần Thị Mai", "0902234567", "tea@traviet.vn", "Tân Bình - TP.HCM", "Trà xanh / Trà đen / Trà Oolong", "Hoạt động"));
        m_suppliers.append(Supplier("SUP003", "Công ty Monin Việt Nam", "Lê Hoàng Phúc", "0903234567", "monin@monin.vn", "Quận 1 - TP.HCM", "Siro / Sauce / Mứt trái cây", "Hoạt động"));
        m_suppliers.append(Supplier("SUP004", "Công ty Sữa Vinamilk", "Phạm Minh Tuấn", "0904234567", "contact@vinamilk.com.vn", "TP.HCM", "Sữa tươi / Sữa đặc / Kem béo", "Hoạt động"));
        m_suppliers.append(Supplier("SUP005", "Nông trại Trái cây Long An", "Nguyễn Văn Bình", "0905234567", "fruit@longanfarm.vn", "Long An", "Trái cây tươi / Chanh / Tắc", "Hoạt động"));
        m_suppliers.append(Supplier("SUP006", "Công ty Nguyên liệu Pha Chế Việt", "Đặng Quốc Khánh", "0906234567", "info@phacheviet.vn", "Gò Vấp - TP.HCM", "Bột Matcha / Cacao / Trân châu", "Hoạt động"));
        m_suppliers.append(Supplier("SUP007", "Công ty ABC Bakery", "Trần Hoài Nam", "0907234567", "sales@abcbakery.vn", "Bình Thạnh - TP.HCM", "Bánh ngọt / Bánh mì", "Hoạt động"));
        saveToCSV();
        endResetModel();
        return;
    }

    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        in.setCodec("UTF-8");
#endif
        bool isHeader = true;
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty()) continue;
            if (isHeader) {
                isHeader = false;
                continue;
            }

            QStringList parts = parseCsvLine(line);
            Supplier s;
            if (parts.size() >= 8) {
                s.setID(parts[0]);
                s.setName(parts[1]);
                s.setContactPerson(parts[2]);
                s.setPhone(parts[3]);
                s.setEmail(parts[4]);
                s.setAddress(parts[5]);
                s.setItemsSupplied(parts[6]);
                s.setStatus(parts[7]);
            } else if (parts.size() == 7) {
                s.setID(parts[0]);
                s.setName(parts[1]);
                s.setContactPerson(parts[2]);
                s.setPhone(parts[3]);
                s.setEmail(parts[4]);
                s.setAddress(parts[5]);
                QString p6 = parts[6];
                if (p6 == "Hoạt động" || p6 == "Tạm dừng" || p6 == "Ngừng hoạt động") {
                    s.setItemsSupplied("Chưa cập nhật");
                    s.setStatus(p6);
                } else {
                    s.setItemsSupplied(p6);
                    s.setStatus("Hoạt động");
                }
            }
            if (!s.getID().isEmpty()) {
                m_suppliers.append(s);
            }
        }
        file.close();
    }

    endResetModel();
}

void SupplierManager::saveToCSV() {
    QString path = getFilePath();
    QDir dir = QFileInfo(path).dir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        QTextStream out(&file);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        out.setCodec("UTF-8");
#endif
        out << "SupplierID,Name,ContactPerson,Phone,Email,Address,ItemsSupplied,Status\n";
        for (const auto &s : std::as_const(m_suppliers)) {
            out << escapeCsvField(s.getID()) << ","
                << escapeCsvField(s.getName()) << ","
                << escapeCsvField(s.getContactPerson()) << ","
                << escapeCsvField(s.getPhone()) << ","
                << escapeCsvField(s.getEmail()) << ","
                << escapeCsvField(s.getAddress()) << ","
                << escapeCsvField(s.getItemsSupplied()) << ","
                << escapeCsvField(s.getStatus()) << "\n";
        }
        file.close();
    }
}

bool SupplierManager::addSupplier(const QString &id, const QString &name, const QString &contactPerson, const QString &phone, const QString &email, const QString &address, const QString &itemsSupplied, const QString &status) {
    for (const auto &s : std::as_const(m_suppliers)) {
        if (s.getID() == id) return false;
    }

    beginInsertRows(QModelIndex(), m_suppliers.size(), m_suppliers.size());
    m_suppliers.append(Supplier(id, name, contactPerson, phone, email, address, itemsSupplied, status.isEmpty() ? "Hoạt động" : status));
    endInsertRows();

    saveToCSV();
    return true;
}

bool SupplierManager::updateSupplier(const QString &id, const QString &name, const QString &contactPerson, const QString &phone, const QString &email, const QString &address, const QString &itemsSupplied, const QString &status) {
    for (int i = 0; i < m_suppliers.size(); ++i) {
        if (m_suppliers[i].getID() == id) {
            m_suppliers[i].setName(name);
            m_suppliers[i].setContactPerson(contactPerson);
            m_suppliers[i].setPhone(phone);
            m_suppliers[i].setEmail(email);
            m_suppliers[i].setAddress(address);
            m_suppliers[i].setItemsSupplied(itemsSupplied);
            m_suppliers[i].setStatus(status.isEmpty() ? "Hoạt động" : status);

            QModelIndex idx = createIndex(i, 0);
            emit dataChanged(idx, idx);
            saveToCSV();
            return true;
        }
    }
    return false;
}

bool SupplierManager::deleteSupplier(const QString &id) {
    for (int i = 0; i < m_suppliers.size(); ++i) {
        if (m_suppliers[i].getID() == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_suppliers.removeAt(i);
            endRemoveRows();

            saveToCSV();
            return true;
        }
    }
    return false;
}

bool SupplierManager::importFromCSV(const QString &fileUrl) {
    QString localPath = QUrl(fileUrl).toLocalFile();
    if (localPath.isEmpty()) localPath = fileUrl;

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QTextStream in(&file);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    in.setCodec("UTF-8");
#endif
    bool isHeader = true;
    int importedCount = 0;

    QVector<Supplier> tempSuppliers = m_suppliers;

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;
        if (isHeader) { isHeader = false; continue; }

        QStringList parts = parseCsvLine(line);
        if (parts.size() >= 7) {
            QString id = parts[0];
            QString name = parts[1];
            QString contact = parts[2];
            QString phone = parts[3];
            QString email = parts[4];
            QString address = parts[5];
            QString items = "Chưa cập nhật";
            QString status = "Hoạt động";

            if (parts.size() >= 8) {
                items = parts[6];
                status = parts[7];
            } else {
                QString p6 = parts[6];
                if (p6 == "Hoạt động" || p6 == "Tạm dừng" || p6 == "Ngừng hoạt động") {
                    status = p6;
                } else {
                    items = p6;
                }
            }

            bool found = false;
            for (int i = 0; i < tempSuppliers.size(); ++i) {
                if (tempSuppliers[i].getID() == id) {
                    tempSuppliers[i] = Supplier(id, name, contact, phone, email, address, items, status);
                    found = true;
                    break;
                }
            }
            if (!found) {
                tempSuppliers.append(Supplier(id, name, contact, phone, email, address, items, status));
            }
            importedCount++;
        }
    }
    file.close();

    if (importedCount > 0) {
        beginResetModel();
        m_suppliers = tempSuppliers;
        endResetModel();
        saveToCSV();
        return true;
    }
    return false;
}

bool SupplierManager::exportToCSV(const QString &fileUrl) {
    QString localPath = QUrl(fileUrl).toLocalFile();
    if (localPath.isEmpty()) localPath = fileUrl;

    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) return false;

    QTextStream out(&file);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    out.setCodec("UTF-8");
#endif
    out << "SupplierID,Name,ContactPerson,Phone,Email,Address,ItemsSupplied,Status\n";
    for (const auto &s : std::as_const(m_suppliers)) {
        out << escapeCsvField(s.getID()) << ","
            << escapeCsvField(s.getName()) << ","
            << escapeCsvField(s.getContactPerson()) << ","
            << escapeCsvField(s.getPhone()) << ","
            << escapeCsvField(s.getEmail()) << ","
            << escapeCsvField(s.getAddress()) << ","
            << escapeCsvField(s.getItemsSupplied()) << ","
            << escapeCsvField(s.getStatus()) << "\n";
    }
    file.close();
    return true;
}