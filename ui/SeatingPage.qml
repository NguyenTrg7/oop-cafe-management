import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: seatingPage
    title: "Sơ Đồ Bàn"
    background: Rectangle { color: "#F8FAFC" }

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("SeatingPage.qml", "Sơ Đồ Bàn")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("SeatingPage.qml", "Sơ Đồ Bàn")
            if (win.pageTitle !== undefined) win.pageTitle = "Sơ Đồ Bàn"
        }
    }

    StackView.onActivating: syncNavBar()

    property var seatingData: []
    property int editingTable: -1

    property var tablePositions: [
        {num: 1,  x: 0,   y: 0},
        {num: 2,  x: 140, y: 0},
        {num: 3,  x: 280, y: 0},
        {num: 4,  x: 420, y: 0},
        {num: 5,  x: 0,   y: 160},
        {num: 6,  x: 140, y: 160},
        {num: 7,  x: 280, y: 160},
        {num: 8,  x: 420, y: 160},
        {num: 9,  x: 0,   y: 320},
        {num: 10, x: 140, y: 320},
        {num: 11, x: 280, y: 320},
        {num: 12, x: 420, y: 320}
    ]

    readonly property int gridWidth: 540   // 420 + 120
    readonly property int gridHeight: 450  // 320 + 130

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
        modal: true
        anchors.centerIn: parent
        width: Math.min(400, seatingPage.width > 0 ? seatingPage.width - 48 : 400)
        padding: 0
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#E2E8F0"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 0

            // ===== HEADER =====
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                color: "#F0F9FF"
                radius: 16

                // Che bo góc dưới để header liền mạch
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 16
                    color: "#F0F9FF"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 16
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 10
                        color: "#E0F2FE"
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "🪑"
                            font.pixelSize: 20
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: "Chỉnh sửa bàn"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#0369A1"
                        }
                        Text {
                            text: "Bàn số " + editingTable
                            font.pixelSize: 13
                            color: "#64748B"
                        }
                    }

                    // Nút đóng góc phải
                    Button {
                        implicitWidth: 32
                        implicitHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle {
                            color: parent.hovered ? "#FEE2E2" : "transparent"
                            radius: 8
                        }
                        contentItem: Text {
                            text: "✕"
                            color: parent.hovered ? "#DC2626" : "#94A3B8"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: editDialog.close()
                    }
                }
            }

            // ===== BODY =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 16

                // Hình dạng
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Hình dạng bàn"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#334155"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Nút Vuông
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: 10
                            color: editShape.currentIndex === 0 ? "#E0F2FE" : "#F8FAFC"
                            border.color: editShape.currentIndex === 0 ? "#0284C7" : "#E2E8F0"
                            border.width: editShape.currentIndex === 0 ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: 3
                                    color: editShape.currentIndex === 0 ? "#0284C7" : "#CBD5E1"
                                }
                                Text {
                                    text: "Vuông"
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: editShape.currentIndex === 0 ? "#0369A1" : "#64748B"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: editShape.currentIndex = 0
                            }
                        }

                        // Nút Tròn
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: 10
                            color: editShape.currentIndex === 1 ? "#E0F2FE" : "#F8FAFC"
                            border.color: editShape.currentIndex === 1 ? "#0284C7" : "#E2E8F0"
                            border.width: editShape.currentIndex === 1 ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: editShape.currentIndex === 1 ? "#0284C7" : "#CBD5E1"
                                }
                                Text {
                                    text: "Tròn"
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: editShape.currentIndex === 1 ? "#0369A1" : "#64748B"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: editShape.currentIndex = 1
                            }
                        }
                    }

                    // ComboBox ẩn (giữ để logic cũ vẫn chạy)
                    ComboBox {
                        id: editShape
                        model: ["Vuông", "Tròn"]
                        visible: false
                        Layout.preferredHeight: 0
                    }
                }

                // Số ghế
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Số ghế"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#334155"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Button {
                            implicitWidth: 44
                            implicitHeight: 44
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            background: Rectangle {
                                color: parent.pressed ? "#E0F2FE" : (parent.hovered ? "#F0F9FF" : "#F8FAFC")
                                radius: 10
                                border.color: "#CBD5E1"
                            }
                            contentItem: Text {
                                text: "−"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#0369A1"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (editCapacity.value > editCapacity.from)
                                    editCapacity.value -= 1
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 10
                            color: "#F0F9FF"
                            border.color: "#BAE6FD"

                            Text {
                                anchors.centerIn: parent
                                text: editCapacity.value + " ghế"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#0369A1"
                            }
                        }

                        Button {
                            implicitWidth: 44
                            implicitHeight: 44
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            background: Rectangle {
                                color: parent.pressed ? "#E0F2FE" : (parent.hovered ? "#F0F9FF" : "#F8FAFC")
                                radius: 10
                                border.color: "#CBD5E1"
                            }
                            contentItem: Text {
                                text: "+"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#0369A1"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (editCapacity.value < editCapacity.to)
                                    editCapacity.value += 1
                            }
                        }

                        // SpinBox ẩn (giữ logic)
                        SpinBox {
                            id: editCapacity
                            from: 1
                            to: 20
                            value: 4
                            visible: false
                            Layout.preferredWidth: 0
                            Layout.preferredHeight: 0
                        }
                    }
                }

                // Ghi chú
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Ghi chú khách đặt bàn"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#334155"
                    }

                    TextArea {
                        id: editNote
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88
                        wrapMode: TextArea.Wrap
                        placeholderText: "VD: Anh Nam – 4 người – 18:30"
                        font.pixelSize: 14
                        color: "#1E293B"
                        leftPadding: 12
                        rightPadding: 12
                        topPadding: 10
                        bottomPadding: 10
                        background: Rectangle {
                            radius: 10
                            color: "#F8FAFC"
                            border.color: editNote.activeFocus ? "#0284C7" : "#E2E8F0"
                            border.width: editNote.activeFocus ? 2 : 1
                        }
                    }
                }
            }

            // ===== FOOTER =====
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#E2E8F0"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle {
                        color: parent.pressed ? "#E2E8F0" : "#F1F5F9"
                        radius: 10
                    }
                    contentItem: Text {
                        text: "Hủy"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#475569"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: editDialog.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle {
                        color: parent.pressed ? "#0369A1" : "#0284C7"
                        radius: 10
                    }
                    contentItem: Text {
                        text: "💾 Lưu thay đổi"
                        font.bold: true
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (typeof coffeeSystem !== "undefined") {
                            if (coffeeSystem.editTable)
                                coffeeSystem.editTable(editingTable, editShape.currentText, editCapacity.value)
                            if (coffeeSystem.setTableNote)
                                coffeeSystem.setTableNote(editingTable, editNote.text.trim())
                        }
                        refresh()
                        editDialog.close()
                    }
                }
            }
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
                padding: 10
                HoverHandler { cursorShape: Qt.PointingHandCursor }
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
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle {
                        color: parent.pressed ? "#6D28D9" : (parent.hovered ? "#6D28D9" : "#7C3AED")
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
                        if (!isNaN(t1) && !isNaN(t2) && t1 !== t2 && typeof coffeeSystem !== "undefined") {
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
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle {
                        color: parent.pressed ? "#C2410C" : (parent.hovered ? "#C2410C" : "#EA580C")
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
                        if (!isNaN(num) && typeof coffeeSystem !== "undefined") {
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

            ScrollView {
                id: seatingScroll
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                contentWidth: Math.max(gridWidth + 40, availableWidth)
                contentHeight: Math.max(gridHeight + 40, availableHeight)

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
                                        if (!info || typeof coffeeSystem === "undefined") return
                                        if (info.available)
                                            coffeeSystem.reserveTable(modelData.num)
                                        else
                                            coffeeSystem.clearTable(modelData.num)
                                        refresh()
                                    }
                                }
                            }

                            // Nút sửa (Căn chỉnh chuẩn neo vào góc trên phải của tableShape)
                            Button {
                                anchors.top: tableShape.top
                                anchors.right: tableShape.right
                                anchors.topMargin: -4
                                anchors.rightMargin: -4
                                width: 28
                                height: 28
                                text: "✎"
                                visible: info !== null
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
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
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        syncNavBar()
        refresh()
    }
}