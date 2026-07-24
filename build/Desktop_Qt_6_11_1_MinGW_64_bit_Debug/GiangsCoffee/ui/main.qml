import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: qsTr("Giang's Coffee - Management System")

    // =========================================================================
    // BIẾN LƯU VAI TRÒ NGƯỜI DÙNG ("Quản lý", "Nhân viên", "Khách hàng")
    // =========================================================================
    property string currentUserRole: ""

    // Bảng màu giao diện
    property color colorBackground: "#F0F9FF"
    property color colorPrimary: "#FFFFFF"
    property color colorSecondary: "#0369A1"
    property color colorText: "#333333"

    background: Rectangle {
        color: colorBackground
    }

    // =========================================================================
    // HEADER CHUNG & THANH MENU CHUYỂN TRANG
    // =========================================================================
    header: ToolBar {
        background: Rectangle {
            color: colorPrimary
            Rectangle {
                width: parent.width
                height: 1
                color: "#E0F2FE"
                anchors.bottom: parent.bottom
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 10

            // Nút Đăng xuất (Chỉ hiện khi đã vào trong các trang chức năng)
            ToolButton {
                text: qsTr("🚪 Đăng xuất")
                font.family: "Segoe UI"
                font.pixelSize: 13
                font.bold: true
                palette.buttonText: "#C62828"
                visible: stackView.depth > 1
                onClicked: {
                    window.currentUserRole = "" // Reset vai trò về rỗng
                    stackView.pop(null)         // Quay lại trang Login
                }
            }

            // Tên thương hiệu
            Label {
                text: "Giang's Coffee"
                font.family: "Segoe UI"
                font.pixelSize: 20
                font.bold: true
                color: colorSecondary
                Layout.fillWidth: stackView.depth <= 1
            }

            Item { Layout.fillWidth: true; visible: stackView.depth > 1 }

            // -----------------------------------------------------------------
            // DÃY NÚT CHUYỂN TRANG (ẨN/HIỆN THEO QUYỀN TRUY CẬP)
            // -----------------------------------------------------------------
            RowLayout {
                visible: stackView.depth > 1
                spacing: 8

                // 1. Đặt Hàng: Dành cho Nhân viên & Quản lý
                Button {
                    text: "☕ Đặt Hàng"
                    visible: window.currentUserRole === "Nhân viên" || window.currentUserRole === "Quản lý"
                    onClicked: stackView.replace("qrc:/qt/qml/GiangsCoffee/ui/OrderPage.qml")
                }

                // 2. Tài Chính: Chỉ dành cho Quản lý
                Button {
                    text: "📊 Tài Chính"
                    visible: window.currentUserRole === "Quản lý"
                    onClicked: stackView.replace("qrc:/qt/qml/GiangsCoffee/ui/FinancePage.qml")
                }

                // 3. Nhân Sự: Chỉ dành cho Quản lý
                Button {
                    text: "👥 Nhân Sự"
                    visible: window.currentUserRole === "Quản lý"
                    onClicked: stackView.replace("qrc:/qt/qml/GiangsCoffee/ui/EmployeeManagementPage.qml")
                }

                // 4. Tích Điểm: Cho cả Khách hàng, Nhân viên & Quản lý
                Button {
                    text: "🎁 Tích Điểm"
                    visible: window.currentUserRole === "Khách hàng" || window.currentUserRole === "Nhân viên" || window.currentUserRole === "Quản lý"
                    onClicked: stackView.replace("qrc:/qt/qml/GiangsCoffee/ui/LoyaltyPage.qml")
                }
            }
        }
    }

    // Trình quản lý luồng các trang
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "qrc:/qt/qml/GiangsCoffee/ui/LoginPage.qml"
    }
}