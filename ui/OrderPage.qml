import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: orderPageRoot
    anchors.fill: parent

    property string selectedCategory: "Drink"

    // Model giỏ hàng tạm thời
    ListModel {
        id: cartModel
    }

    function formatVND(value) {
        value = Math.round(Number(value));
        return Qt.locale("vi_VN").toString(value) + " VNĐ";
    }

    // Hàm chuyển đổi tên món thành tên file ảnh chuẩn (Ví dụ: "Cà phê đen đá" -> "ca_phe_den_da.png")
    // Hàm chuyển đổi tên món thành tên file ảnh chuẩn
    function getImagePath(itemName, category)
    {
        if (!itemName)
            return "";

        var fileName = itemName.toLowerCase()
                               .normalize("NFD")
                               .replace(/[\u0300-\u036f]/g, "")
                               .replace(/[đĐ]/g, "d")
                               .replace(/\s+/g, "_")
                               .replace(/[^a-z0-9_]/g, "");

        var folder = category === "Food" ? "Food" : "Drink";

        return "file:///" + applicationDir + "/data/" + folder + "/" + fileName + ".png";
    }
    // Hàm tính tổng tiền toàn bộ giỏ hàng
    function calculateGrandTotal() {
        var total = 0;
        for (var i = 0; i < cartModel.count; i++) {
            total += cartModel.get(i).totalPrice;
        }
        return total;
    }

    // hàm tính điểm của giỏ hàng
    function calculateLoyaltyPoints() {
        var pts = 0
        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i)
            var qty = item.quantity || 1
            if (item.category === "Drink") {
                var size = (item.size || "M").toUpperCase()
                var per = 2
                if (size === "S") per = 1
                else if (size === "L") per = 3
                pts += per * qty
            } else {
                pts += 2 * qty
            }
        }
        return pts
    }

    // 1. Lấy dữ liệu từ MenuManager
    function getMenuData(type) {
        if (typeof coffeeSystem !== "undefined" && coffeeSystem && coffeeSystem.menuManager) {
            return coffeeSystem.menuManager.getMenuByCategory(type);
        }
        return [];
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // =====================================================================
        // CỘT BÊN TRÁI: MENU (CHỌN DRINK / FOOD & DANH SÁCH MÓN)
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Thanh Tab Chọn Loại Món
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "☕ Đồ uống (Drink)"
                    Layout.fillWidth: true
                    highlighted: orderPageRoot.selectedCategory === "Drink"
                    onClicked: orderPageRoot.selectedCategory = "Drink"
                }

                Button {
                    text: "🍰 Món ăn (Food)"
                    Layout.fillWidth: true
                    highlighted: orderPageRoot.selectedCategory === "Food"
                    onClicked: orderPageRoot.selectedCategory = "Food"
                }
            }

            // Grid Danh sách món
            GridView {
                id: menuGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: menuGrid.width / 2
                cellHeight: 110
                clip: true

                model: getMenuData(orderPageRoot.selectedCategory)

                delegate: Item {
                    width: menuGrid.cellWidth
                    height: menuGrid.cellHeight

                    Rectangle {
                        id: cardBackground
                        anchors.fill: parent
                        anchors.margins: 5
                        color: mouseArea.containsMouse ? "#F2EBE1" : "#FFFDF9"
                        border.color: mouseArea.containsMouse ? "#8B5A2B" : "#D8C4B6"
                        border.width: mouseArea.containsMouse ? 2 : 1
                        radius: 8

                        // Layout hàng ngang: Hình ảnh bên trái, Thông tin món bên phải
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            // Hình ảnh món ăn / đồ uống
                            Image {
                                Layout.preferredWidth: 70
                                Layout.preferredHeight: 70
                                //fillMode: Image.PreserveAspectFit
                                source: getImagePath(modelData.name, orderPageRoot.selectedCategory)
                                    onSourceChanged: console.log("Image path: " + source)
                                //source: getImagePath(modelData.name, orderPageRoot.selectedCategory)
                                // Hiển thị hình mặc định hoặc ẩn nếu không tìm thấy file ảnh

                                fillMode: Image.PreserveAspectCrop
                                clip: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#E0E0E0"
                                    visible: parent.status === Image.Error || parent.status === Image.Null
                                    radius: 6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📷"
                                        font.pixelSize: 20
                                    }
                                }
                            }

                            // Thông tin tên món và giá
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                Text {
                                    text: modelData.name || ""
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: "#2C1D11"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: formatVND(modelData.price)
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#8B5A2B"
                                }
                            }
                        }

                        // Nhấp trực tiếp vào ô món ăn để chọn
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                itemDialog.openDialog(modelData, orderPageRoot.selectedCategory);
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // CỘT BÊN PHẢI: GIỎ HÀNG & TỔNG TIỀN ĐƠN HÀNG
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            color: "#F9F6F0"
            border.color: "#D8C4B6"
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "🛒 Chi tiết đơn hàng"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2C1D11"
                }

                // Danh sách món trong giỏ hàng
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: cartModel

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 55
                        color: "#FFFFFF"
                        radius: 4
                        border.color: "#E0E0E0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.name + (model.size ? " (" + model.size + ")" : "") + " x" + model.quantity
                                    font.bold: true
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: model.note !== "" ? "Ghi chú: " + model.note : "Không ghi chú"
                                    font.pixelSize: 10
                                    color: "#757575"
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: formatVND(model.totalPrice)
                                font.bold: true
                                font.pixelSize: 12
                                color: "#8B5A2B"
                            }

                            Button {
                                text: "X"
                                implicitWidth: 24
                                implicitHeight: 24
                                onClicked: cartModel.remove(index)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#D8C4B6"
                }

                // HIỂN THỊ TỔNG TIỀN VÀ NÚT TÍNH TIỀN
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "TỔNG CỘNG:"
                        font.bold: true
                        font.pixelSize: 15
                        color: "#2C1D11"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: formatVND(calculateGrandTotal())
                        font.bold: true
                        font.pixelSize: 18
                        color: "#C0392B"
                    }
                }

                Button {
                    text: "TẠO ĐƠN & THANH TOÁN"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    highlighted: true
                    enabled: cartModel.count > 0

                    onClicked: {
                        console.log("Thanh toán tổng tiền: " + calculateGrandTotal());
                        var total = calculateGrandTotal()
                        var earned = calculateLoyaltyPoints()

                        if (typeof customerHandler !== "undefined" && earned > 0) {
                            customerHandler.addPoints(earned)
                            if (typeof accountHandler !== "undefined")
                                accountHandler.saveCustomerLoyalty()
                            console.log("Tich +" + earned + " diem")
                        }
                        cartModel.clear()
                    }
                }

                Button {
                    text: "⭐ Xem điểm Loyalty"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        if (StackView.view)
                            StackView.view.push("LoyaltyPage.qml")
                        else if (typeof stackView !== "undefined")
                            stackView.push("LoyaltyPage.qml")
                    }
                }

                Button {
                    text: "🪑 Xem trạng thái bàn"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        if (StackView.view)
                            StackView.view.push("SeatingPage.qml")
                        else if (typeof stackView !== "undefined")
                            stackView.push("SeatingPage.qml")
                    }
                }
            }
        }
    }

    // =========================================================================
    // DIALOG TÙY CHỌN MÓN (SIZE -> SỐ LƯỢNG -> GHI CHÚ -> BẢNG TÍNH TIỀN TẠM)
    // =========================================================================
    Dialog {
        id: itemDialog
        title: "Tùy chọn món"
        anchors.centerIn: parent
        width: 360
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        property var itemData: null
        property string category: "Drink"
        property real basePrice: 0
        property real calculatedPrice: 0

        function openDialog(data, cat) {
            itemData = data;
            category = cat;
            basePrice = Number(data.price || 0);

            if (cat === "Drink" && data.sizes && data.sizes.length > 0) {
                sizeCombo.model = data.sizes;
                sizeRow.visible = true;
            } else {
                sizeCombo.model = ["Standard"];
                sizeRow.visible = false;
            }

            sizeCombo.currentIndex = 0;
            spinQuantity.value = 1;
            tfNote.text = "";
            updatePrice();
            open();
        }

        function updatePrice(){
            var extra = 0;
            if (category === "Drink" && itemData && itemData.sizes){
                var sizesList = itemData.sizes;
                var selectedSize = sizeCombo.currentText;
                var sizeIndex = sizeCombo.currentIndex;

                if (sizeIndex > 0){
                    var firstSize = sizesList[0];
                    if (firstSize === "S"){
                        if (selectedSize === "M") extra = 5000;
                        else extra = 10000;
                    }
                    else if(firstSize === "M") if (selectedSize === "L") extra = 5000;
                }
            }
            calculatedPrice = (basePrice + extra) * spinQuantity.value;
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: itemDialog.itemData ? itemDialog.itemData.name : ""
                font.bold: true
                font.pixelSize: 16
                color: "#2C1D11"
            }

            RowLayout {
                id: sizeRow
                Layout.fillWidth: true
                Text { text: "Kích thước (Size):"; font.pixelSize: 13 }
                Item { Layout.fillWidth: true }
                ComboBox {
                    id: sizeCombo
                    onCurrentTextChanged: itemDialog.updatePrice()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Số lượng:"; font.pixelSize: 13 }
                Item { Layout.fillWidth: true }
                SpinBox {
                    id: spinQuantity
                    from: 1
                    to: 99
                    value: 1
                    onValueChanged: itemDialog.updatePrice()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text { text: "Ghi chú (Ít đường/đá, v.v.):"; font.pixelSize: 13 }
                TextField {
                    id: tfNote
                    Layout.fillWidth: true
                    placeholderText: "Nhập ghi chú món ở đây..."
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#E0E0E0" }

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Thành tiền:"; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: formatVND(itemDialog.calculatedPrice)
                    font.bold: true
                    font.pixelSize: 16
                    color: "#8B5A2B"
                }
            }
        }

        onAccepted: {
            cartModel.append({
                "id": itemDialog.itemData.id,
                "name": itemDialog.itemData.name,
                "size": sizeRow.visible ? sizeCombo.currentText : "",
                "quantity": spinQuantity.value,
                "note": tfNote.text,
                "totalPrice": itemDialog.calculatedPrice,
                "category": itemDialog.category
            });
        }
    }
}