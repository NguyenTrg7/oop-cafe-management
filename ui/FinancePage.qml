import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: financePage
    title: "Quản Lý Tài Chính"

    ListModel { id: financeModel }
    property double totalRevenue: 0.0
    property double totalExpense: 0.0

    Component.onCompleted: refreshFinance()

    function refreshFinance() {
        financeModel.clear()
        totalRevenue = 0.0
        totalExpense = 0.0
        var data = coffeeSystem.loadFinance()
        for (var i = 0; i < data.length; i++) {
            financeModel.append(data[i])
            if (data[i].type === "Thu") totalRevenue += data[i].amount
            else if (data[i].type === "Chi") totalExpense += data[i].amount
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Thống kê tổng quan
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Rectangle {
                Layout.fillWidth: true; height: 80; color: "#E8F5E9"; radius: 8
                Column {
                    anchors.centerIn: parent
                    Text { text: "TỔNG THU"; font.bold: true; color: "#2E7D32" }
                    Text { text: totalRevenue.toLocaleString() + " VNĐ"; font.pixelSize: 18; color: "#2E7D32" }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 80; color: "#FFEBEE"; radius: 8
                Column {
                    anchors.centerIn: parent
                    Text { text: "TỔNG CHI"; font.bold: true; color: "#C62828" }
                    Text { text: totalExpense.toLocaleString() + " VNĐ"; font.pixelSize: 18; color: "#C62828" }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 80; color: "#E3F2FD"; radius: 8
                Column {
                    anchors.centerIn: parent
                    Text { text: "LỢI NHUẬN"; font.bold: true; color: "#1565C0" }
                    Text { text: (totalRevenue - totalExpense).toLocaleString() + " VNĐ"; font.pixelSize: 18; color: "#1565C0" }
                }
            }
        }

        // Bảng lịch sử giao dịch
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: financeModel
            clip: true
            delegate: Rectangle {
                width: parent.width; height: 45
                color: model.type === "Thu" ? "#F1F8E9" : "#FFEBEE"
                border.color: "#E0E0E0"

                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    Text { text: model.date; Layout.preferredWidth: 100 }
                    Text { text: model.type; font.bold: true; color: model.type === "Thu" ? "green" : "red"; Layout.preferredWidth: 60 }
                    Text { text: model.amount.toLocaleString() + " VNĐ"; Layout.preferredWidth: 120 }
                    Text { text: model.note; Layout.fillWidth: true }
                }
            }
        }
    }
}