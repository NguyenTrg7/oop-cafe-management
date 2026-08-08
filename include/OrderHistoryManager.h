#ifndef ORDERHISTORYMANAGER_H
#define ORDERHISTORYMANAGER_H

#include <QObject>
#include <QList>
#include <QVariantList>
#include "OrderHistoryItem.h"

class OrderHistoryManager : public QObject
{
    Q_OBJECT

private:
    QList<OrderHistoryItem> m_history;
    QString m_savePath;
public:
    explicit OrderHistoryManager(QObject *parent = nullptr);

    Q_INVOKABLE void addOrder(const QVariantMap &orderData);
    Q_INVOKABLE QVariantList getHistory() const;
    Q_INVOKABLE QVariantMap getOrderDetail(const QString &invoiceNumber) const;
    Q_INVOKABLE bool removeOrder(const QString &invoiceNumber);

    // Load / Save file
    Q_INVOKABLE bool loadFromCSV(const QString &path);
    Q_INVOKABLE bool saveToCSV(const QString &path) const;

    void setSavePath(const QString &path);
signals:
    void historyChanged();


};

#endif