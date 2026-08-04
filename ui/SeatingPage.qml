import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: seatingPage
    background: Rectangle { color: "#F8FAFC" }

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
        width: 340
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: "#FFFFFF"
            radius: 12
            border.color: "#E2E8F0"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 14

            Label { text: "Hình dạng:"; color: "#334155"; font.bold: true }
            ComboBox {
                id: editShape
                model: ["Vuông", "Tròn"]
                Layout.fillWidth: true
            }

            Label { text: "Số ghế:"; color: "#334155"; font.bold: true }
            SpinBox {
                id: editCapacity
                from: 1
                to: 20
                value: 4
                Layout.fillWidth: true
            }

            Label { text: "Ghi chú khách đặt bàn:"; color: "#334155"; font.bold: true }
            TextArea {
                id: editNote
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                wrapMode: TextArea.Wrap
                placeholderText: "VD: Anh Nam - 4 người - 18:30"
                background: Rectangle {
                    radius: 8
                    color: "#F8FAFC"
                    border.color: "#CBD5E1"
                }
            }
        }

        onAccepted: {
            coffeeSystem.editTable(editingTable, editShape.currentText, editCapacity.value)
            coffeeSystem.setTableNote(editingTable, editNote.text.trim())
            refresh()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ===== HEADER =====
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2
                Label {
                    text: "🪑 Sơ Đồ Bàn"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#0369A1"
                }
                Label {
                    text: "Quản lý trạng thái bàn • Gộp / Tách bàn"
                    font.pixelSize: 13
                    color: "#64748B"
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "🔄 Làm mới"
                implicitHeight: 38
                background: Rectangle {
                    color: parent.hovered ? "#E0F2FE" : "#F0F9FF"
                    radius: 8
                    border.color: "#7DD3FC"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#0369A1"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: refresh()
            }
        }

        // ===== THANH GỘP / TÁCH BÀN =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            color: "#FFFFFF"
            radius: 12
            border.color: "#E2E8F0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Label {
                    text: "Gộp bàn:"
                    font.bold: true
                    color: "#334155"
                }

                TextField {
                    id: mergeInput1
                    placeholderText: "Bàn 1"
                    validator: IntValidator { bottom: 1 }
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignHCenter
                    background: Rectangle {
                        radius: 8
                        color: "#F8FAFC"
                        border.color: "#CBD5E1"
                    }
                }

                Label { text: "+"; font.bold: true; color: "#64748B" }

                TextField {
                    id: mergeInput2
                    placeholderText: "Bàn 2"
                    validator: IntValidator { bottom: 1 }
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignHCenter
                    background: Rectangle {
                        radius: 8
                        color: "#F8FAFC"
                        border.color: "#CBD5E1"
                    }
                }

                Button {
                    text: "Gộp"
                    Layout.preferredWidth: 80
                    implicitHeight: 36
                    background: Rectangle {
                        color: parent.pressed ? "#6D28D9" : "#7C3AED"
                        radius: 8
                    }
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
                    text: "Tách bàn:"
                    font.bold: true
                    color: "#334155"
                }

                TextField {
                    id: undoMergeInput
                    placeholderText: "Số bàn"
                    validator: IntValidator { bottom: 1 }
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignHCenter
                    background: Rectangle {
                        radius: 8
                        color: "#F8FAFC"
                        border.color: "#CBD5E1"
                    }
                }

                Button {
                    text: "Tách"
                    Layout.preferredWidth: 80
                    implicitHeight: 36
                    background: Rectangle {
                        color: parent.pressed ? "#C2410C" : "#EA580C"
                        radius: 8
                    }
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

        // ===== SƠ ĐỒ BÀN =====
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            radius: 12
            border.color: "#E2E8F0"
            clip: true

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

                        // Bàn
                        Rectangle {
                            id: tableShape
                            width: 90
                            height: 90
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: (info && info.shape === "Tròn") ? width / 2 : 12
                            color: (info && info.occupied) ? "#FEE2E2" : "#DCFCE7"
                            border.color: (info && info.occupied) ? "#DC2626" : "#16A34A"
                            border.width: 3

                            // Số bàn
                            Text {
                                anchors.centerIn: parent
                                text: modelData.num
                                font.pixelSize: 26
                                font.bold: true
                                color: (info && info.occupied) ? "#B91C1C" : "#15803D"
                            }

                            // Trạng thái
                            Text {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 6
                                text: (info && info.occupied) ? "Có khách" : "Trống"
                                font.pixelSize: 11
                                font.bold: true
                                color: (info && info.occupied) ? "#B91C1C" : "#15803D"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
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

                        // Thông tin ghế + hình dạng
                        Text {
                            anchors.top: tableShape.bottom
                            anchors.topMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 4
                            horizontalAlignment: Text.AlignHCenter
                            text: {
                                if (!info) return ""
                                var base = info.shape + " • " + info.capacity + " ghế"
                                if (info.note && info.note.length > 0)
                                    return base + "\n📝 " + info.note
                                return base
                            }
                            font.pixelSize: 11
                            color: "#64748B"
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 3
                        }

                        // Nút sửa
                        Button {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: 28
                            height: 28
                            text: "✎"
                            visible: info !== null
                            background: Rectangle {
                                color: parent.hovered ? "#0284C7" : "#0369A1"
                                radius: 14
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                editingTable = modelData.num
                                if (info) {
                                    editShape.currentIndex = (info.shape === "Tròn") ? 1 : 0
                                    editCapacity.value = info.capacity
                                    editNote.text = info.note || ""
                                }
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