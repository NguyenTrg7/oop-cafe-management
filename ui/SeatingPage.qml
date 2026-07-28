import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: seatingPage
    background: Rectangle { color: "#BAE6FD" }

    property var seatingData: []
    property int editingTable: -1

    property var tablePositions: [
        {num: 1,  x: 40,  y: 40},
        {num: 2,  x: 180, y: 40},
        {num: 3,  x: 320, y: 40},
        {num: 4,  x: 460, y: 40},
        {num: 5,  x: 40,  y: 200},
        {num: 6,  x: 180, y: 200},
        {num: 7,  x: 320, y: 200},
        {num: 8,  x: 460, y: 200},
        {num: 9,  x: 40,  y: 360},
        {num: 10, x: 180, y: 360},
        {num: 11, x: 320, y: 360},
        {num: 12, x: 460, y: 360}
    ]

    function refresh() {
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.getSeatingList)
            seatingData = coffeeSystem.getSeatingList()
        else
            seatingData = []
    }

    function getTableData(num) {
        for (var i = 0; i < seatingData.length; ++i) {
            if (seatingData[i].tableNumber === num)
                return seatingData[i]
        }
        return null
    }

    Dialog {
        id: editDialog
        title: "Sửa bàn " + editingTable
        modal: true
        anchors.centerIn: parent
        width: 320
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Label { text: "Hình dạng:" }
            ComboBox {
                id: editShape
                model: ["Vuông", "Tròn"]
                Layout.fillWidth: true
            }

            Label { text: "Số ghế:" }
            SpinBox {
                id: editCapacity
                from: 1
                to: 20
                value: 4
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            coffeeSystem.editTable(editingTable, editShape.currentText, editCapacity.value)
            refresh()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Label {
            text: "Sơ đồ bàn của Giang's Coffee"
            font.family: "Georgia"
            font.pixelSize: 24
            font.bold: true
            color: "#4E3629"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "#F0F9FF"
            border.color: "#B68D40"
            border.width: 2
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Label {
                    text: "Gộp bàn:"
                    font.bold: true
                    color: "#4E3629"
                }

                TextField {
                    id: mergeInput1
                    placeholderText: "Bàn 1"
                    validator: IntValidator { bottom: 1 }
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignHCenter
                }

                Label { text: "+" }

                TextField {
                    id: mergeInput2
                    placeholderText: "Bàn 2"
                    validator: IntValidator { bottom: 1 }
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "Gộp"
                    Layout.preferredWidth: 80
                    background: Rectangle { color: "#6A1B9A"; radius: 5 }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var t1 = parseInt(mergeInput1.text)
                        var t2 = parseInt(mergeInput2.text)
                        if (!isNaN(t1) && !isNaN(t2) && t1 !== t2) {
                            coffeeSystem.mergeTable(t1, t2)
                            mergeInput1.text = ""
                            mergeInput2.text = ""
                            refresh()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: "Hủy gộp:"
                    font.bold: true
                    color: "#4E3629"
                }

                TextField {
                    id: undoMergeInput
                    placeholderText: "Số bàn"
                    validator: IntValidator { bottom: 1 }
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "Tách bàn"
                    Layout.preferredWidth: 90
                    background: Rectangle { color: "#E65100"; radius: 5 }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var num = parseInt(undoMergeInput.text)
                        if (!isNaN(num)) {
                            if (coffeeSystem.undoMerge(num)) {
                                undoMergeInput.text = ""
                                refresh()
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#F0F9FF"
            border.color: "#B68D40"
            border.width: 2
            radius: 8
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                color: "#F0F9FF"
                radius: 6

                Item {
                    id: tableMap
                    width: 580
                    height: 490
                    anchors.centerIn: parent

                    Repeater {
                        model: tablePositions

                        Item {
                            x: modelData.x
                            y: modelData.y
                            width: 120
                            height: 130

                            property var info: getTableData(modelData.num)
                            visible: info !== null

                            Rectangle {
                                id: tableShape
                                width: 90
                                height: 90
                                anchors.horizontalCenter: parent.horizontalCenter
                                radius: (info && info.shape === "Tròn") ? width / 2 : 10
                                color: (info && info.occupied) ? "#C62828" : "#81C784"
                                border.color: "#4E3629"
                                border.width: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.num
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "white"
                                }

                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: 4
                                    text: (info && info.occupied) ? "Có khách" : "Trống"
                                    font.pixelSize: 11
                                    color: "white"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (!info) return
                                        if (info.available)
                                            coffeeSystem.reserveTable(modelData.num)
                                        else
                                            coffeeSystem.clearTable(modelData.num)
                                        refresh()
                                    }
                                }
                            }

                            Text {
                                anchors.top: tableShape.bottom
                                anchors.topMargin: 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: info ? (info.shape + " • " + info.capacity + " ghế") : ""
                                font.pixelSize: 11
                                color: "#5D4037"
                            }

                            Button {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                width: 24
                                height: 24
                                text: "✎"
                                visible: info !== null
                                background: Rectangle {
                                    color: "#1565C0"
                                    radius: 12
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    editingTable = modelData.num
                                    if (info) {
                                        editShape.currentIndex = (info.shape === "Tròn") ? 1 : 0
                                        editCapacity.value = info.capacity
                                    }
                                    editDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: refresh()
}