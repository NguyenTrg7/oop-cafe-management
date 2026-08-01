import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1180
    height: 760
    minimumWidth: 1024
    minimumHeight: 700
    title: qsTr("Giang's Coffee - Management System")

    property color colorBackground: "#F8FAFC"
    property color colorPrimary: "#0369A1"
    property color colorText: "#1E293B"

    // Biến lưu trạng thái trang hiện tại để làm sáng Menu
    property string currentActivePage: ""

    background: Rectangle { color: colorBackground }

    // Biến kiểm tra quyền truy cập (Dựa vào số điện thoại đăng nhập)
    property bool isAdmin: typeof accountHandler !== "undefined" && accountHandler.currentUserPhone === "admin"
    property bool isStaff: typeof accountHandler !== "undefined" && accountHandler.currentUserPhone !== "admin" && accountHandler.currentUserPhone !== ""

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "LoginPage.qml"
    }

    // ---------------------------------------------------
    // KHU VỰC BẮT SỰ KIỆN RÊ CHUỘT Ở MÉP (CỐ ĐỊNH 15px)
    // ---------------------------------------------------
    MouseArea {
        id: edgeHoverArea
        width: 15
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        hoverEnabled: true
        // ĐÃ SỬA: Hiển thị nếu đã đăng nhập thành công (thay vì dựa vào độ sâu của stack)
        visible: (isAdmin || isStaff)
        z: 99
    }

    // ---------------------------------------------------
    // SIDEBAR - THANH ĐIỀU HƯỚNG BÊN TRÁI
    // ---------------------------------------------------
    Rectangle {
        id: sideBar
        width: 260
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        HoverHandler {
            id: sideBarHover
        }

        // ĐÃ SỬA: Xử lý hoạt ảnh trượt mượt mà dựa vào trạng thái đăng nhập
        x: (edgeHoverArea.containsMouse || sideBarHover.hovered) && (isAdmin || isStaff) ? 0 : -width
        color: colorPrimary
        visible: (isAdmin || isStaff)
        z: 100

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            // Tiêu đề Sidebar
            Label {
                text: "☕ GIANG'S COFFEE"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                Layout.bottomMargin: 20
            }

            // Danh sách các Menu
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 8

                    // Component nút bấm dùng chung
                    component MenuButton : Button {
                        property string iconStr: ""
                        property string btnText: ""
                        property string targetPage: ""
                        property bool checkAccess: true

                        // Kiểm tra xem nút này có đang là trang hiện tại không
                        property bool isActive: appWindow.currentActivePage === targetPage

                        visible: checkAccess
                        Layout.fillWidth: true
                        implicitHeight: 45

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            // Nếu đang Active -> Màu sáng đậm (#0284C7). Ngược lại xét theo Hover/Pressed
                            color: parent.isActive ? "#0284C7" : (parent.pressed ? "#0369A1" : (parent.hovered ? "#38BDF8" : "transparent"))
                            radius: 8
                            // Thêm viền trắng mờ để nút Active nổi bật hẳn lên
                            border.color: parent.isActive ? "#7DD3FC" : "transparent"
                            border.width: parent.isActive ? 1 : 0
                        }

                        contentItem: RowLayout {
                            spacing: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            Text { text: parent.parent.iconStr; font.pixelSize: 18; color: "white" }
                            Text {
                                text: parent.parent.btnText;
                                font.pixelSize: 15;
                                font.bold: true;
                                color: "white";
                                Layout.fillWidth: true
                            }
                        }

                        onClicked: {
                            if (targetPage !== "") {
                                appWindow.currentActivePage = targetPage
                                // Dọn dẹp stack rác và chuyển trang
                                stackView.replace(null, targetPage)
                            }
                        }
                    }

                    // ---------- PHÂN QUYỀN MENU CHUNG ----------
                    MenuButton {
                        iconStr: "🏠"
                        btnText: "Trang Chủ Quản Lý"
                        targetPage: "ManagerPage.qml"
                        checkAccess: isAdmin
                    }

                    MenuButton {
                        iconStr: "🕒"
                        btnText: "Điểm Danh Ca Làm"
                        targetPage: "EmployeePage.qml"
                        checkAccess: isStaff && !isAdmin
                    }

                    MenuButton {
                        iconStr: "🛒"
                        btnText: "Bán Hàng (Order)"
                        targetPage: "OrderPage.qml"
                        checkAccess: isAdmin || isStaff
                    }

                    MenuButton {
                        iconStr: "🪑"
                        btnText: "Sơ Đồ Bàn"
                        targetPage: "SeatingPage.qml"
                        checkAccess: isAdmin || isStaff
                    }

                    MenuButton {
                        iconStr: "🎁"
                        btnText: "Loyalty (Tích điểm)"
                        targetPage: "LoyaltyPage.qml"
                        checkAccess: isAdmin || isStaff
                    }

                    // ---------- MENU DÀNH RIÊNG CHO QUẢN LÝ ----------
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#38BDF8"
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        visible: isAdmin
                    }

                    MenuButton {
                        iconStr: "👥"
                        btnText: "Quản Lý Nhân Viên"
                        targetPage: "EmployeeManagementPage.qml"
                        checkAccess: isAdmin
                    }

                    MenuButton {
                        iconStr: "📈"
                        btnText: "Quản Lý Tài Chính"
                        targetPage: "FinancePage.qml"
                        checkAccess: isAdmin
                    }
                }
            }

            // Đẩy phần đăng xuất xuống dưới cùng
            Item { Layout.fillHeight: true }

            // Nút đăng xuất
            Button {
                Layout.fillWidth: true
                implicitHeight: 45

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                background: Rectangle {
                    color: parent.pressed ? "#B91C1C" : "#DC2626"
                    radius: 8
                }

                contentItem: Text {
                    text: "🚪 Đăng xuất"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: logoutDialog.open()
            }
        }
    }

    // ---------------------------------------------------
    // POPUP XÁC NHẬN ĐĂNG XUẤT
    // ---------------------------------------------------
    Dialog {
        id: logoutDialog
        width: 320
        height: 160
        modal: true
        anchors.centerIn: parent
        title: "Xác nhận"

        background: Rectangle {
            color: "#FFFFFF"
            radius: 12
            border.color: "#E2E8F0"
        }

        header: Item {
            height: 40
            Text {
                text: "Xác nhận đăng xuất"
                font.bold: true
                font.pixelSize: 16
                color: "#1E293B"
                anchors.centerIn: parent
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20

            Text {
                text: "Bạn có chắc chắn muốn đăng xuất?"
                font.pixelSize: 14
                color: "#475569"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Button {
                    text: "Không"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#F1F5F9"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "#1E293B"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: logoutDialog.close()
                }

                Button {
                    text: "Có, đăng xuất"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#DC2626"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        logoutDialog.close()

                        // Reset lại trang Active khi đăng xuất
                        appWindow.currentActivePage = ""

                        if (typeof accountHandler !== "undefined") {
                            accountHandler.currentUserPhone = ""
                        }
                        stackView.replace(null, "LoginPage.qml")
                    }
                }
            }
        }
    }
}