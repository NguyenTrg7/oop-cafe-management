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

    // Hàm lấy đường dẫn ảnh nền động
    function getImageSource() {
        if (typeof savesDir !== "undefined" && savesDir !== "") {
            var base = savesDir.toString().replace(/[\\\/]+$/, "")
            base = base.replace(/[\\\/]saves$/i, "")
            var path = base + "/data/themeNavigator.png"
            path = path.replace(/\\/g, "/")
            console.log("Image path:", "file:///" + path)
            return "file:///" + path
        }
        if (typeof applicationDir !== "undefined" && applicationDir !== "") {
            var p = applicationDir.toString().replace(/\\/g, "/") + "/data/themeNavigator.png"
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
        width: 260
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#96D2F5"
        visible: (isAdmin || isStaff)
        z: 100
        clip: true

        // Ảnh nền thanh điều hướng
        Image {
            anchors.fill: parent
            source: appWindow.getImageSource()
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignBottom
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Label {
                text: "☕ GIANG'S COFFEE"
                font.pixelSize: 21
                font.bold: true
                color: "#0F172A"
                style: Text.Outline
                styleColor: "#FFFFFF"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    width: parent.width - 6
                    spacing: 8

                    component MenuButton : Button {
                        id: btn
                        property string iconStr: ""
                        property string btnText: ""
                        property string targetPage: ""
                        property bool checkAccess: true

                        property bool isActive: appWindow.getBaseName(appWindow.currentActivePage) === appWindow.getBaseName(targetPage)

                        visible: checkAccess
                        Layout.fillWidth: true
                        implicitHeight: 44

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        // Khung trong suốt dạng kính (Glassmorphism)
                        background: Rectangle {
                            color: btn.isActive ? "#FFFFFF" : (btn.pressed ? "#60FFFFFF" : (btn.hovered ? "#40FFFFFF" : "#25FFFFFF"))
                            radius: 10
                            border.color: btn.isActive ? "#0284C7" : (btn.hovered ? "#FFFFFF" : "#80FFFFFF")
                            border.width: btn.isActive ? 2 : 1
                        }

                        contentItem: RowLayout {
                            spacing: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 12

                            Text {
                                text: btn.iconStr
                                font.pixelSize: 18
                            }
                            Text {
                                text: btn.btnText
                                font.pixelSize: 15
                                font.bold: true
                                color: btn.isActive ? "#0369A1" : "#0F172A"
                                style: btn.isActive ? Text.Normal : Text.Outline
                                styleColor: "#FFFFFF"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        onClicked: {
                            if (targetPage !== "") {
                                appWindow.switchPage(targetPage)
                            }
                        }
                    }

                    MenuButton { iconStr: "🏠"; btnText: "Trang Chủ Quản Lý"; targetPage: "ManagerPage.qml"; checkAccess: isAdmin }
                    MenuButton { iconStr: "🕒"; btnText: "Điểm Danh Ca Làm"; targetPage: "EmployeePage.qml"; checkAccess: isStaff && !isAdmin }
                    MenuButton { iconStr: "🛒"; btnText: "Bán Hàng"; targetPage: "OrderPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "📦"; btnText: "Quản Lý Kho Hàng"; targetPage: "InventoryPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "📜"; btnText: "Lịch Sử Đơn Hàng"; targetPage: "OrderHistoryPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "🪑"; btnText: "Sơ Đồ Bàn"; targetPage: "SeatingPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "🎁"; btnText: "Tích điểm"; targetPage: "LoyaltyPage.qml"; checkAccess: isAdmin || isStaff }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#90FFFFFF"; Layout.topMargin: 6; Layout.bottomMargin: 6; visible: isAdmin }

                    MenuButton { iconStr: "🔐"; btnText: "Quản Lý Nhân Sự"; targetPage: "EmployeeManagementPage.qml"; checkAccess: isAdmin }
                    MenuButton { iconStr: "📋"; btnText: "Báo Cáo Điểm Danh"; targetPage: "AttendanceReportPage.qml"; checkAccess: isAdmin }
                    MenuButton { iconStr: "📈"; btnText: "Quản Lý Tài Chính"; targetPage: "FinancePage.qml"; checkAccess: isAdmin }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#90FFFFFF"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

                    Button {
                        Layout.fillWidth: true
                        implicitHeight: 44

                        HoverHandler { cursorShape: Qt.PointingHandCursor }

                        background: Rectangle { color: parent.pressed ? "#B91C1C" : "#DC2626"; radius: 10 }

                        contentItem: Text {
                            text: "🚪 Đăng xuất";
                            color: "white";
                            font.bold: true;
                            font.pixelSize: 15;
                            horizontalAlignment: Text.AlignHCenter;
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: logoutDialog.open()
                    }
                }
            }
        }
    }

    Dialog {
        id: logoutDialog
        width: Math.min(320, parent.width * 0.9)
        height: 160
        modal: true
        anchors.centerIn: parent
        title: "Xác nhận"

        background: Rectangle { color: "#FFFFFF"; radius: 12; border.color: "#E2E8F0" }
        header: Item { height: 40; Text { text: "Xác nhận đăng xuất"; font.bold: true; font.pixelSize: 16; color: "#1E293B"; anchors.centerIn: parent } }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 10; spacing: 20
            Text { text: "Bạn có chắc chắn muốn đăng xuất?"; font.pixelSize: 14; color: "#475569"; Layout.alignment: Qt.AlignHCenter }

            RowLayout {
                Layout.fillWidth: true; spacing: 15
                Button {
                    text: "Không"; Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { color: "#F1F5F9"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "#1E293B"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: logoutDialog.close()
                }
                Button {
                    text: "Có, đăng xuất"; Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { color: "#DC2626"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
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