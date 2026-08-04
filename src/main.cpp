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
#include "GiangCoffeeSystem.h"   // Import Header Singleton xử lý Menu
#include "IngredientManager.h"   // Thêm từ Source 4
#include "OrderHistoryManager.h" // Thêm từ Source 4

// Hàm hỗ trợ tìm kiếm file dữ liệu
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

    // Set thư mục gốc
    QDir::setCurrent(QCoreApplication::applicationDirPath());

    QQmlApplicationEngine engine;

    // ==========================================
    // 1. XỬ LÝ ACCOUNT, CUSTOMER & EMPLOYEE
    // ==========================================
    Account accountHandler;
    Customer customerHandler;

    accountHandler.setCustomerHandler(&customerHandler);
    EmployeeModel employeeModel(&accountHandler);

    // ==========================================
    // 2. XỬ LÝ MENU (GIANG COFFEE SYSTEM)
    // ==========================================
    GiangCoffeeSystem *systemInstance = GiangCoffeeSystem::getInstance();

    QString drinkPath = findDataFile("data/drink.csv");
    QString foodPath = findDataFile("data/food.csv");

    // Nạp dữ liệu từ CSV
    systemInstance->getMenuManager()->loadDrinksCSV(drinkPath);
    systemInstance->getMenuManager()->loadFoodsCSV(foodPath);

    // ==========================================
    // 3. XỬ LÝ QUẢN LÝ TỒN KHO (INGREDIENT MANAGER)
    // ==========================================
    IngredientManager ingManager;
    systemInstance->getMenuManager()->setIngredientManager(&ingManager);

    // Tạo thư mục data cạnh file .exe
    QString dataDir = QCoreApplication::applicationDirPath() + "/data";
    QDir().mkpath(dataDir);

    QString drinkIngPath = dataDir + "/IngredientDrink.csv";
    QString foodIngPath  = dataDir + "/IngredientFood.csv";
    QString recipesPath  = findDataFile("data/Recipes.csv");

    // Tự động copy file mặc định nếu chưa tồn tại
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

    // ==========================================
    // 4. XỬ LÝ LỊCH SỬ ĐƠN HÀNG (ORDER HISTORY MANAGER)
    // ==========================================
    QString historyPath = findDataFile("data/OrderHistory.csv");
    OrderHistoryManager *historyManager = new OrderHistoryManager();
    historyManager->setSavePath(historyPath);
    historyManager->loadFromCSV(historyPath);

    // ==========================================
    // 5. ĐĂNG KÝ QML CONTEXT PROPERTIES (TỔNG HỢP & DỌC SẠCH TRÙNG)
    // ==========================================
    engine.rootContext()->setContextProperty("accountHandler", &accountHandler);
    engine.rootContext()->setContextProperty("customerHandler", &customerHandler);
    engine.rootContext()->setContextProperty("cppEmployeeModel", &employeeModel);
    engine.rootContext()->setContextProperty("coffeeSystem", systemInstance);
    engine.rootContext()->setContextProperty("ingredientManager", &ingManager);
    engine.rootContext()->setContextProperty("orderHistoryManager", historyManager);
    engine.rootContext()->setContextProperty("applicationDir", QCoreApplication::applicationDirPath());

    // ==========================================
    // 6. LOAD FILE QML CHÍNH
    // ==========================================
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

    // Giữ duy nhất 1 lệnh load để tránh crash/hiển thị 2 cửa sổ
    engine.load(url);

    return app.exec();
}