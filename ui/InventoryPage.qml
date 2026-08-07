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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Tiêu đề
        Text {
            text: "📥 NHẬP TỒN KHO"
            font.pixelSize: 22
            font.bold: true
            color: "#3E2723"
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
                onClicked: {
                    filterType = "Food"
                    ingredientList.model = getFilteredIngredients()
                }
            }
        }

        // Header bảng
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: "#F5F0E8"
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "Tên nguyên liệu"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#5D4037"
                    Layout.preferredWidth: 280
                }
                Text {
                    text: "Ngưỡng tối thiểu"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#5D4037"
                    Layout.preferredWidth: 140
                }
                Text {
                    text: "Tồn hiện tại"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#5D4037"
                    Layout.preferredWidth: 130
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Nhập số mới"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#5D4037"
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
            spacing: 6
            model: getFilteredIngredients()

            delegate: Rectangle {
                width: ingredientList.width
                height: 58
                radius: 8
                color: modelData.isLow ? "#FFEBEE" : "#FFFDF9"
                border.color: modelData.isLow ? "#EF5350" : "#E8DDD2"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: modelData.name
                        font.bold: true
                        font.pixelSize: 14
                        color: "#2C1D11"
                        elide: Text.ElideRight
                        Layout.preferredWidth: 280
                    }

                    Text {
                        text: modelData.minThreshold + " " + modelData.unit
                        font.pixelSize: 13
                        color: "#757575"
                        Layout.preferredWidth: 140
                    }

                    Text {
                        text: modelData.quantity + " " + modelData.unit
                        font.pixelSize: 13
                        font.bold: true
                        color: modelData.isLow ? "#C62828" : "#2E7D32"
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
                    }

                    Button {
                        text: "Cập nhật"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 34
                        highlighted: true
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
            implicitHeight: 44
            highlighted: true
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