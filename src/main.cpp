#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <iostream>

#include "Account.h"
#include "Customer.h"
#include "EmployeeModel.h"
#include "IngredientManager.h"
#include "OrderHistoryManager.h"
#include "GiangCoffeeSystem.h"// Import Header Singleton xử lý Menu

// Hàm hỗ trợ tìm kiếm file dữ liệu (Lấy từ main1.cpp)
QString findDataFile(const QString &relativePath)
{
    QString path = QCoreApplication::applicationDirPath() + "/" + relativePath;
    if (!QFile::exists(path)) {
        QDir sourceDir(QCoreApplication::applicationDirPath());
        sourceDir.cdUp();
        sourceDir.cdUp();
        QString altPath = sourceDir.filePath(relativePath);
        if (QFile::exists(altPath))
            return altPath;
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
    Customer customerHandler;

    accountHandler.setCustomerHandler(&customerHandler);
    EmployeeModel employeeModel(&accountHandler);

    engine.rootContext()->setContextProperty("accountHandler", &accountHandler);
    engine.rootContext()->setContextProperty("customerHandler", &customerHandler);  // ← THIẾU DÒNG NÀY SẼ LỖI

    // ==========================================
    // 2. XỬ LÝ MENU (Thêm từ main1.cpp)
    // ==========================================
    GiangCoffeeSystem *systemInstance = GiangCoffeeSystem::getInstance();

    QString drinkPath = findDataFile("data/drink.csv");
    QString foodPath = findDataFile("data/food.csv");

    // Nạp dữ liệu từ CSV
    systemInstance->getMenuManager()->loadDrinksCSV(drinkPath);
    systemInstance->getMenuManager()->loadFoodsCSV(foodPath);


    // ===== INGREDIENT =====
    IngredientManager ingManager;
    systemInstance->getMenuManager()->setIngredientManager(&ingManager);
    // Tạo thư mục data cạnh file .exe (luôn ghi được)
    QString dataDir = QCoreApplication::applicationDirPath() + "/data";
    QDir().mkpath(dataDir);

    QString drinkIngPath = dataDir + "/IngredientDrink.csv";
    QString foodIngPath  = dataDir + "/IngredientFood.csv";
    QString recipesPath  = findDataFile("data/Recipes.csv"); // recipe có thể giữ nguyên

    // Nếu file chưa có trong thư mục exe → copy từ bản gốc
    auto ensureFile = [](const QString &dest, const QString &srcName) {
        if (!QFile::exists(dest)) {
            QString src = findDataFile(srcName);
            if (QFile::exists(src))
                QFile::copy(src, dest);
        }
    };
    ensureFile(drinkIngPath, "data/IngredientDrink.csv");
    ensureFile(foodIngPath,  "data/IngredientFood.csv");

    ingManager.loadIngredientsCSV(drinkIngPath, true);
    ingManager.loadIngredientsCSV(foodIngPath, false);
    ingManager.loadRecipesCSV(recipesPath);
    ingManager.setPaths(drinkIngPath, foodIngPath);

    qDebug() << "FOOD FILE (mở file này để kiểm tra):" << foodIngPath;

    // ===== ORDER HISTORY =====
    QString historyPath  = findDataFile("data/OrderHistory.csv");
    OrderHistoryManager *historyManager = new OrderHistoryManager();
    historyManager->setSavePath(historyPath);
    historyManager->loadFromCSV(historyPath);   // load lại lịch sử cũ

    // Đăng ký QML
    engine.rootContext()->setContextProperty("ingredientManager", &ingManager);
    engine.rootContext()->setContextProperty("orderHistoryManager", historyManager);

    // ==========================================
    // 3. ĐĂNG KÝ QML CONTEXT PROPERTIES
    // ==========================================
    engine.rootContext()->setContextProperty("accountHandler", &accountHandler);
    engine.rootContext()->setContextProperty("cppEmployeeModel", &employeeModel);
    engine.rootContext()->setContextProperty("coffeeSystem", systemInstance); // Đăng ký thêm system cho menu
    engine.rootContext()->setContextProperty("ingredientManager", &ingManager);
    engine.rootContext()->setContextProperty("orderHistoryManager", historyManager);
    // 4. Load file QML chính
    const QUrl url(QStringLiteral("qrc:/qt/qml/GiangsCoffee/ui/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("applicationDir", QCoreApplication::applicationDirPath());

    engine.load(QUrl(QStringLiteral("qrc:/main.qml"))); // hoặc load từ file

    engine.load(url);

    return app.exec();
}