import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    property string filterType: "All"

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("InventoryPage.qml", "Tồn Kho Nguyên Liệu")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("InventoryPage.qml", "Tồn Kho Nguyên Liệu")
            if (win.pageTitle !== undefined) win.pageTitle = "Tồn Kho Nguyên Liệu"
        }
    }

    onVisibleChanged: {
        if (visible) syncNavBar()
    }

    function getFilteredIngredients() {
        if (typeof ingredientManager === "undefined") return []

        var all = ingredientManager.getAllIngredients()
        if (filterType === "All") return all

        var result = []
        for (var i = 0; i < all.length; i++) {
            var id = all[i].id || ""
            if (filterType === "Drink" && id.startsWith("ING0"))
                result.push(all[i])
            else if (filterType === "Food" && id.startsWith("ING1"))
                result.push(all[i])
        }
        return result
    }
    Rectangle {
        anchors.fill: parent
        color: "#F0F9FF"
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // Tiêu đề
        Text {
            text: "📥 NHẬP TỒN KHO"
            font.pixelSize: 22
            font.bold: true
            color: "#0C4A6E"
        }

        // Bộ lọc
        RowLayout {
            spacing: 10

            ButtonGroup { id: filterGroup }

            Button {
                text: "Tất cả"
                checkable: true
                checked: filterType === "All"
                ButtonGroup.group: filterGroup
                background: Rectangle {
                    radius: 10
                    color: parent.checked ? "#3B82F6" : "#FFFFFF"
                    border.color: parent.checked ? "#3B82F6" : "#BAE6FD"
                    border.width: 1.5
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "white" : "#1E3A5F"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    filterType = "All"
                    ingredientList.model = getFilteredIngredients()
                }
            }
            Button {
                text: "Đồ uống"
                checkable: true
                checked: filterType === "Drink"
                ButtonGroup.group: filterGroup
                background: Rectangle {
                    radius: 10
                    color: parent.checked ? "#3B82F6" : "#FFFFFF"
                    border.color: parent.checked ? "#3B82F6" : "#BAE6FD"
                    border.width: 1.5
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "white" : "#1E3A5F"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    filterType = "Drink"
                    ingredientList.model = getFilteredIngredients()
                }
            }
            Button {
                text: "Món ăn"
                checkable: true
                checked: filterType === "Food"
                ButtonGroup.group: filterGroup
                background: Rectangle {
                    radius: 10
                    color: parent.checked ? "#3B82F6" : "#FFFFFF"
                    border.color: parent.checked ? "#3B82F6" : "#BAE6FD"
                    border.width: 1.5
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "white" : "#1E3A5F"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    filterType = "Food"
                    ingredientList.model = getFilteredIngredients()
                }
            }
        }

        // Header bảng
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#E0F2FE"
            radius: 10
            border.color: "#BAE6FD"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "Tên nguyên liệu"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#0C4A6E"
                    Layout.preferredWidth: 280
                }
                Text {
                    text: "Ngưỡng tối thiểu"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#0C4A6E"
                    Layout.preferredWidth: 140
                }
                Text {
                    text: "Tồn hiện tại"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#0C4A6E"
                    Layout.preferredWidth: 130
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Nhập số mới"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#0C4A6E"
                    Layout.preferredWidth: 110
                    horizontalAlignment: Text.AlignHCenter
                }
                Item { Layout.preferredWidth: 100 }
            }
        }

        // Danh sách nguyên liệu
        ListView {
            id: ingredientList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 7
            model: getFilteredIngredients()

            delegate: Rectangle {
                width: ingredientList.width
                height: 58
                radius: 8
                color: modelData.isLow ? "#FEF2F2" : "#FFFFFF"
                                border.color: modelData.isLow ? "#FCA5A5" : "#BAE6FD"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: modelData.name
                        font.bold: true
                        font.pixelSize: 14
                        color: "#1E3A5F"
                        elide: Text.ElideRight
                        Layout.preferredWidth: 280
                    }

                    Text {
                        text: modelData.minThreshold + " " + modelData.unit
                        font.pixelSize: 13
                        color: "#64748B"
                        Layout.preferredWidth: 140
                    }

                    Text {
                        text: modelData.quantity + " " + modelData.unit
                        font.pixelSize: 13
                        font.bold: true
                        color: modelData.isLow ? "#DC2626" : "#059669"
                        Layout.preferredWidth: 130
                        horizontalAlignment: Text.AlignHCenter
                    }

                    TextField {
                        id: qtyField
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 34
                        text: modelData.quantity
                        horizontalAlignment: Text.AlignHCenter
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        selectByMouse: true
                        background: Rectangle {
                            radius: 8
                            color: "#F8FAFC"
                            border.color: parent.activeFocus ? "#3B82F6" : "#BFDBFE"
                            border.width: 1.5
                        }
                    }

                    Button {
                        text: "Cập nhật"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 34
                        highlighted: true
                        background: Rectangle {
                            radius: 8
                            color: parent.down ? "#2563EB" : "#3B82F6"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.bold: true
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            var newQty = parseFloat(qtyField.text)
                            if (!isNaN(newQty) && typeof ingredientManager !== "undefined") {
                                ingredientManager.setQuantity(modelData.id, newQty)
                                ingredientList.model = getFilteredIngredients()
                            }
                        }
                    }
                }
            }
        }

        // Nút lưu
        Button {
            text: "💾 Lưu tồn kho ra file"
            Layout.fillWidth: true
            implicitHeight: 46
            highlighted: true
            background: Rectangle {
                radius: 12
                color: parent.down ? "#2563EB" : "#3B82F6"
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                if (typeof ingredientManager !== "undefined") {
                    // Gọi setQuantity lại để trigger autoSave
                    var list = ingredientManager.getAllIngredients()
                    for (var i = 0; i < list.length; i++) {
                        ingredientManager.setQuantity(list[i].id, list[i].quantity)
                    }
                    console.log("Đã lưu tồn kho")
                }
            }
        }
    }

    Connections {
        target: typeof ingredientManager !== "undefined" ? ingredientManager : null
        function onIngredientsChanged() {
            ingredientList.model = getFilteredIngredients()
        }
    }

    Component.onCompleted: {
        syncNavBar()
        ingredientList.model = getFilteredIngredients()
    }
}