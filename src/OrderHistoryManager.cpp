#include "OrderHistoryManager.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

OrderHistoryManager::OrderHistoryManager(QObject *parent)
    : QObject(parent)
{
}
void OrderHistoryManager::setSavePath(const QString &path)
{
    m_savePath = path;
}
void OrderHistoryManager::addOrder(const QVariantMap &orderData)
{
    OrderHistoryItem order;
    order.invoiceNumber = orderData["invoiceNumber"].toString();
    order.date          = orderData["date"].toString();
    order.time          = orderData["time"].toString();
    order.customerName  = orderData.value("customerName", "Khách vãng lai").toString();
    order.totalAmount   = orderData["totalAmount"].toDouble();
    order.discount      = orderData.value("discount", 0).toDouble();
    order.voucherCode   = orderData.value("voucherCode", "").toString();
    order.status        = "Completed";

    QVariantList items = orderData["items"].toList();
    for (const QVariant &v : items) {
        QVariantMap m = v.toMap();
        OrderItemDetail item;
        item.id         = m["id"].toString();
        item.name       = m["name"].toString();
        item.size       = m["size"].toString();
        item.quantity   = m["quantity"].toInt();
        item.note       = m["note"].toString();
        item.totalPrice = m["totalPrice"].toDouble();
        item.category   = m["category"].toString();
        item.ice        = m.value("ice").toString();
        item.toppings   = m.value("toppings").toString();
        order.items.append(item);
    }

    m_history.prepend(order);
    emit historyChanged();

    if(!m_savePath.isEmpty())
        saveToCSV(m_savePath);
}

QVariantList OrderHistoryManager::getHistory() const
{
    QVariantList list;
    for (const auto &order : m_history) {
        QVariantMap m;
        m["invoiceNumber"] = order.invoiceNumber;
        m["date"]          = order.date;
        m["time"]          = order.time;
        m["customerName"]  = order.customerName;
        m["totalAmount"]   = order.totalAmount;
        m["discount"]      = order.discount;
        m["voucherCode"]   = order.voucherCode;
        m["status"]        = order.status;
        m["itemCount"]     = order.items.size();
        list.append(m);
    }
    return list;
}

QVariantMap OrderHistoryManager::getOrderDetail(const QString &invoiceNumber) const
{
    for (const auto &order : m_history) {
        if (order.invoiceNumber == invoiceNumber) {
            QVariantMap m;
            m["invoiceNumber"] = order.invoiceNumber;
            m["date"]          = order.date;
            m["time"]          = order.time;
            m["customerName"]  = order.customerName;
            m["totalAmount"]   = order.totalAmount;
            m["discount"]      = order.discount;
            m["voucherCode"]   = order.voucherCode;
            m["status"]        = order.status;

            QVariantList items;
            for (const auto &item : order.items) {
                QVariantMap im;
                im["id"]         = item.id;
                im["name"]       = item.name;
                im["size"]       = item.size;
                im["quantity"]   = item.quantity;
                im["note"]       = item.note;
                im["totalPrice"] = item.totalPrice;
                im["category"]   = item.category;
                im["ice"]        = item.ice;
                im["toppings"]   = item.toppings;
                items.append(im);
            }
            m["items"] = items;
            return m;
        }
    }
    return QVariantMap();
}

bool OrderHistoryManager::removeOrder(const QString &invoiceNumber)
{
    for (int i = 0; i < m_history.size(); ++i) {
        if (m_history[i].invoiceNumber == invoiceNumber) {
            m_history.removeAt(i);
            emit historyChanged();
            return true;
        }
    }
    return false;
}

bool OrderHistoryManager::saveToCSV(const QString &path) const
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << "InvoiceNumber,Date,Time,CustomerName,TotalAmount,Discount,VoucherCode,Status,ItemsJson\n";

    for (const auto &order : m_history) {
        // Gói items thành JSON string
        QJsonArray itemsArr;
        for (const auto &item : order.items) {
            QJsonObject o;
            o["id"] = item.id;
            o["name"] = item.name;
            o["size"] = item.size;
            o["quantity"] = item.quantity;
            o["note"] = item.note;
            o["totalPrice"] = item.totalPrice;
            o["category"] = item.category;
            o["ice"] = item.ice;
            o["toppings"] = item.toppings;
            itemsArr.append(o);
        }
        QString itemsJson = QString::fromUtf8(
            QJsonDocument(itemsArr).toJson(QJsonDocument::Compact));
        // Escape dấu phẩy / ngoặc kép trong CSV
        itemsJson.replace("\"", "\"\"");

        out << order.invoiceNumber << ","
            << order.date << ","
            << order.time << ","
            << "\"" << order.customerName << "\","
            << order.totalAmount << ","
            << order.discount << ","
            << order.voucherCode << ","
            << order.status << ","
            << "\"" << itemsJson << "\"\n";
    }
    file.close();
    return true;
}

bool OrderHistoryManager::loadFromCSV(const QString &path)
{
    QFile file(path);
    if (!file.exists() || !file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QTextStream in(&file);
    in.readLine();
    m_history.clear();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList cols;
        QString cur;
        bool inQuote = false;
        for (int i = 0; i < line.size(); ++i) {
            QChar c = line[i];
            if (c == '"') {
                if (inQuote && i + 1 < line.size() && line[i + 1] == '"') {
                    cur += '"'; ++i;
                } else {
                    inQuote = !inQuote;
                }
            } else if (c == ',' && !inQuote) {
                cols.append(cur);
                cur.clear();
            } else {
                cur += c;
            }
        }
        cols.append(cur);
        if (cols.size() < 9) continue;

        OrderHistoryItem order;
        order.invoiceNumber = cols[0];
        order.date          = cols[1];
        order.time          = cols[2];
        order.customerName  = cols[3];
        order.totalAmount   = cols[4].toDouble();
        order.discount      = cols[5].toDouble();
        order.voucherCode   = cols[6];
        order.status        = cols[7];

        QJsonDocument doc = QJsonDocument::fromJson(cols[8].toUtf8());
        if (doc.isArray()) {
            for (const auto &v : doc.array()) {
                QJsonObject o = v.toObject();
                OrderItemDetail item;
                item.id         = o["id"].toString();
                item.name       = o["name"].toString();
                item.size       = o["size"].toString();
                item.quantity   = o["quantity"].toInt();
                item.note       = o["note"].toString();
                item.totalPrice = o["totalPrice"].toDouble();
                item.category   = o["category"].toString();
                item.ice        = o["ice"].toString();
                item.toppings   = o["toppings"].toString();
                order.items.append(item);
            }
        }
        m_history.append(order);
    }
    file.close();
    emit historyChanged();
    return true;
}