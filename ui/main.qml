import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    minimumWidth: 1024
    minimumHeight: 700
    title: qsTr("Giang's Coffee - Management System")

    property color colorBackground: "#F8FAFC"
    property color colorPrimary: "#0369A1"
    property color colorText: "#1E293B"

    property string currentActivePage: "OrderPage.qml"
    property bool sidebarPinned: false

    property var pageCache: ({})

    background: Rectangle { color: colorBackground }

    // Đã kiểm tra null an toàn cho accountHandler
    property bool isAdmin: typeof accountHandler !== "undefined" && accountHandler !== null && accountHandler.currentUserPhone === "admin"
    property bool isStaff: typeof accountHandler !== "undefined" && accountHandler !== null && accountHandler.currentUserPhone !== "admin" && accountHandler.currentUserPhone !== ""

    function getBaseName(url) {
        if (!url) return "";
        var str = url.toString();
        var parts = str.split("/");
        return parts[parts.length - 1];
    }

    // Đồng bộ trạng thái Sidebar Nav & Title khi sub-tab hoặc trang con thay đổi
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
        anchors.fill: parent
        initialItem: "LoginPage.qml"
    }

    // =========================================================================
    // HÀM CHUYỂN TRANG TỐI ƯU HIỆU NĂNG & ĐỒNG BỘ TRẠNG THÁI NAV BAR
    // =========================================================================
    function switchPage(pageUrl) {
        if (getBaseName(currentActivePage) === getBaseName(pageUrl)) return;

        if (pageUrl === "LoginPage.qml") {
            sidebarPinned = false;
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

        // ĐỒNG BỘ: Cập nhật tiêu đề cửa sổ dựa trên title của trang đang active
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

    MouseArea {
        id: edgeHoverArea
        width: 10
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        hoverEnabled: true
        visible: (isAdmin || isStaff)
        enabled: (isAdmin || isStaff)
        z: 99
    }

    // ---------------------------------------------------
    // SIDEBAR NAVIGATION (Đã tích hợp ScrollView chứa cả nút Đăng xuất)
    // ---------------------------------------------------
    Rectangle {
        id: sideBar
        width: 260
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        HoverHandler {
            id: sideBarHover
            enabled: (isAdmin || isStaff)
        }

        x: (sidebarPinned || edgeHoverArea.containsMouse || sideBarHover.hovered || toggleBtnHover.hovered) && (isAdmin || isStaff) ? 0 : -width
        color: colorPrimary
        visible: (isAdmin || isStaff)
        z: 100

        Behavior on x {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuart }
        }

        Rectangle {
            id: toggleHandle
            width: 32
            height: 60
            color: colorPrimary
            radius: 8
            anchors.left: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: (isAdmin || isStaff)

            Rectangle {
                width: 16
                height: 60
                color: colorPrimary
                anchors.left: parent.left
            }

            HoverHandler {
                id: toggleBtnHover
                cursorShape: Qt.PointingHandCursor
                enabled: (isAdmin || isStaff)
            }

            Text {
                anchors.centerIn: parent
                text: sideBar.x === 0 ? "◀" : "▶"
                color: "#FFFFFF"
                font.bold: true
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: (isAdmin || isStaff)
                onClicked: sidebarPinned = !sidebarPinned
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Label {
                text: "☕ GIANG'S COFFEE"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }

            // Vùng chứa tất cả menu + nút Đăng xuất (Tự động cuộn khi cửa sổ thu nhỏ height)
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    width: parent.width - 6
                    spacing: 8

                    component MenuButton : Button {
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

                        background: Rectangle {
                            color: parent.isActive ? "#0284C7" : (parent.pressed ? "#0369A1" : (parent.hovered ? "#38BDF8" : "transparent"))
                            radius: 8
                            border.color: parent.isActive ? "#7DD3FC" : "transparent"
                            border.width: parent.isActive ? 1 : 0
                        }

                        contentItem: RowLayout {
                            spacing: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            Text { text: parent.parent.iconStr; font.pixelSize: 18; color: "white" }
                            Text {
                                text: parent.parent.btnText
                                font.pixelSize: 15
                                font.bold: true
                                color: "white"
                                Layout.fillWidth: true
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
                    MenuButton { iconStr: "🛒"; btnText: "Bán Hàng (Order)"; targetPage: "OrderPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "📦"; btnText: "Quản Lý Kho Hàng"; targetPage: "InventoryPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "📜"; btnText: "Lịch Sử Đơn Hàng"; targetPage: "OrderHistoryPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "🪑"; btnText: "Sơ Đồ Bàn"; targetPage: "SeatingPage.qml"; checkAccess: isAdmin || isStaff }
                    MenuButton { iconStr: "🎁"; btnText: "Loyalty (Tích điểm)"; targetPage: "LoyaltyPage.qml"; checkAccess: isAdmin || isStaff }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#38BDF8"; Layout.topMargin: 6; Layout.bottomMargin: 6; visible: isAdmin }

                    MenuButton { iconStr: "🔐"; btnText: "Quản Lý Nhân Sự"; targetPage: "EmployeeManagementPage.qml"; checkAccess: isAdmin }
                    MenuButton { iconStr: "📋"; btnText: "Báo Cáo Điểm Danh"; targetPage: "AttendanceReportPage.qml"; checkAccess: isAdmin }
                    MenuButton { iconStr: "📈"; btnText: "Quản Lý Tài Chính"; targetPage: "FinancePage.qml"; checkAccess: isAdmin }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#38BDF8"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

                    // Nút Đăng xuất đưa vào đây để luôn cuộn tới được khi màn hình nhỏ
                    Button {
                        Layout.fillWidth: true
                        implicitHeight: 44

                        HoverHandler { cursorShape: Qt.PointingHandCursor }

                        background: Rectangle { color: parent.pressed ? "#B91C1C" : "#DC2626"; radius: 8 }

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
        width: 320
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