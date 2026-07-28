#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <iostream>

#include "Account.h"
#include "EmployeeModel.h"
#include "GiangCoffeeSystem.h" // Import Header Singleton xử lý Menu

// Hàm hỗ trợ tìm kiếm file dữ liệu (Lấy từ main1.cpp)
QString findDataFile(const QString &relativePath) {
    QString path = QCoreApplication::applicationDirPath() + "/" + relativePath;
    if (!QFile::exists(path)) {
        QDir sourceDir(QCoreApplication::applicationDirPath());
        sourceDir.cdUp();
        sourceDir.cdUp();
        QString altPath = sourceDir.filePath(relativePath);
        if (QFile::exists(altPath)) return altPath;
    }
    return path;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    std::cout << "========================================================\n";
    std::cout << "            HE THONG QUAN LY GIANG COFFEE v1.0            \n";
    std::cout << "   Du an phat trien boi Nhom 3: Nguyen, Quang, Thanh, Giang, Khuong\n";
    std::cout << "========================================================\n";

    // Set thư mục gốc (Lấy từ main1.cpp)
    QDir::setCurrent(QCoreApplication::applicationDirPath());

    QQmlApplicationEngine engine;

    // ==========================================
    // 1. XỬ LÝ ACCOUNT (Giữ nguyên của main.cpp)
    // ==========================================
    Account accountHandler;
    EmployeeModel employeeModel(&accountHandler);

    // ==========================================
    // 2. XỬ LÝ MENU (Thêm từ main1.cpp)
    // ==========================================
    GiangCoffeeSystem* systemInstance = GiangCoffeeSystem::getInstance();

    QString drinkPath = findDataFile("data/drink.csv");
    QString foodPath = findDataFile("data/food.csv");

    // Nạp dữ liệu từ CSV
    systemInstance->getMenuManager()->loadDrinksCSV(drinkPath);
    systemInstance->getMenuManager()->loadFoodsCSV(foodPath);

    // ==========================================
    // 3. ĐĂNG KÝ QML CONTEXT PROPERTIES
    // ==========================================
    engine.rootContext()->setContextProperty("accountHandler", &accountHandler);
    engine.rootContext()->setContextProperty("cppEmployeeModel", &employeeModel);
    engine.rootContext()->setContextProperty("coffeeSystem", systemInstance); // Đăng ký thêm system cho menu

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