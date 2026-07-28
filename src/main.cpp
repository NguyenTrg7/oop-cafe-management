#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Account.h"
#include "EmployeeModel.h"
#include <iostream>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    std::cout << "========================================================\n";
    std::cout << "            HE THONG QUAN LY GIANG COFFEE v1.0            \n";
    std::cout << "   Du an phat trien boi Nhom 3: Nguyen, Quang, Thanh, Giang, Khuong\n";
    std::cout << "========================================================\n";

    QQmlApplicationEngine engine;

    // Khởi tạo Account Handler trước
    Account accountHandler;

    // Khởi tạo EmployeeModel và truyền accountHandler vào để liên kết tự động
    EmployeeModel employeeModel(&accountHandler);

    // Chuyển đối tượng sang QML Context Properties
    engine.rootContext()->setContextProperty("accountHandler", &accountHandler);
    engine.rootContext()->setContextProperty("cppEmployeeModel", &employeeModel);

    const QUrl url(QStringLiteral("qrc:/qt/qml/GiangsCoffee/ui/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}