cmake_minimum_required(VERSION 3.16)

project(GiangsCoffee VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

# =============================================================================
# DANH SÁCH FILE DỰ ÁN HOÀN CHỈNH
# =============================================================================

set(HEADER_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/include/User.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Customer.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Employee.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/EmployeeModel.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Order.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/GiangCoffeeSystem.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Menu.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Ingredient.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Supplier.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/SupplierManager.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Seating.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Account.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/MenuManager.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/IngredientManager.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/OrderHistoryItem.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/OrderHistoryManager.h"
)

set(LOGIC_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/User.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Customer.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Employee.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/EmployeeModel.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Order.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/GiangCoffeeSystem.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Menu.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Ingredient.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Supplier.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/SupplierManager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Seating.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Account.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/MenuManager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/IngredientManager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/OrderHistoryManager.cpp"
)

set(UI_FILES
    "ui/main.qml"
    "ui/OrderPage.qml"
    "ui/LoyaltyPage.qml"
    "ui/LoginPage.qml"
    "ui/ManagerPage.qml"
    "ui/EmployeePage.qml"
    "ui/EmployeeManagementPage.qml"
    "ui/FinancePage.qml"
    "ui/SeatingPage.qml"
    "ui/InventoryPage.qml"
    "ui/InvoiceDialog.qml"
    "ui/AttendanceReportPage.qml"
    "ui/OrderHistoryPage.qml"
    "ui/SupplierPage.qml"
)

# Phân nhóm file hiển thị trên Tree structure của IDE (Visual Studio / CLion / Qt Creator)
source_group("Mục Header (Headers)" FILES ${HEADER_FILES})
source_group("Mục Logic (Sources)" FILES ${LOGIC_FILES})
source_group("Mục UI (QML)" FILES ${UI_FILES})

# =============================================================================
# CẤU HÌNH BUILD
# =============================================================================

qt_add_executable(GiangsCoffee
    ${LOGIC_FILES}
    ${HEADER_FILES}
)

qt_add_qml_module(GiangsCoffee
    URI GiangsCoffee
    VERSION 1.0
    QML_FILES ${UI_FILES}
)

target_include_directories(GiangsCoffee PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_link_libraries(GiangsCoffee PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
)

# =============================================================================
# CẤU HÌNH THƯ MỤC LƯU TRỮ (SAVE)
# =============================================================================

# 1. Định nghĩa thư mục saves và data nằm trong thư mục dự án gốc
set(SAVE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/saves")
set(DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/data")

# 2. Chuẩn hóa đường dẫn thành dạng Unix '/' để tránh lỗi escape character dấu '\' trên Windows
file(TO_CMAKE_PATH "${SAVE_DIR}" SAVE_DIR_CLEAN)
file(TO_CMAKE_PATH "${DATA_DIR}" DATA_DIR_CLEAN)

# 3. Truyền đường dẫn đã chuẩn hóa vào C++ dưới dạng Macro chuỗi
target_compile_definitions(GiangsCoffee PRIVATE
    SAVE_DIR_PATH="${SAVE_DIR_CLEAN}"
    DATA_DIR_PATH="${DATA_DIR_CLEAN}"
)
# 4. Tự động tạo thư mục saves (nếu chưa có) và copy LẦN LƯỢT các file/folder từ data/
# (Nếu saves đã có nhưng thiếu file/folder gốc nào đó, nó sẽ tự động copy bù vào mà không ghi đè file cũ)
if(NOT EXISTS "${SAVE_DIR_CLEAN}")
    file(MAKE_DIRECTORY "${SAVE_DIR_CLEAN}")
    message(STATUS "Created directory: ${SAVE_DIR_CLEAN}")
endif()

if(EXISTS "${DATA_DIR}")
    file(GLOB DATA_ITEMS "${DATA_DIR}/*")

    foreach(ITEM ${DATA_ITEMS})
        get_filename_component(ITEM_NAME "${ITEM}" NAME)
        set(DEST_ITEM "${SAVE_DIR_CLEAN}/${ITEM_NAME}")

        # Nếu file/folder chưa tồn tại trong saves/, copy từ data/ sang
        if(NOT EXISTS "${DEST_ITEM}")
            message(STATUS "Copying original data: ${ITEM_NAME} -> saves/")
            file(COPY "${ITEM}" DESTINATION "${SAVE_DIR_CLEAN}")
        endif()
    endforeach()
endif()