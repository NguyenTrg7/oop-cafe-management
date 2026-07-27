import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: seatingPage
    background: Rectangle { color: "#F4EBD0" }

    property var seatingData: []
    property int editingTable: -1

    // Tọa độ cố định của 10 bàn trên sơ đồ (x, y)
    property var tablePositions: [
        {num: 1,  x: 40,  y: 40},
        {num: 2,  x: 180, y: 40},
        {num: 3,  x: 320, y: 40},
        {num: 4,  x: 460, y: 40},
        {num: 5,  x: 40,  y: 200},
        {num: 6,  x: 180, y: 200},
        {num: 7,  x: 320, y: 200},
        {num: 8,  x: 40,  y: 360},
        {num: 9,  x: 180, y: 360},
        {num: 10, x: 320, y: 360}
    ]

    function refresh() {
        seatingData = coffeeSystem.getSeatingList()
    }

    function getTableData(num) {
        for (var i = 0; i < seatingData.length; ++i) {
            if (seatingData[i].tableNumber === num)
                return seatingData[i]
        }
        return null
    }

    // ===================== DIALOG SỬA HÌNH DẠNG =====================
    Dialog {
        id: editDialog
        title: "Sửa hình dạng bàn " + editingTable
        modal: true
        anchors.centerIn: parent
        width: 300
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
        }

        onAccepted: {
            coffeeSystem.editTable(editingTable, "", editShape.currentText)
            refresh()
        }
    }

    // ===================== NỘI DUNG =====================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Label {
            text: "Sơ đồ bàn Giang's Coffee"
            font.family: "Georgia"
            font.pixelSize: 24
            font.bold: true
            color: "#4E3629"
            Layout.alignment: Qt.AlignHCenter
        }

        // ===== THANH CÔNG CỤ =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            color: "#FFF8E7"
            border.color: "#B68D40"
            border.width: 2
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // Hàng 1: Gộp bàn
                RowLayout {
                    spacing: 8
                    Label { text: "Gộp bàn:"; font.bold: true; color: "#4E3629" }

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
                            text: parent.text; color: "white"; font.bold: true
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
                    Button { text: "Làm mới"; onClicked: refresh() }
                }

                // Hàng 2: Đổi số + Hủy gộp
                RowLayout {
                    spacing: 8
                    Label { text: "Đổi số:"; font.bold: true; color: "#4E3629" }

                    TextField {
                        id: renameOld
                        placeholderText: "Cũ"
                        validator: IntValidator { bottom: 1 }
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label { text: "→" }
                    TextField {
                        id: renameNew
                        placeholderText: "Mới"
                        validator: IntValidator { bottom: 1 }
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Button {
                        text: "Đổi số"
                        Layout.preferredWidth: 80
                        background: Rectangle { color: "#0277BD"; radius: 5 }
                        contentItem: Text {
                            text: parent.text; color: "white"; font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            var oldN = parseInt(renameOld.text)
                            var newN = parseInt(renameNew.text)
                            if (!isNaN(oldN) && !isNaN(newN)) {
                                if (coffeeSystem.renameTable(oldN, newN)) {
                                    renameOld.text = ""
                                    renameNew.text = ""
                                    refresh()
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Label { text: "Hủy gộp:"; font.bold: true; color: "#4E3629" }
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
                            text: parent.text; color: "white"; font.bold: true
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
        }

        // ===== SƠ ĐỒ BÀN VỚI VỊ TRÍ CỐ ĐỊNH =====
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFF8E7"
            border.color: "#B68D40"
            border.width: 2
            radius: 8
            clip: true

            // Nền sơ đồ
            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                color: "#F5F0E6"
                radius: 6

                // Vẽ từng bàn theo tọa độ cố định
                Repeater {
                    model: tablePositions

                    Item {
                        x: modelData.x
                        y: modelData.y
                        width: 120
                        height: 130

                        property var info: getTableData(modelData.num)

                        // Chỉ hiện nếu bàn còn tồn tại (sau khi gộp có thể mất)
                        visible: info !== null

                        // Hình bàn
                        Rectangle {
                            id: tableShape
                            width: 90
                            height: 90
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: (info && info.shape === "Tròn") ? width/2 : 10
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

                        // Số ghế + hình dạng
                        Text {
                            anchors.top: tableShape.bottom
                            anchors.topMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: info ? (info.shape + " • " + info.capacity + " ghế") : ""
                            font.pixelSize: 11
                            color: "#5D4037"
                        }

                        // Nút sửa hình dạng
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
                                editShape.currentIndex = (info.shape === "Tròn") ? 1 : 0
                                editDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: refresh()
}