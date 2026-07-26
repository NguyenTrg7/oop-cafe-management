/****************************************************************************
** Meta object code from reading C++ file 'GiangCoffeeSystem.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../include/GiangCoffeeSystem.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'GiangCoffeeSystem.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN17GiangCoffeeSystemE_t {};
} // unnamed namespace

template <> constexpr inline auto GiangCoffeeSystem::qt_create_metaobjectdata<qt_meta_tag_ZN17GiangCoffeeSystemE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "GiangCoffeeSystem",
        "addEmployee",
        "",
        "Employee*",
        "emp",
        "removeEmployee",
        "empID",
        "updateEmployeeShift",
        "id",
        "shift",
        "calculatePayroll",
        "addItem",
        "Menu",
        "item",
        "removeItem",
        "itemId",
        "searchMenu",
        "name",
        "printMenu",
        "placeOrder",
        "Order*",
        "order",
        "reserveTable",
        "tableNum",
        "mergeTable",
        "num1",
        "num2",
        "generateReport",
        "date",
        "checkDiscount",
        "code",
        "totalAmount",
        "loadEmployees",
        "QVariantList",
        "addEmployeeCSV",
        "pos",
        "salary",
        "loadFinance",
        "addTransactionCSV",
        "type",
        "amount",
        "note",
        "deleteEmployeeCSV",
        "updateEmployeeCSV"
    };

    QtMocHelpers::UintData qt_methods {
        // Method 'addEmployee'
        QtMocHelpers::MethodData<void(Employee *)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 3, 4 },
        }}),
        // Method 'removeEmployee'
        QtMocHelpers::MethodData<void(const QString &)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 6 },
        }}),
        // Method 'updateEmployeeShift'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 }, { QMetaType::QString, 9 },
        }}),
        // Method 'calculatePayroll'
        QtMocHelpers::MethodData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'addItem'
        QtMocHelpers::MethodData<void(const Menu &)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 12, 13 },
        }}),
        // Method 'removeItem'
        QtMocHelpers::MethodData<void(const QString &)>(14, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 15 },
        }}),
        // Method 'searchMenu'
        QtMocHelpers::MethodData<Menu(const QString &)>(16, 2, QMC::AccessPublic, 0x80000000 | 12, {{
            { QMetaType::QString, 17 },
        }}),
        // Method 'printMenu'
        QtMocHelpers::MethodData<void()>(18, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'placeOrder'
        QtMocHelpers::MethodData<void(Order *)>(19, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 20, 21 },
        }}),
        // Method 'reserveTable'
        QtMocHelpers::MethodData<void(int)>(22, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 23 },
        }}),
        // Method 'mergeTable'
        QtMocHelpers::MethodData<void(int, int)>(24, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 25 }, { QMetaType::Int, 26 },
        }}),
        // Method 'generateReport'
        QtMocHelpers::MethodData<void(const QDateTime &)>(27, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QDateTime, 28 },
        }}),
        // Method 'checkDiscount'
        QtMocHelpers::MethodData<double(const QString &, double)>(29, 2, QMC::AccessPublic, QMetaType::Double, {{
            { QMetaType::QString, 30 }, { QMetaType::Double, 31 },
        }}),
        // Method 'loadEmployees'
        QtMocHelpers::MethodData<QVariantList()>(32, 2, QMC::AccessPublic, 0x80000000 | 33),
        // Method 'addEmployeeCSV'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, const QString &, double, const QString &)>(34, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 8 }, { QMetaType::QString, 17 }, { QMetaType::QString, 35 }, { QMetaType::Double, 36 },
            { QMetaType::QString, 9 },
        }}),
        // Method 'loadFinance'
        QtMocHelpers::MethodData<QVariantList()>(37, 2, QMC::AccessPublic, 0x80000000 | 33),
        // Method 'addTransactionCSV'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, double, const QString &)>(38, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 28 }, { QMetaType::QString, 39 }, { QMetaType::Double, 40 }, { QMetaType::QString, 41 },
        }}),
        // Method 'deleteEmployeeCSV'
        QtMocHelpers::MethodData<bool(const QString &)>(42, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 8 },
        }}),
        // Method 'updateEmployeeCSV'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, const QString &, double, const QString &)>(43, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 8 }, { QMetaType::QString, 17 }, { QMetaType::QString, 35 }, { QMetaType::Double, 36 },
            { QMetaType::QString, 9 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<GiangCoffeeSystem, qt_meta_tag_ZN17GiangCoffeeSystemE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject GiangCoffeeSystem::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17GiangCoffeeSystemE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17GiangCoffeeSystemE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN17GiangCoffeeSystemE_t>.metaTypes,
    nullptr
} };

void GiangCoffeeSystem::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<GiangCoffeeSystem *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->addEmployee((*reinterpret_cast<std::add_pointer_t<Employee*>>(_a[1]))); break;
        case 1: _t->removeEmployee((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 2: _t->updateEmployeeShift((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 3: _t->calculatePayroll(); break;
        case 4: _t->addItem((*reinterpret_cast<std::add_pointer_t<Menu>>(_a[1]))); break;
        case 5: _t->removeItem((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 6: { Menu _r = _t->searchMenu((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<Menu*>(_a[0]) = std::move(_r); }  break;
        case 7: _t->printMenu(); break;
        case 8: _t->placeOrder((*reinterpret_cast<std::add_pointer_t<Order*>>(_a[1]))); break;
        case 9: _t->reserveTable((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 10: _t->mergeTable((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2]))); break;
        case 11: _t->generateReport((*reinterpret_cast<std::add_pointer_t<QDateTime>>(_a[1]))); break;
        case 12: { double _r = _t->checkDiscount((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<double>>(_a[2])));
            if (_a[0]) *reinterpret_cast<double*>(_a[0]) = std::move(_r); }  break;
        case 13: { QVariantList _r = _t->loadEmployees();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 14: { bool _r = _t->addEmployeeCSV((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 15: { QVariantList _r = _t->loadFinance();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 16: { bool _r = _t->addTransactionCSV((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 17: { bool _r = _t->deleteEmployeeCSV((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 18: { bool _r = _t->updateEmployeeCSV((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 0:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< Employee* >(); break;
            }
            break;
        }
    }
}

const QMetaObject *GiangCoffeeSystem::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *GiangCoffeeSystem::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17GiangCoffeeSystemE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int GiangCoffeeSystem::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 19)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 19;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 19)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 19;
    }
    return _id;
}
QT_WARNING_POP
