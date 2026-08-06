#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QUrl>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <iostream>

#include "Account.h"
#include "Customer.h"
#include "EmployeeModel.h"
#include "GiangCoffeeSystem.h"   // Import Header Singleton xử lý Menu
#include "IngredientManager.h"
#include "OrderHistoryManager.h"

// Fallback nếu không chạy từ CMake
#ifndef SAVE_DIR_PATH
#define SAVE_DIR_PATH "./saves"
#endif

// Hàm hỗ trợ lấy đường dẫn file nằm trong thư mục saves
QString getSavePath(const QString &fileName)
{
    QDir dir(SAVE_DIR_PATH);
    if (!dir.exists()) {
        dir.mkpath("."); // Tự động tạo thư mục saves nếu chưa có
    }
    return dir.filePath(fileName);
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    std::cout << "========================================================\n";
    std::cout << "            HE THONG QUAN LY GIANG COFFEE v1.0            \n";
    std::cout << "   Du an phat trien boi Nhom 3: Nguyen, Quang, Thanh, Giang, Khuong\n";
    std::cout << "========================================================\n";

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

    QString drinkPath = getSavePath("drink.csv");
    QString foodPath  = getSavePath("food.csv");

    // Nạp dữ liệu từ CSV trong thư mục saves
    systemInstance->getMenuManager()->loadDrinksCSV(drinkPath);
    systemInstance->getMenuManager()->loadFoodsCSV(foodPath);

    // ==========================================
    // 3. XỬ LÝ QUẢN LÝ TỒN KHO (INGREDIENT MANAGER)
    // ==========================================
    IngredientManager ingManager;
    systemInstance->getMenuManager()->setIngredientManager(&ingManager);

    QString drinkIngPath = getSavePath("IngredientDrink.csv");
    QString foodIngPath  = getSavePath("IngredientFood.csv");
    QString recipesPath  = getSavePath("Recipes.csv");

    ingManager.loadIngredientsCSV(drinkIngPath, true);
    ingManager.loadIngredientsCSV(foodIngPath, false);
    ingManager.loadRecipesCSV(recipesPath);
    ingManager.setPaths(drinkIngPath, foodIngPath);

    // ==========================================
    // 4. XỬ LÝ LỊCH SỬ ĐƠN HÀNG (ORDER HISTORY MANAGER)
    // ==========================================
    QString historyPath = getSavePath("OrderHistory.csv");
    OrderHistoryManager *historyManager = new OrderHistoryManager();
    historyManager->setSavePath(historyPath);
    historyManager->loadFromCSV(historyPath);

    // ==========================================
    // 5. ĐĂNG KÝ QML CONTEXT PROPERTIES
    // ==========================================
    // Lấy đường dẫn tuyệt đối của thư mục save (cùng chỗ load CSV)
    QString savesPath = QDir(SAVE_DIR_PATH).absolutePath();
    if (!savesPath.endsWith('/'))
        savesPath += '/';

    // Đưa sang QML
    engine.rootContext()->setContextProperty("savesDir", savesPath);
    engine.rootContext()->setContextProperty("savesDirUrl", QUrl::fromLocalFile(savesPath).toString());

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

    engine.load(url);

    return app.exec();
}