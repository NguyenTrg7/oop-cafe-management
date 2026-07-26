#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qt_qml_GiangsCoffee_ui_main_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_GiangsCoffee_ui_OrderPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_GiangsCoffee_ui_LoyaltyPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_GiangsCoffee_ui_LoginPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_GiangsCoffee_ui_FinancePage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_GiangsCoffee_ui_EmployeeManagementPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}

}
namespace {
struct Registry {
    Registry();
    ~Registry();
    QHash<QString, const QQmlPrivate::CachedQmlUnit*> resourcePathToCachedUnit;
    static const QQmlPrivate::CachedQmlUnit *lookupCachedUnit(const QUrl &url);
};

Q_GLOBAL_STATIC(Registry, unitRegistry)


Registry::Registry() {
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/GiangsCoffee/ui/main.qml"), &QmlCacheGeneratedCode::_qt_qml_GiangsCoffee_ui_main_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/GiangsCoffee/ui/OrderPage.qml"), &QmlCacheGeneratedCode::_qt_qml_GiangsCoffee_ui_OrderPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/GiangsCoffee/ui/LoyaltyPage.qml"), &QmlCacheGeneratedCode::_qt_qml_GiangsCoffee_ui_LoyaltyPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/GiangsCoffee/ui/LoginPage.qml"), &QmlCacheGeneratedCode::_qt_qml_GiangsCoffee_ui_LoginPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/GiangsCoffee/ui/FinancePage.qml"), &QmlCacheGeneratedCode::_qt_qml_GiangsCoffee_ui_FinancePage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/GiangsCoffee/ui/EmployeeManagementPage.qml"), &QmlCacheGeneratedCode::_qt_qml_GiangsCoffee_ui_EmployeeManagementPage_qml::unit);
    QQmlPrivate::RegisterQmlUnitCacheHook registration;
    registration.structVersion = 0;
    registration.lookupCachedQmlUnit = &lookupCachedUnit;
    QQmlPrivate::qmlregister(QQmlPrivate::QmlUnitCacheHookRegistration, &registration);
}

Registry::~Registry() {
    QQmlPrivate::qmlunregister(QQmlPrivate::QmlUnitCacheHookRegistration, quintptr(&lookupCachedUnit));
}

const QQmlPrivate::CachedQmlUnit *Registry::lookupCachedUnit(const QUrl &url) {
    if (url.scheme() != QLatin1String("qrc"))
        return nullptr;
    QString resourcePath = QDir::cleanPath(url.path());
    if (resourcePath.isEmpty())
        return nullptr;
    if (!resourcePath.startsWith(QLatin1Char('/')))
        resourcePath.prepend(QLatin1Char('/'));
    return unitRegistry()->resourcePathToCachedUnit.value(resourcePath, nullptr);
}
}
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_GiangsCoffee)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_GiangsCoffee))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_GiangsCoffee)() {
    return 1;
}
