#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>  // <-- THÊM: Thư viện kết nối C++ với QML
#include "Account.h"    // <-- THÊM: Class quản lý tài khoản
#include <iostream>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    std::cout << "========================================================\n";
    std::cout << "            HE THONG QUAN LY GIANG COFFEE v1.0            \n";
    std::cout << "   Du an phat trien boi Nhom 3: Nguyen, Quang, Thanh, Giang, Khuong\n";
    std::cout << "========================================================\n";

    QQmlApplicationEngine engine;

    // =======================================================
    // KHỞI TẠO VÀ CHUYỂN ACCOUNT HANDLER SANG QML
    // =======================================================
    Account accountHandler;
    engine.rootContext()->setContextProperty("accountHandler", &accountHandler);

    // Dùng QStringLiteral (chuẩn mực và an toàn nhất, không lo cảnh báo hay lỗi)
    const QUrl url(QStringLiteral("qrc:/qt/qml/GiangsCoffee/ui/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}