#ifndef ORDERHISTORYITEM_H
#define ORDERHISTORYITEM_H

#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QDateTime>

struct OrderItemDetail {
    QString id;
    QString name;
    QString size;
    int     quantity;
    QString note;
    double  totalPrice;
    QString category;
    QString ice;
    QString toppings;
};

struct OrderHistoryItem {
    QString invoiceNumber;
    QString date;          // dd/MM/yyyy
    QString time;          // hh:mm:ss
    QString customerName;  // hoặc "Khách vãng lai"
    double  totalAmount;
    double  discount;
    QString voucherCode;
    QString status;        // "Completed", "Cancelled"...
    QList<OrderItemDetail> items;
};

#endif