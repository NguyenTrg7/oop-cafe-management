import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: managerPage
    background: Rectangle { color: "#F8FAFC" }

    // 🔑 Hàm hỗ trợ điều hướng trang linh hoạt
    function openPage(pageUrl) {
        if (typeof pageStack !== "undefined" && pageStack.push) {
            pageStack.push(pageUrl)
        } else if (StackView.view) {
            StackView.view.push(pageUrl)
        } else if (typeof mainLoader !== "undefined") {
            mainLoader.source = pageUrl
        } else {
            console.log("Chuyển tới trang:", pageUrl)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // ---------------------------------------------------------------------
        // 1. TIÊU ĐỀ QUẢN LÝ
        // ---------------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "📊 TRUNG TÂM QUẢN LÝ CỬA HÀNG"
                font.pixelSize: 22
                font.bold: true
                color: "#0369A1"
            }
            Item { Layout.fillWidth: true }
            Label {
                text: "Quyền: Quản lý (Admin)"
                font.pixelSize: 14
                color: "#64748B"
            }
        }

        // ---------------------------------------------------------------------
        // 2. KHUNG THỐNG KÊ NHANH
        // ---------------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Rectangle {
                Layout.fillWidth: true; height: 90
                color: "#E0F2FE"; radius: 12
                Column {
                    anchors.centerIn: parent; spacing: 5
                    Text { text: "Doanh Thu Hôm Nay"; color: "#0369A1"; font.pixelSize: 13 }
                    Text { text: "3.450.000 VNĐ"; color: "#0284C7"; font.pixelSize: 20; font.bold: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 90
                color: "#DCFCE7"; radius: 12
                Column {
                    anchors.centerIn: parent; spacing: 5
                    Text { text: "Tổng Đơn Hàng"; color: "#15803D"; font.pixelSize: 13 }
                    Text { text: "86 Đơn"; color: "#16A34A"; font.pixelSize: 20; font.bold: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 90
                color: "#FEF3C7"; radius: 12
                Column {
                    anchors.centerIn: parent; spacing: 5
                    Text { text: "Khách Hàng Mới"; color: "#B45309"; font.pixelSize: 13 }
                    Text { text: "+12 Thành viên"; color: "#D97706"; font.pixelSize: 20; font.bold: true }
                }
            }
        }

        // ---------------------------------------------------------------------
        // 3. DANH SÁCH CÁC CHỨC NĂNG QUẢN TRỊ
        // ---------------------------------------------------------------------
        Label {
            text: "Chức năng quản trị:"
            font.pixelSize: 16
            font.bold: true
            color: "#334155"
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 15

            // 1. Quản lý thực đơn
            Button {
                text: "☕ Quản Lý Thực Đơn"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
                onClicked: openPage("OrderPage.qml")
            }

            // 2. Quản lý nhân viên
            Button {
                text: "👥 Quản Lý Nhân Viên"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
                onClicked: openPage("EmployeePage.qml")
            }

            // 3. Quản lý & cấp tài khoản hệ thống
            Button {
                text: "🔐 Quản Lý & Cấp Tài Khoản"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
                onClicked: openPage("EmployeeManagementPage.qml")
            }

            // 4. Báo cáo doanh thu
            Button {
                text: "📈 Báo Cáo Doanh Thu"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
                onClicked: openPage("FinancePage.qml")
            }

            // 5. Khuyến mãi
            Button {
                text: "🎁 Chương Trình Khuyến Mãi"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
                onClicked: openPage("LoyaltyPage.qml")
            }
        }

        Item { Layout.fillHeight: true }
    }
}