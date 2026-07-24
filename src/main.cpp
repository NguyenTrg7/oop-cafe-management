#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QDebug>

#include "Account.h"
#include "GiangCoffeeSystem.h" // Import Header Singleton của bạn

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);


    QDir::setCurrent(QCoreApplication::applicationDirPath());

    QQmlApplicationEngine engine;

    Account account;
    QString accountPath = QCoreApplication::applicationDirPath() + "/data/accounts.csv";
    if (!QFile::exists(accountPath)) {
        QDir sourceDir(QCoreApplication::applicationDirPath());
        sourceDir.cdUp();
        sourceDir.cdUp();
        QString altPath = sourceDir.filePath("data/accounts.csv");
        if (QFile::exists(altPath)) accountPath = altPath;
    }
    account.loadFromFile(accountPath);
    engine.rootContext()->setContextProperty("accountHandler", &account);

    // 3. ĐĂNG KÝ SINGLETON GIANGCOFFEESYSTEM VÀO QML
    // Kết nối instance với tên "coffeeSystem" đúng như các file QML đang gọi
    GiangCoffeeSystem* systemInstance = GiangCoffeeSystem::getInstance();
    engine.rootContext()->setContextProperty("coffeeSystem", systemInstance);

    // 4. Load file QML chính
    const QUrl url(QStringLiteral("qrc:/qt/qml/GiangsCoffee/ui/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}