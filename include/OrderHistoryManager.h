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

    // Lưu 1 đơn hàng mới
    Q_INVOKABLE void addOrder(const QVariantMap &orderData);

    // Lấy danh sách lịch sử (cho QML)
    Q_INVOKABLE QVariantList getHistory() const;

    // Lấy chi tiết 1 đơn theo mã hóa đơn
    Q_INVOKABLE QVariantMap getOrderDetail(const QString &invoiceNumber) const;

    // Xóa / hủy đơn (tuỳ chọn)
    Q_INVOKABLE bool removeOrder(const QString &invoiceNumber);

    // Load / Save file
    Q_INVOKABLE bool loadFromCSV(const QString &path);
    Q_INVOKABLE bool saveToCSV(const QString &path) const;

    void setSavePath(const QString &path);
signals:
    void historyChanged();


};

#endif