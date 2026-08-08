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
#include "GiangCoffeeSystem.h"
#include "IngredientManager.h"
#include "OrderHistoryManager.h"
#include "SupplierManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    std::cout << "========================================================\n";
    std::cout << "            HE THONG QUAN LY GIANG COFFEE v1.0            \n";
    std::cout << "   Du an phat trien boi Nhom 3: Nguyen, Quang, Thanh, Giang, Khuong\n";
    std::cout << "========================================================\n";

    QQmlApplicationEngine engine;

    // Xử lý tài khoản, khách hàng và nhân viên
    Account accountHandler;
    Customer customerHandler;

    accountHandler.setCustomerHandler(&customerHandler);
    EmployeeModel employeeModel(&accountHandler);

    // Xử lý menu
    GiangCoffeeSystem *systemInstance = GiangCoffeeSystem::getInstance();

    QString drinkPath = GiangCoffeeSystem::getSaveFilePath("drink.csv");
    QString foodPath  = GiangCoffeeSystem::getSaveFilePath("food.csv");

    // Nạp dữ liệu từ csv trong thư mục saves
    systemInstance->getMenuManager()->loadDrinksCSV(drinkPath);
    systemInstance->getMenuManager()->loadFoodsCSV(foodPath);

    // Xử lý nguyên liệu tồn kho
    IngredientManager ingManager;
    systemInstance->getMenuManager()->setIngredientManager(&ingManager);

    QString drinkIngPath = GiangCoffeeSystem::getSaveFilePath("IngredientDrink.csv");
    QString foodIngPath  = GiangCoffeeSystem::getSaveFilePath("IngredientFood.csv");
    QString recipesPath  = GiangCoffeeSystem::getSaveFilePath("Recipes.csv");

    ingManager.loadIngredientsCSV(drinkIngPath, true);
    ingManager.loadIngredientsCSV(foodIngPath, false);
    ingManager.loadRecipesCSV(recipesPath);
    ingManager.setPaths(drinkIngPath, foodIngPath);

    // Xử lý lịch sử đơn hàng
    QString historyPath = GiangCoffeeSystem::getSaveFilePath("OrderHistory.csv");
    OrderHistoryManager *historyManager = new OrderHistoryManager();
    historyManager->setSavePath(historyPath);
    historyManager->loadFromCSV(historyPath);

    // Xử lý nhà cung cấp
    SupplierManager supplierManager;

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
    engine.rootContext()->setContextProperty("supplierManager", &supplierManager);
    engine.rootContext()->setContextProperty("applicationDir", QCoreApplication::applicationDirPath());

    // Load QML chính
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