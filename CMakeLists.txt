cmake_minimum_required(VERSION 3.16)

project(GiangsCoffee VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

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
    "${CMAKE_CURRENT_SOURCE_DIR}/include/InStoreOrder.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/DeliverOrder.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/GiangCoffeeSystem.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Menu.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Ingredient.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Supplier.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Seating.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/Account.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/MenuManager.h"
)

set(LOGIC_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/User.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Customer.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Employee.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/EmployeeModel.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Order.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/InStoreOrder.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/DeliverOrder.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/GiangCoffeeSystem.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Menu.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Ingredient.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Supplier.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Seating.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Account.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/MenuManager.cpp"
)

# Đã thêm ui/AttendanceReportPage.qml vào danh sách
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
    "ui/AttendanceReportPage.qml"
)

source_group("Mục Header (Headers)" FILES ${HEADER_FILES})
source_group("Mục Logic (Sources)" FILES ${LOGIC_FILES})

# Cập nhật đường dẫn tuyệt đối cho IDE hiển thị thư mục
source_group("Mục UI (QML)" FILES
    ${UI_FILES}
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/main.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/OrderPage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/LoyaltyPage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/LoginPage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/ManagerPage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/EmployeePage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/EmployeeManagementPage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/FinancePage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/SeatingPage.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/AttendanceReportPage.qml"
)

# =============================================================================
# CẤU HÌNH BUILD
# =============================================================================
qt_add_executable(GiangsCoffee
    ${LOGIC_FILES}
    ${HEADER_FILES}
)

# Truyền trực tiếp list ${UI_FILES} để tránh trùng lặp thủ công
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
)


# =============================================================================
# ĐỒNG BỘ 2 CHIỀU THƯ MỤC DATA (TẠO SYMLINK / JUNCTION NGUYÊN BẢN)
# =============================================================================

# 1. Tự động tạo folder data nguồn nếu chưa có
file(MAKE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data")

# 2. Xóa folder data cũ trong build (nếu có) và tạo liên kết trực tiếp
add_custom_command(TARGET GiangsCoffee POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/data"
    COMMAND ${CMAKE_COMMAND} -E create_symlink
        "${CMAKE_CURRENT_SOURCE_DIR}/data"
        "${CMAKE_CURRENT_BINARY_DIR}/data"
    COMMENT "Dang tao lien ket 2 chieu cho thu muc data..."
    VERBATIM
)