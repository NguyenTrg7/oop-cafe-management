cmake_minimum_required(VERSION 3.16)

project(GiangsCoffee VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Sql)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

# =============================================================================
# DANH SÁCH FILE DỰ ÁN HOÀN CHỈNH
# =============================================================================

# 1. Mục Header: Định nghĩa các class (.h)
set(HEADER_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/include/User.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Customer.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Employee.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Order.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/InStoreOrder.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/DeliverOrder.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/GiangCoffeeSystem.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Menu.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Ingredient.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Supplier.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Seating.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Account.h"
)

# 2. Mục Logic: Triển khai mã nguồn (.cpp)
set(LOGIC_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/User.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Customer.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Employee.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Order.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/InStoreOrder.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/DeliverOrder.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/GiangCoffeeSystem.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Menu.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Ingredient.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Supplier.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Seating.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Account.cpp"
)

# 3. Mục UI: Các file giao diện QML
set(UI_FILES
    "ui/main.qml"
    "ui/OrderPage.qml"
    "ui/LoyaltyPage.qml"
    "ui/LoginPage.qml"
    "ui/FinancePage.qml"
    "ui/EmployeeManagementPage.qml"
)

# =============================================================================
# PHÂN NHÓM HIỂN THỊ TRONG QT CREATOR
# =============================================================================
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
    Qt6::Sql
)

# Tự động tạo thư mục data trong build nếu chưa có
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/data")

# Chỉ copy nếu thư mục data ở source tồn tại
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/data")
    file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/data/" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/data")
endif()