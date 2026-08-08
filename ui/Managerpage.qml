import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: managerPage
    title: "Trung Tâm Quản Lý"
    background: Rectangle { color: "#F8FAFC" }

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("ManagerPage.qml", "Trung Tâm Quản Lý")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("ManagerPage.qml", "Trung Tâm Quản Lý")
            if (win.pageTitle !== undefined) win.pageTitle = "Trung Tâm Quản Lý"
        }
    }

    StackView.onActivating: {
        syncNavBar()
        refreshStats() // Tự động làm mới số liệu khi mở lại trang
    }

    property string totalRevenueText: "0 VNĐ"
    property string totalEmpText: "0"

    Component.onCompleted: {
        syncNavBar()
        refreshStats()
    }

    function refreshStats() {
        var rev = 0;

        // Tổng Thu từ giao dịch thủ công finance.csv
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadFinance) {
            var dataFinance = coffeeSystem.loadFinance()
            if (dataFinance) {
                for (var i = 0; i < dataFinance.length; i++) {
                    if (dataFinance[i].type === "Thu") {
                        rev += Number(dataFinance[i].amount)
                    }
                }
            }
        }

        // Tổng hóa đơn từ Lịch sử bán hàng OrderHistory.csv
        if (typeof orderHistoryManager !== "undefined") {
            var orders = orderHistoryManager.getHistory();
            if (orders) {
                for (var j = 0; j < orders.length; j++) {
                    rev += Number(orders[j].totalAmount);
                }
            }
        }

        totalRevenueText = Number(rev).toLocaleString(Qt.locale("vi_VN")) + " VNĐ"

        // Cập nhật số lượng nhân sự
        var empCount = 0;
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
            var empData = coffeeSystem.loadEmployees()
            if (empData) {
                empCount = empData.length
            }
        }
        totalEmpText = empCount + " Nhân sự"
    }

    function openPage(pageUrl) {
        if (typeof appWindow !== "undefined" && typeof appWindow.switchPage === "function") {
            appWindow.switchPage(pageUrl);
        } else if (ApplicationWindow.window && typeof ApplicationWindow.window.switchPage === "function") {
            ApplicationWindow.window.switchPage(pageUrl);
        } else if (StackView.view) {
            StackView.view.push(pageUrl);
        } else {
            console.log("Lỗi: Không tìm thấy hàm chuyển trang cho", pageUrl);
        }
    }

    // Nút bấm Dashboard
    component DashboardButton: Button {
        id: control
        property string iconText: "📦"
        property string titleText: "Tiêu đề"
        property string descText: "Mô tả chức năng"

        Layout.fillWidth: true
        Layout.preferredWidth: 0
        Layout.preferredHeight: 85
        leftPadding: 16
        rightPadding: 16
        topPadding: 12
        bottomPadding: 12

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        background: Rectangle {
            color: control.pressed ? "#F1F5F9" : (control.hovered ? "#F8FAFC" : "#FFFFFF")
            radius: 12
            border.color: control.hovered ? "#0284C7" : "#E2E8F0"
            border.width: control.hovered ? 2 : 1
        }

        contentItem: RowLayout {
            spacing: 12

            Item {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: control.iconText
                    font.pixelSize: 26
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Text {
                    text: control.titleText
                    font.bold: true
                    font.pixelSize: 15
                    color: "#1E293B"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: control.descText
                    font.pixelSize: 12
                    color: "#64748B"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: scrollView.availableWidth
            implicitHeight: mainLayout.implicitHeight + 40

            ColumnLayout {
                id: mainLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Math.max(16, scrollView.availableWidth * 0.05) // Tự dãn khoảng cách lề
                spacing: 20

                // Header tiêu đề
                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 4
                        Label {
                            text: "📊 TRUNG TÂM QUẢN LÝ"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#0369A1"
                        }
                        Label {
                            text: "Hệ thống quản trị viên Giang's Coffee"
                            font.pixelSize: 14
                            color: "#64748B"
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                // Thống kê Doanh thu & Nhân sự
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.preferredHeight: 95
                        color: "#E0F2FE"
                        radius: 12
                        border.color: "#BAE6FD"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Text {
                                text: "Tổng Doanh Thu"
                                color: "#0369A1"
                                font.pixelSize: 13
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: totalRevenueText
                                color: "#0284C7"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.preferredHeight: 95
                        color: "#DCFCE7"
                        radius: 12
                        border.color: "#BBF7D0"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Text {
                                text: "Nhân Sự Hệ Thống"
                                color: "#15803D"
                                font.pixelSize: 13
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: totalEmpText
                                color: "#16A34A"
                                font.pixelSize: 20
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                // Nhóm Hoạt động & Bán hàng
                Label {
                    text: "Hoạt động & Bán hàng"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#334155"
                    Layout.topMargin: 10
                }

                GridLayout {
                    columns: managerPage.width < 600 ? 1 : 2
                    Layout.fillWidth: true
                    columnSpacing: 15
                    rowSpacing: 15

                    DashboardButton {
                        iconText: "☕"
                        titleText: "POS Bán Hàng (Thực Đơn)"
                        descText: "Tạo đơn hàng, thanh toán và in bill"
                        onClicked: openPage("OrderPage.qml")
                    }

                    DashboardButton {
                        iconText: "🪑"
                        titleText: "Quản Lý Sơ Đồ Bàn"
                        descText: "Xem trạng thái, ghép bàn, thanh toán"
                        onClicked: openPage("SeatingPage.qml")
                    }
                }

                // Nhóm Quản trị Hệ thống
                Label {
                    text: "Quản trị Hệ thống & Dữ liệu"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#334155"
                    Layout.topMargin: 15
                }

                GridLayout {
                    columns: managerPage.width < 600 ? 1 : 2
                    Layout.fillWidth: true
                    columnSpacing: 15
                    rowSpacing: 15

                    DashboardButton {
                        iconText: "👥"
                        titleText: "Báo Cáo Điểm Danh"
                        descText: "Xem danh sách Check-in/out ca làm"
                        onClicked: openPage("AttendanceReportPage.qml")
                    }

                    DashboardButton {
                        iconText: "🔐"
                        titleText: "Quản Lý Nhân Sự"
                        descText: "Thêm, sửa, xóa hồ sơ nhân viên"
                        onClicked: openPage("EmployeeManagementPage.qml")
                    }

                    DashboardButton {
                        iconText: "📈"
                        titleText: "Quản Lý Tài Chính"
                        descText: "Kiểm soát dòng tiền thu/chi, lợi nhuận"
                        onClicked: openPage("FinancePage.qml")
                    }

                    DashboardButton {
                        iconText: "🎁"
                        titleText: "Chương Trình Khuyến Mãi"
                        descText: "Tích điểm Loyalty & Quản lý Voucher"
                        onClicked: openPage("LoyaltyPage.qml")
                    }
                }
            }
        }
    }
}