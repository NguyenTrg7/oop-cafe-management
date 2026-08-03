import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    title: "Báo Cáo Điểm Danh"
    background: Rectangle { color: "#F8FAFC" }

    ListModel { id: attendanceModel }

    Component.onCompleted: loadAttendanceData()

    function loadAttendanceData() {
        attendanceModel.clear()
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadAttendance) {
            var data = coffeeSystem.loadAttendance()
            for (var i = 0; i < data.length; i++) {
                attendanceModel.append(data[i])
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "LỊCH SỬ ĐIỂM DANH"
                font.bold: true
                font.pixelSize: 20
                color: "#0369A1"
                Layout.fillWidth: true
            }

            Button {
                text: "🔄 Làm mới"
                onClicked: loadAttendanceData()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: attendanceModel
            clip: true
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: index % 2 === 0 ? "#F1F5F9" : "#FFFFFF"
                border.color: "#E2E8F0"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Mã/SĐT: " + model.identifier; font.bold: true; Layout.preferredWidth: 150 }
                    Text { text: model.type === "CHECK_IN" ? "🟢 Check-in" : "🔴 Check-out"; Layout.preferredWidth: 150; color: model.type === "CHECK_IN" ? "#16A34A" : "#DC2626" }
                    Text { text: "Thời gian: " + model.timestamp; Layout.fillWidth: true }
                }
            }
        }
    }
}