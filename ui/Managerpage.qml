import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: managerPage
    background: Rectangle { color: "#F8FAFC" }

    property string totalRevenueText: "0 VNĐ"
    property string totalEmpText: "0"

    Component.onCompleted: refreshStats()

    function refreshStats() {
        var rev = 0;
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadFinance) {
            var dataFinance = coffeeSystem.loadFinance()
            if (dataFinance) {
                for (var i = 0; i < dataFinance.length; i++) {
                    if (dataFinance[i].type === "Thu") {
                        rev += dataFinance[i].amount
                    }
                }
            }
        }
        totalRevenueText = Number(rev).toLocaleString(Qt.locale("vi_VN")) + " VNĐ"

        var empCount = 0;
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
            var empData = coffeeSystem.loadEmployees()
            if (empData) {
                empCount = empData.length
            }
        }
        totalEmpText = empCount + " Nhân sự"
    }

    // Hàm chuyển trang đa năng: Tự động tìm appWindow hoặc StackView để điều hướng
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

    component DashboardButton: Button {
        id: control
        property string iconText: "📦"
        property string titleText: "Tiêu đề"
        property string descText: "Mô tả chức năng"

        Layout.fillWidth: true
        Layout.preferredHeight: 85

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        background: Rectangle {
            color: control.pressed ? "#F1F5F9" : (control.hovered ? "#F8FAFC" : "#FFFFFF")
            radius: 12
            border.color: control.hovered ? "#93C5FD" : "#E2E8F0"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                anchors.topMargin: 2
                color: "transparent"
                border.color: "#0F000000"
                radius: 13
                z: -1
            }
        }

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            Text {
                text: control.iconText
                font.pixelSize: 28
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: control.titleText
                    font.bold: true
                    font.pixelSize: 15
                    color: "#1E293B"
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
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            anchors.margins: 25
            spacing: 25

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 25
                Layout.rightMargin: 25
                Layout.topMargin: 20

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

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 25
                Layout.rightMargin: 25
                spacing: 15

                Rectangle {
                    Layout.fillWidth: true; height: 95
                    color: "#E0F2FE"; radius: 12
                    border.color: "#BAE6FD"
                    Column {
                        anchors.centerIn: parent; spacing: 5
                        Text { text: "Tổng Doanh Thu"; color: "#0369A1"; font.pixelSize: 13; font.bold: true }
                        Text { text: totalRevenueText; color: "#0284C7"; font.pixelSize: 20; font.bold: true }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 95
                    color: "#DCFCE7"; radius: 12
                    border.color: "#BBF7D0"
                    Column {
                        anchors.centerIn: parent; spacing: 5
                        Text { text: "Nhân Sự Hệ Thống"; color: "#15803D"; font.pixelSize: 13; font.bold: true }
                        Text { text: totalEmpText; color: "#16A34A"; font.pixelSize: 20; font.bold: true }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 25
                Layout.rightMargin: 25
                spacing: 15

                Label {
                    text: "Hoạt động & Bán hàng"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#334155"
                    Layout.topMargin: 10
                }

                GridLayout {
                    columns: 2
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

                Label {
                    text: "Quản trị Hệ thống & Dữ liệu"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#334155"
                    Layout.topMargin: 15
                }

                GridLayout {
                    columns: 2
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
                        titleText: "Báo Cáo Tài Chính"
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

            Item { Layout.fillHeight: true; Layout.minimumHeight: 30 }
        }
    }
}