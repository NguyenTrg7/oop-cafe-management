/****************************************************************************
** Meta object code from reading C++ file 'Account.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../include/Account.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'Account.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN7AccountE_t {};
} // unnamed namespace

template <> constexpr inline auto Account::qt_create_metaobjectdata<qt_meta_tag_ZN7AccountE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "Account",
        "currentUserChanged",
        "",
        "loadFromFile",
        "filePath",
        "saveToFile",
        "loginAndGetRole",
        "username",
        "password",
        "registerAccount",
        "role",
        "getAccountList",
        "QVariantList",
        "addAccount",
        "updateAccount",
        "newPassword",
        "newRole",
        "deleteAccount",
        "currentUser"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'currentUserChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'loadFromFile'
        QtMocHelpers::MethodData<bool(const QString &)>(3, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 4 },
        }}),
        // Method 'saveToFile'
        QtMocHelpers::MethodData<bool(const QString &)>(5, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 4 },
        }}),
        // Method 'saveToFile'
        QtMocHelpers::MethodData<bool()>(5, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Bool),
        // Method 'loginAndGetRole'
        QtMocHelpers::MethodData<QString(const QString &, const QString &)>(6, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 7 }, { QMetaType::QString, 8 },
        }}),
        // Method 'registerAccount'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, const QString &)>(9, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 7 }, { QMetaType::QString, 8 }, { QMetaType::QString, 10 },
        }}),
        // Method 'getAccountList'
        QtMocHelpers::MethodData<QVariantList()>(11, 2, QMC::AccessPublic, 0x80000000 | 12),
        // Method 'addAccount'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, const QString &)>(13, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 7 }, { QMetaType::QString, 8 }, { QMetaType::QString, 10 },
        }}),
        // Method 'updateAccount'
        QtMocHelpers::MethodData<bool(const QString &, const QString &, const QString &)>(14, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 7 }, { QMetaType::QString, 15 }, { QMetaType::QString, 16 },
        }}),
        // Method 'deleteAccount'
        QtMocHelpers::MethodData<bool(const QString &)>(17, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 7 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'currentUser'
        QtMocHelpers::PropertyData<QString>(18, QMetaType::QString, QMC::DefaultPropertyFlags, 0),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<Account, qt_meta_tag_ZN7AccountE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject Account::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN7AccountE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN7AccountE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN7AccountE_t>.metaTypes,
    nullptr
} };

void Account::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<Account *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->currentUserChanged(); break;
        case 1: { bool _r = _t->loadFromFile((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 2: { bool _r = _t->saveToFile((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 3: { bool _r = _t->saveToFile();
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 4: { QString _r = _t->loginAndGetRole((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 5: { bool _r = _t->registerAccount((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 6: { QVariantList _r = _t->getAccountList();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 7: { bool _r = _t->addAccount((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 8: { bool _r = _t->updateAccount((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 9: { bool _r = _t->deleteAccount((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (Account::*)()>(_a, &Account::currentUserChanged, 0))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QString*>(_v) = _t->currentUser(); break;
        default: break;
        }
    }
}

const QMetaObject *Account::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Account::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN7AccountE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Account::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 10;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void Account::currentUserChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
