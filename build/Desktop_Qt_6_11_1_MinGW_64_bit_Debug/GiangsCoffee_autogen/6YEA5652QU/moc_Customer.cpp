
#include "../../../../include/Customer.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'Customer.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN8CustomerE_t {};
} // unnamed namespace

template <> constexpr inline auto Customer::qt_create_metaobjectdata<qt_meta_tag_ZN8CustomerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "Customer",
        "loyaltyPointsChanged",
        "",
        "rankChanged",
        "loyaltyPoints",
        "phoneNumber",
        "rank"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'loyaltyPointsChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'loyaltyPoints'
        QtMocHelpers::PropertyData<int>(4, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 0),
        // property 'phoneNumber'
        QtMocHelpers::PropertyData<QString>(5, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Constant),
        // property 'rank'
        QtMocHelpers::PropertyData<QString>(6, QMetaType::QString, QMC::DefaultPropertyFlags, 0x70000000 | 3),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<Customer, qt_meta_tag_ZN8CustomerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject Customer::staticMetaObject = { {
    QMetaObject::SuperData::link<User::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN8CustomerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN8CustomerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN8CustomerE_t>.metaTypes,
    nullptr
} };

void Customer::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<Customer *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->loyaltyPointsChanged(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (Customer::*)()>(_a, &Customer::loyaltyPointsChanged, 0))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<int*>(_v) = _t->loyaltyPoints(); break;
        case 1: *reinterpret_cast<QString*>(_v) = _t->m_phoneNumber; break;
        case 2: *reinterpret_cast<QString*>(_v) = _t->m_rank; break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setLoyaltyPoints(*reinterpret_cast<int*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *Customer::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Customer::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN8CustomerE_t>.strings))
        return static_cast<void*>(this);
    return User::qt_metacast(_clname);
}

int Customer::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = User::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 1)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 1;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}

// SIGNAL 0
void Customer::loyaltyPointsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
namespace CheckNotifySignalValidity_ZN8CustomerE {
template<typename T> using has_nullary_rankChanged = decltype(std::declval<T>().rankChanged());
template<typename T> using has_unary_rankChanged = decltype(std::declval<T>().rankChanged(std::declval<QString>()));
// static_assert(qxp::is_detected_v<has_nullary_rankChanged, Customer> || qxp::is_detected_v<has_unary_rankChanged, Customer>,
//               "NOTIFY signal rankChanged does not exist in class (or is private in its parent)");
}
QT_WARNING_POP
