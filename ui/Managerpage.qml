import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: managerPage
    background: Rectangle { color: "#F8FAFC" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // Tiêu đề Quản lý
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

        // Khung Thống kê nhanh
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

        // Danh sách các chức năng chính
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

            Button {
                text: "☕ Quản Lý Thực Đơn"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
            }

            Button {
                text: "👥 Quản Lý Nhân Viên"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
            }

            Button {
                text: "📈 Báo Cáo Doanh Thu"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
            }

            Button {
                text: "🎁 Chương Trình Khuyến Mãi"
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.pixelSize: 15; font.bold: true
                background: Rectangle { color: "#FFFFFF"; radius: 10; border.color: "#CBD5E1" }
            }
        }

        Item { Layout.fillHeight: true }
    }
}