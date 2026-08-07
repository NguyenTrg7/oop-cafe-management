import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    title: qsTr("Giang's Coffee - Management System")

    property color colorBackground: "#F8FAFC"
    property color colorPrimary: "#0369A1"
    property color colorText: "#1E293B"

    property string currentActivePage: "OrderPage.qml"
    property var pageCache: ({})

    background: Rectangle { color: colorBackground }

    property bool isAdmin: typeof accountHandler !== "undefined" && accountHandler !== null && accountHandler.currentUserPhone === "admin"
    property bool isStaff: typeof accountHandler !== "undefined" && accountHandler !== null && accountHandler.currentUserPhone !== "admin" && accountHandler.currentUserPhone !== ""

    function getImageSource() {
        if (typeof savesDir !== "undefined" && savesDir !== "") {
            var base = savesDir.toString().replace(/[\\\/]+$/, "")
            base = base.replace(/[\\\/]saves$/i, "")
            var path = base + "/data/catBG.png"
            path = path.replace(/\\/g, "/")
            return "file:///" + path
        }
        if (typeof applicationDir !== "undefined" && applicationDir !== "") {
            var p = applicationDir.toString().replace(/\\/g, "/") + "/data/catBG.png"
            return "file:///" + p
        }
        return ""
    }

    function getBaseName(url) {
        if (!url) return "";
        var str = url.toString();
        var parts = str.split("/");
        return parts[parts.length - 1];
    }

    function updateNavigation(pageUrl, pageTitle) {
        currentActivePage = pageUrl;
        if (pageTitle && pageTitle !== "") {
            appWindow.title = "Giang's Coffee - " + pageTitle;
        } else {
            appWindow.title = "Giang's Coffee - Management System";
        }
    }

    StackView {
        id: stackView
        anchors.left: (isAdmin || isStaff) ? sideBar.right : parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        initialItem: "LoginPage.qml"
    }

    function switchPage(pageUrl) {
        if (getBaseName(currentActivePage) === getBaseName(pageUrl)) return;

        if (pageUrl === "LoginPage.qml") {
            currentActivePage = "";
            for (var key in pageCache) {
                if (pageCache[key]) {
                    pageCache[key].destroy();
                }
            }
            pageCache = {};
            stackView.replace(null, pageUrl, StackView.Immediate);
            appWindow.title = "Giang's Coffee - Đăng nhập";
            return;
        }

        currentActivePage = pageUrl;

        if (!pageCache[pageUrl]) {
            var component = Qt.createComponent(pageUrl);
            if (component.status === Component.Ready) {
                pageCache[pageUrl] = component.createObject(appWindow);
            } else if (component.status === Component.Error) {
                console.error("Lỗi tải trang: " + component.errorString());
                return;
            }
        }

        var targetItem = pageCache[pageUrl];
        stackView.replace(null, targetItem, StackView.Immediate);

        if (typeof targetItem.title !== "undefined" && targetItem.title !== "") {
            appWindow.title = "Giang's Coffee - " + targetItem.title;
        } else {
            appWindow.title = "Giang's Coffee - Management System";
        }

        if (typeof targetItem.refreshData === "function") {
            targetItem.refreshData();
        }
        if (typeof targetItem.refreshStats === "function") {
            targetItem.refreshStats();
        }
    }

    // ---------------------------------------------------
    // SIDEBAR NAVIGATION
    // ---------------------------------------------------
    Rectangle {
        id: sideBar
        width: Math.max(220, Math.min(280, appWindow.width * 0.20))
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#96D2F5"
        visible: (isAdmin || isStaff)
        z: 100
        clip: true

        Image {
            anchors.fill: parent
            source: appWindow.getImageSource()
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignBottom
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.max(6, sideBar.width * 0.04)
            spacing: Math.max(4, sideBar.height * 0.008)

            Label {
                text: "☕ GIANG'S COFFEE"
                font.pixelSize: Math.max(15, Math.min(19, sideBar.width * 0.07))
                font.bold: true
                color: "#0F172A"
                style: Text.Outline
                styleColor: "#FFFFFF"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            component MenuButton : Button {
                id: btn
                property string iconStr: ""
                property string btnText: ""
                property string targetPage: ""
                property bool checkAccess: true
                property bool alignRight: false

                property bool isActive: appWindow.getBaseName(appWindow.currentActivePage) === appWindow.getBaseName(targetPage)

                visible: checkAccess
                hoverEnabled: true

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 30
                Layout.maximumHeight: 46

                Layout.leftMargin: btn.alignRight ? (sideBar.width * 0.236) : (sideBar.width * 0.02)
                Layout.rightMargin: !btn.alignRight ? (sideBar.width * 0.205) : (sideBar.width * 0.02)

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                background: Rectangle {
                    radius: 10
                    clip: true
                    color: btn.isActive ? "#FFFFFF" : (btn.pressed ? "#70FFFFFF" : (btn.hovered ? "#45FFFFFF" : "#20FFFFFF"))
                    border.color: btn.isActive ? "#0284C7" : (btn.hovered ? "#FFFFFF" : "#80FFFFFF")
                    border.width: btn.isActive ? 2 : 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                contentItem: RowLayout {
                    anchors.fill: parent
                    spacing: 6

                    Item { Layout.fillWidth: true }

                    Text {
                        text: btn.iconStr
                        font.pixelSize: Math.max(12, Math.min(16, btn.height * 0.42))
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: btn.btnText
                        font.pixelSize: Math.max(11, Math.min(14, btn.height * 0.36))
                        font.bold: true
                        color: btn.isActive ? "#0369A1" : "#0F172A"
                        style: btn.isActive ? Text.Normal : Text.Outline
                        styleColor: "#FFFFFF"
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }
                }

                onClicked: {
                    if (targetPage !== "") {
                        appWindow.switchPage(targetPage)
                    }
                }
            }

            // 🔴 TRANG CHỦ: Mở cho cả Admin & Nhân viên (Admin -> ManagerPage.qml, Staff -> EmployeePage.qml)
            MenuButton {
                iconStr: "🏠"
                btnText: "Trang Chủ"
                targetPage: isAdmin ? "ManagerPage.qml" : "EmployeePage.qml"
                checkAccess: isAdmin || isStaff
                alignRight: false
            }

            MenuButton { iconStr: "🛒"; btnText: "Bán Hàng"; targetPage: "OrderPage.qml"; checkAccess: isAdmin || isStaff; alignRight: false }
            MenuButton { iconStr: "📦"; btnText: "Quản Lý Kho Hàng"; targetPage: "InventoryPage.qml"; checkAccess: isAdmin || isStaff; alignRight: false }
            MenuButton { iconStr: "🚚"; btnText: "Nhà Cung Cấp"; targetPage: "SupplierPage.qml"; checkAccess: isAdmin || isStaff; alignRight: false }
            MenuButton { iconStr: "📜"; btnText: "Lịch Sử Đơn Hàng"; targetPage: "OrderHistoryPage.qml"; checkAccess: isAdmin || isStaff; alignRight: !isAdmin }

            // Nhóm dưới: Né mèo bên trái
            MenuButton { iconStr: "🪑"; btnText: "Sơ Đồ Bàn"; targetPage: "SeatingPage.qml"; checkAccess: isAdmin || isStaff; alignRight: true }
            MenuButton { iconStr: "🎁"; btnText: "Tích điểm"; targetPage: "LoyaltyPage.qml"; checkAccess: isAdmin || isStaff; alignRight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#60FFFFFF"
                visible: isAdmin
            }

            MenuButton { btnText: "Quản Lý Nhân Sự"; iconStr: "🔐"; targetPage: "EmployeeManagementPage.qml"; checkAccess: isAdmin; alignRight: true }
            MenuButton { btnText: "Báo Cáo Điểm Danh"; iconStr: "📋"; targetPage: "AttendanceReportPage.qml"; checkAccess: isAdmin; alignRight: true }
            MenuButton { btnText: "Quản Lý Tài Chính"; iconStr: "📈"; targetPage: "FinancePage.qml"; checkAccess: isAdmin; alignRight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#60FFFFFF"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.leftMargin: sideBar.width * 0.236
                Layout.rightMargin: sideBar.width * 0.02
                hoverEnabled: true

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                background: Rectangle {
                    radius: 10
                    clip: true
                    color: parent.pressed ? "#B91C1C" : (parent.hovered ? "#EF4444" : "#DC2626")
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                contentItem: Text {
                    text: "🚪 Đăng xuất"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: logoutDialog.open()
            }
        }
    }

    // Dialog Xác nhận đăng xuất
    Dialog {
        id: logoutDialog
        width: Math.min(320, parent.width * 0.9)
        height: 170
        modal: true
        anchors.centerIn: parent

        background: Rectangle { color: "#FFFFFF"; radius: 12; border.color: "#E2E8F0" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: "Xác nhận đăng xuất"
                font.bold: true
                font.pixelSize: 16
                color: "#1E293B"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Bạn có chắc chắn muốn đăng xuất?"
                font.pixelSize: 14
                color: "#475569"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: "Không"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#F1F5F9"; radius: 6 }
                    contentItem: Text {
                        text: parent.text
                        color: "#1E293B"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: logoutDialog.close()
                }

                Button {
                    text: "Có, đăng xuất"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#DC2626"; radius: 6 }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        logoutDialog.close()
                        if (typeof accountHandler !== "undefined" && accountHandler !== null) {
                            accountHandler.currentUserPhone = ""
                        }
                        appWindow.switchPage("LoginPage.qml")
                    }
                }
            }
        }
    }
}