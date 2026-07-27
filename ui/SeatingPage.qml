import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: seatingPage
    background: Rectangle { color: "#F4EBD0" }

    // Model tạm từ C++
    property var seatingData: coffeeSystem.getSeatingList()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Label {
            text: "Bảng trạng thái bàn"
            font.family: "Georgia"
            font.pixelSize: 24
            font.bold: true
            color: "#4E3629"
            Layout.alignment: Qt.AlignHCenter
        }

        // ===== BẢNG =====
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFF8E7"
            border.color: "#B68D40"
            border.width: 2
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    color: "#4E3629"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 0

                        Label {
                            text: "Bàn số"
                            color: "#F4EBD0"
                            font.bold: true
                            font.pixelSize: 15
                            Layout.preferredWidth: 80
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: "Sức chứa"
                            color: "#F4EBD0"
                            font.bold: true
                            font.pixelSize: 15
                            Layout.preferredWidth: 100
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: "Trạng thái"
                            color: "#F4EBD0"
                            font.bold: true
                            font.pixelSize: 15
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: "Có thể ngồi?"
                            color: "#F4EBD0"
                            font.bold: true
                            font.pixelSize: 15
                            Layout.preferredWidth: 120
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // Nội dung bảng
                ListView {
                    id: tableList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: seatingData

                    delegate: Rectangle {
                        width: tableList.width
                        height: 42
                        color: index % 2 === 0 ? "#FFF8E7" : "#F4EBD0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 0

                            Label {
                                text: modelData.tableNumber
                                font.pixelSize: 15
                                color: "#3E2723"
                                Layout.preferredWidth: 80
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: modelData.capacity
                                font.pixelSize: 15
                                color: "#3E2723"
                                Layout.preferredWidth: 100
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: modelData.status
                                font.pixelSize: 15
                                color: modelData.occupied ? "#C62828" : "#2E7D32"
                                font.bold: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: modelData.available ? "Có" : "Không"
                                font.pixelSize: 15
                                color: modelData.available ? "#2E7D32" : "#C62828"
                                Layout.preferredWidth: 120
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }

        // Nút làm mới bảng
        Button {
            text: "Làm mới bảng"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 180
            Layout.preferredHeight: 42
            background: Rectangle {
                color: "#4E3629"
                radius: 6
            }
            contentItem: Text {
                text: parent.text
                color: "#F4EBD0"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                seatingData = coffeeSystem.getSeatingList()
            }
        }
    }
}