import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    property string mode: "morning"          // "morning" | "evening"
    property string filterType: "All"        // "All" | "Drink" | "Food"

    // Hàm lọc nguyên liệu theo loại (dựa vào ID)
    function getFilteredIngredients() {
        if (typeof ingredientManager === "undefined") return []

        var all = ingredientManager.getAllIngredients()
        if (filterType === "All") return all

        var result = []
        for (var i = 0; i < all.length; i++) {
            var id = all[i].id || ""
            if (filterType === "Drink" && id.startsWith("ING0"))   // ING001 → ING024
                result.push(all[i])
            else if (filterType === "Food" && id.startsWith("ING1")) // ING101 → ...
                result.push(all[i])
        }
        return result
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // ===== HEADER =====
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: mode === "morning" ? "📥 NHẬP TỒN ĐẦU NGÀY" : "📤 KIỂM TRA TỒN CUỐI NGÀY"
                font.pixelSize: 22
                font.bold: true
                color: "#3E2723"
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "← Quay lại"
                onClicked: {
                    if (StackView.view) StackView.view.pop()
                    else if (typeof stackView !== "undefined") stackView.pop()
                }
            }
        }

        // ===== CHỌN MODE + LỌC LOẠI =====
        RowLayout {
            spacing: 10

            // --- Nhóm Đầu ngày / Cuối ngày ---
            ButtonGroup {
                id: modeGroup
            }

            Button {
                text: "Đầu ngày"
                checkable: true
                checked: mode === "morning"
                ButtonGroup.group: modeGroup
                onClicked: mode = "morning"
            }
            Button {
                text: "Cuối ngày"
                checkable: true
                checked: mode === "evening"
                ButtonGroup.group: modeGroup
                onClicked: mode = "evening"
            }

            Item { width: 24 }   // khoảng cách

            // --- Nhóm lọc loại nguyên liệu ---
            ButtonGroup {
                id: filterGroup
            }

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

        // ===== HEADER CỘT (thẳng hàng) =====
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
                Item { Layout.preferredWidth: 100 } // chỗ nút
            }
        }

        // ===== DANH SÁCH =====
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

                    // Tên
                    Text {
                        text: modelData.name
                        font.bold: true
                        font.pixelSize: 14
                        color: "#2C1D11"
                        elide: Text.ElideRight
                        Layout.preferredWidth: 280
                    }

                    // Ngưỡng tối thiểu
                    Text {
                        text: modelData.minThreshold + " " + modelData.unit
                        font.pixelSize: 13
                        color: "#757575"
                        Layout.preferredWidth: 140
                    }

                    // Tồn hiện tại
                    Text {
                        text: modelData.quantity + " " + modelData.unit
                        font.pixelSize: 13
                        font.bold: true
                        color: modelData.isLow ? "#C62828" : "#2E7D32"
                        Layout.preferredWidth: 130
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Ô nhập
                    TextField {
                        id: qtyField
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 34
                        text: modelData.quantity
                        horizontalAlignment: Text.AlignHCenter
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        selectByMouse: true
                    }

                    // Nút Cập nhật
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

        // ===== NÚT LƯU FILE =====
        Button {
            text: "💾 Lưu tồn kho ra file"
            Layout.fillWidth: true
            implicitHeight: 44
            highlighted: true
            onClicked: {
                if (typeof ingredientManager !== "undefined") {
                    // Lưu riêng 2 file hoặc 1 file tổng tuỳ bạn
                    var ok1 = ingredientManager.saveIngredientsCSV(applicationDir + "/data/IngredientDrink.csv")
                    // Bạn có thể viết thêm hàm save riêng cho Food nếu muốn
                    console.log(ok1 ? "Đã lưu thành công" : "Lỗi lưu file")
                }
            }
        }
    }

    // Tự refresh khi có thay đổi
    Connections {
        target: typeof ingredientManager !== "undefined" ? ingredientManager : null
        function onIngredientsChanged() {
            ingredientList.model = getFilteredIngredients()
        }
    }

    Component.onCompleted: {
        ingredientList.model = getFilteredIngredients()
    }
}