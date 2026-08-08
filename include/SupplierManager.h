#ifndef SUPPLIERMANAGER_H
#define SUPPLIERMANAGER_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>
#include <QString>
#include <QStringList>
#include "Supplier.h"

class SupplierManager : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int totalCount READ rowCount NOTIFY countChanged)

public:
    enum SupplierRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        ContactPersonRole,
        PhoneRole,
        EmailRole,
        AddressRole,
        ItemsSuppliedRole,
        StatusRole
    };

    explicit SupplierManager(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadFromCSV();
    Q_INVOKABLE void saveToCSV();
    Q_INVOKABLE bool addSupplier(const QString &id, const QString &name, const QString &contactPerson, const QString &phone, const QString &email, const QString &address, const QString &itemsSupplied, const QString &status = "Hoạt động");
    Q_INVOKABLE bool updateSupplier(const QString &id, const QString &name, const QString &contactPerson, const QString &phone, const QString &email, const QString &address, const QString &itemsSupplied, const QString &status = "Hoạt động");
    Q_INVOKABLE bool deleteSupplier(const QString &id);
    Q_INVOKABLE bool importFromCSV(const QString &fileUrl);
    Q_INVOKABLE bool exportToCSV(const QString &fileUrl);
    Q_INVOKABLE QString getSavePath() const;

signals:
    void countChanged();

private:
    QVector<Supplier> m_suppliers;
    QString getFilePath() const;

    static QStringList parseCsvLine(const QString &line);
    static QString escapeCsvField(const QString &field);
};

#endif // SUPPLIERMANAGER_H