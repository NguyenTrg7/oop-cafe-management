import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: orderPageRoot
    anchors.fill: parent

    // -------------------------------------------------------------------------
    // PROPERTIES & MODELS
    // -------------------------------------------------------------------------
    property string selectedVoucherCode: ""
    property double voucherDiscount: 0
    property string selectedCategory: "Drink"

    property string invoiceNumber: ""
    property string invoiceDate: ""
    property string invoiceTime: ""

    // Model giỏ hàng tạm thời
    ListModel {
        id: cartModel
    }

    // -------------------------------------------------------------------------
    // HELPER FUNCTIONS
    // -------------------------------------------------------------------------
    function formatVND(value) {
        if (value === undefined || value === null || isNaN(value)) return "0 VNĐ";
        var num = Math.round(Number(value));
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") + " VNĐ";
    }

    // Hàm chuyển đổi tên món thành tên file ảnh chuẩn
    function getImagePath(itemName, category) {
        if (!itemName) return "";

        var fileName = itemName.toLowerCase()
                               .normalize("NFD")
                               .replace(/[\u0300-\u036f]/g, "")
                               .replace(/[đĐ]/g, "d")
                               .replace(/\s+/g, "_")
                               .replace(/[^a-z0-9_]/g, "");

        var folder = category === "Food" ? "Food" : "Drink";
        return "file:///" + applicationDir + "/data/" + folder + "/" + fileName + ".png";
    }

    // Tính tổng tiền toàn bộ giỏ hàng
    function calculateGrandTotal() {
        var total = 0;
        for (var i = 0; i < cartModel.count; i++) {
            total += cartModel.get(i).totalPrice;
        }
        return total;
    }

    // Tính điểm thưởng Loyalty
    function calculateLoyaltyPoints() {
        var pts = 0;
        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i);
            var qty = item.quantity || 1;
            if (item.category === "Drink") {
                var size = (item.size || "M").toUpperCase();
                var per = 2;
                if (size === "S") per = 1;
                else if (size === "L") per = 3;
                pts += per * qty;
            } else {
                pts += 2 * qty;
            }
        }
        return pts;
    }

    function generateInvoiceNumber() {
        var d = new Date();
        return "HD"
                + d.getFullYear()
                + ("0" + (d.getMonth() + 1)).slice(-2)
                + ("0" + d.getDate()).slice(-2)
                + "-"
                + ("0" + d.getHours()).slice(-2)
                + ("0" + d.getMinutes()).slice(-2)
                + ("0" + d.getSeconds()).slice(-2);
    }

    function updateInvoiceInfo() {
        var d = new Date();
        invoiceNumber = generateInvoiceNumber();
        invoiceDate = ("0" + d.getDate()).slice(-2) + "/" + ("0" + (d.getMonth() + 1)).slice(-2) + "/" + d.getFullYear();
        invoiceTime = ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2) + ":" + ("0" + d.getSeconds()).slice(-2);
    }

    function getMenuData(type) {
        if (typeof coffeeSystem !== "undefined" && coffeeSystem && coffeeSystem.menuManager) {
            return coffeeSystem.menuManager.getMenuByCategory(type);
        }
        return [];
    }

    // -------------------------------------------------------------------------
    // MAIN LAYOUT
    // -------------------------------------------------------------------------
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
            spacing: 12

            // Thanh Tab Chọn Loại Món
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "☕ Đồ uống (Drink)"
                    Layout.fillWidth: true
                    implicitHeight: 42
                    highlighted: orderPageRoot.selectedCategory === "Drink"
                    onClicked: orderPageRoot.selectedCategory = "Drink"
                }

                Button {
                    text: "🍰 Món ăn (Food)"
                    Layout.fillWidth: true
                    implicitHeight: 42
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
                        radius: 10

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12

                            Image {
                                Layout.preferredWidth: 70
                                Layout.preferredHeight: 70
                                source: getImagePath(modelData.name, orderPageRoot.selectedCategory)
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
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            color: "#F9F6F0"
            border.color: "#D8C4B6"
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
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
                    spacing: 6

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 58
                        color: "#FFFFFF"
                        radius: 6
                        border.color: "#E5D8CC"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.name + (model.size ? " (" + model.size + ")" : "") + "  x" + model.quantity
                                    font.bold: true
                                    font.pixelSize: 13
                                    color: "#2C1D11"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.note !== "" ? "Ghi chú: " + model.note : "Không ghi chú"
                                    font.pixelSize: 11
                                    color: "#757575"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: formatVND(model.totalPrice)
                                font.bold: true
                                font.pixelSize: 12
                                color: "#8B5A2B"
                            }

                            Button {
                                implicitWidth: 28
                                implicitHeight: 28
                                flat: true
                                background: Rectangle {
                                    color: parent.hovered ? "#FEE2E2" : "transparent"
                                    radius: 14
                                }
                                contentItem: Text {
                                    text: "🗑️"
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
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

                // CHỌN VOUCHER & HIỂN THỊ GIẢM GIÁ
                ComboBox {
                    id: voucherCombo
                    Layout.fillWidth: true
                    model: {
                        var items = ["Không dùng voucher"];
                        if (typeof customerHandler !== "undefined") {
                            var list = customerHandler.activeVouchers;
                            for (var i = 0; i < list.length; i++)
                                items.push(list[i].code + " (" + list[i].percent + "%)");
                        }
                        return items;
                    }
                    onActivated: {
                        if (currentIndex <= 0) {
                            selectedVoucherCode = "";
                            voucherDiscount = 0;
                        } else if (typeof customerHandler !== "undefined") {
                            var list = customerHandler.activeVouchers;
                            var v = list[currentIndex - 1];
                            selectedVoucherCode = v.code;
                            voucherDiscount = customerHandler.applyVoucher(v.code, calculateGrandTotal());
                        }
                    }
                }

                Text {
                    visible: voucherDiscount > 0
                    text: "Giảm giá: -" + formatVND(voucherDiscount)
                    color: "#15803D"
                    font.bold: true
                    font.pixelSize: 13
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "TỔNG CỘNG:"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#2C1D11"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: formatVND(calculateGrandTotal())
                        font.bold: true
                        font.pixelSize: 14
                        color: "#64748B"
                        font.strikeout: voucherDiscount > 0
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "THANH TOÁN:"
                        font.bold: true
                        font.pixelSize: 15
                        color: "#2C1D11"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: formatVND(Math.max(0, calculateGrandTotal() - voucherDiscount))
                        font.bold: true
                        font.pixelSize: 18
                        color: "#C0392B"
                    }
                }

                // CÁC NÚT THAO TÁC
                Button {
                    text: "💳 THANH TOÁN"
                    Layout.fillWidth: true
                    implicitHeight: 42
                    highlighted: true
                    enabled: cartModel.count > 0

                    onClicked: {
                        updateInvoiceInfo();
                        invoiceDialog.open();

                        var earned = calculateLoyaltyPoints();
                        if (typeof customerHandler !== "undefined" && earned > 0) {
                            customerHandler.addPoints(earned);
                            if (typeof accountHandler !== "undefined")
                                accountHandler.saveCustomerLoyalty();
                            console.log("Tích +" + earned + " điểm");
                        }
                    }
                }

                Button {
                    text: "⭐ Xem điểm Loyalty"
                    Layout.fillWidth: true
                    implicitHeight: 38
                    onClicked: {
                        if (StackView.view)
                            StackView.view.push("LoyaltyPage.qml");
                        else if (typeof stackView !== "undefined")
                            stackView.push("LoyaltyPage.qml");
                    }
                }

                Button {
                    text: "🪑 Xem trạng thái bàn"
                    Layout.fillWidth: true
                    implicitHeight: 38
                    onClicked: {
                        if (StackView.view)
                            StackView.view.push("SeatingPage.qml");
                        else if (typeof stackView !== "undefined")
                            stackView.push("SeatingPage.qml");
                    }
                }
            }
        }
    }

    // =========================================================================
    // DIALOG TÙY CHỌN MÓN
    // =========================================================================
    Dialog {
        id: itemDialog
        modal: true
        focus: true
        width: 480
        height: 520
        padding: 0
        x: (orderPageRoot.width - width) / 2
        y: (orderPageRoot.height - height) / 2

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
            quantityField.text = "1";
            tfNote.text = "";
            updatePrice();
            open();
        }

        function updatePrice() {
            var extra = 0;
            if (category === "Drink" && itemData && itemData.sizes) {
                var list = itemData.sizes;
                var current = sizeCombo.currentText;

                if (sizeCombo.currentIndex > 0) {
                    if (list[0] === "S") {
                        if (current === "M") extra = 5000;
                        else extra = 10000;
                    } else if (list[0] === "M") {
                        if (current === "L") extra = 5000;
                    }
                }
            }

            var quantity = parseInt(quantityField.text);
            if (isNaN(quantity)) quantity = 0;

            calculatedPrice = (basePrice + extra) * quantity;
        }

        background: Rectangle {
            radius: 16
            color: "#FFFDF8"
            border.color: "#E6D6C8"
            border.width: 1
        }

        header: Rectangle {
            height: 80
            color: "transparent"

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text { text: "Tùy chọn món"; color: "#777777"; font.pixelSize: 14 }
                Text {
                    text: itemDialog.itemData ? itemDialog.itemData.name : ""
                    font.pixelSize: 22
                    font.bold: true
                    color: "#3E2723"
                }
            }
        }

        ColumnLayout {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.margins: 20
            spacing: 14

            // Chọn Kích thước (Size)
            Rectangle {
                id: sizeRow
                Layout.fillWidth: true
                height: 52
                radius: 8
                color: "#F8F4EF"
                border.color: "#E8DDD2"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    Text { text: "☕  Kích thước"; font.bold: true; font.pixelSize: 14; color: "#3E2723" }
                    Item { Layout.fillWidth: true }
                    ComboBox {
                        id: sizeCombo
                        implicitWidth: 130
                        onCurrentTextChanged: itemDialog.updatePrice()
                    }
                }
            }

            // Chọn Số lượng
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 8
                color: "#F8F4EF"
                border.color: "#E8DDD2"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    Text { text: "🛒  Số lượng"; font.bold: true; font.pixelSize: 14; color: "#3E2723" }
                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 6

                        Button {
                            text: "−"
                            implicitWidth: 36; implicitHeight: 36
                            onClicked: {
                                var n = parseInt(quantityField.text);
                                if (isNaN(n)) n = 0;
                                quantityField.text = String(Math.max(1, n - 1));
                                itemDialog.updatePrice();
                            }
                        }

                        TextField {
                            id: quantityField
                            text: "1"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            implicitWidth: 45
                            validator: IntValidator { bottom: 1; top: 999 }
                            onTextChanged: itemDialog.updatePrice()
                        }

                        Button {
                            text: "+"
                            implicitWidth: 36; implicitHeight: 36
                            onClicked: {
                                var n = parseInt(quantityField.text);
                                if (isNaN(n)) n = 0;
                                quantityField.text = String(n + 1);
                                itemDialog.updatePrice();
                            }
                        }
                    }
                }
            }

            // Ghi chú
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "📝 Ghi chú"; font.bold: true; font.pixelSize: 14; color: "#3E2723" }

                TextArea {
                    id: tfNote
                    Layout.fillWidth: true
                    Layout.preferredHeight: 75
                    wrapMode: TextArea.Wrap
                    placeholderText: "Nhập ghi chú món ở đây..."
                    background: Rectangle {
                        radius: 8
                        color: "#F8F4EF"
                        border.color: "#E8DDD2"
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#E8DDD2" }

            // Thành tiền tạm tính
            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 10
                color: "#FFF6ED"
                border.color: "#F2D8B8"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    Text { text: "💰 Thành tiền"; font.bold: true; font.pixelSize: 15; color: "#3E2723" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: formatVND(itemDialog.calculatedPrice)
                        font.bold: true
                        font.pixelSize: 22
                        color: "#A45A1D"
                    }
                }
            }
        }

        footer: Rectangle {
            height: 70
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                Item { Layout.fillWidth: true }

                Button {
                    id: cancelButton
                    text: "HỦY"
                    implicitWidth: 110; implicitHeight: 40
                    onClicked: itemDialog.close()
                }

                Button {
                    id: okButton
                    text: "XÁC NHẬN"
                    implicitWidth: 120; implicitHeight: 40
                    highlighted: true
                    onClicked: itemDialog.accept()
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
            NumberAnimation { property: "scale"; from: 0.92; to: 1.0; duration: 180 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "scale"; from: 1; to: 0.92; duration: 150 }
        }

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.92

        onAccepted: {
            var quantity = parseInt(quantityField.text);
            if (isNaN(quantity) || quantity <= 0) {
                quantityField.forceActiveFocus();
                return;
            }

            cartModel.append({
                "id": itemDialog.itemData.id,
                "name": itemDialog.itemData.name,
                "category": itemDialog.category,
                "size": sizeRow.visible ? sizeCombo.currentText : "",
                "quantity": quantity,
                "note": tfNote.text,
                "totalPrice": itemDialog.calculatedPrice
            });

            close();
        }
    }

    // =========================================================================
    // DIALOG HÓA ĐƠN & THANH TOÁN
    // =========================================================================
    Dialog {
        id: invoiceDialog
        modal: true
        width: 600
        height: 660
        anchors.centerIn: parent
        padding: 0

        background: Rectangle {
            color: "#FFFDF9"
            radius: 16
            border.color: "#D8C4B6"
            border.width: 1
        }

        ScrollView {
            id: invoiceScrollView
            anchors.fill: parent
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ColumnLayout {
                width: invoiceScrollView.availableWidth - 10
                spacing: 14

                // Header Quán
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    spacing: 4

                    Text {
                        text: "☕ GIANG'S COFFEE"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#6F4E37"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Cảm ơn Quý khách đã đặt hàng ❤️"
                        color: "#888888"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Thông tin Hóa đơn
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    implicitHeight: 80
                    radius: 8
                    color: "#F9F5EF"
                    border.color: "#E6D8C8"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        Text { text: "🧾  Mã hóa đơn:  " + invoiceNumber; font.bold: true; font.pixelSize: 13; color: "#2C1D11" }
                        Text { text: "📅  Ngày: " + invoiceDate; font.pixelSize: 12; color: "#475569" }
                        Text { text: "🕒  Giờ: " + invoiceTime; font.pixelSize: 12; color: "#475569" }
                    }
                }

                Text {
                    text: "CHI TIẾT ĐƠN HÀNG"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#6F4E37"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Danh sách món trong hóa đơn
                ListView {
                    id: invoiceList
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    implicitHeight: contentHeight
                    interactive: false
                    spacing: 8
                    model: cartModel

                    delegate: Rectangle {
                        width: invoiceList.width
                        implicitHeight: 65
                        radius: 8
                        color: "#FCFAF6"
                        border.color: "#E7DBCF"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            Image {
                                Layout.preferredWidth: 45
                                Layout.preferredHeight: 45
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                source: getImagePath(model.name, model.category ? model.category : orderPageRoot.selectedCategory)

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: "#E0E0E0"
                                    radius: 6
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#E0E0E0"
                                    visible: parent.status === Image.Error || parent.status === Image.Null
                                    radius: 6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📷"
                                        font.pixelSize: 16
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: name + (size !== "" ? " (" + size + ")" : "")
                                    font.bold: true
                                    font.pixelSize: 13
                                    color: "#2C1D11"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text { text: "Số lượng: " + quantity; font.pixelSize: 11; color: "#666666" }

                                Text {
                                    visible: note !== ""
                                    text: "📝 " + note
                                    color: "#888888"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: formatVND(totalPrice)
                                font.bold: true
                                font.pixelSize: 13
                                color: "#8B5A2B"
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                // Dòng voucher
                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    visible: voucherDiscount > 0
                    text: "Voucher " + selectedVoucherCode + ":  -" + formatVND(voucherDiscount)
                    font.pixelSize: 13
                    font.bold: true
                    color: "#15803D"
                }

                // Tổng thanh toán
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    radius: 10
                    color: "#FFF7ED"
                    border.color: "#F2D9B6"
                    implicitHeight: 52

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12

                        Text { text: "💰 Tổng thanh toán"; font.bold: true; font.pixelSize: 15; color: "#6F4E37" }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: formatVND(Math.max(0, calculateGrandTotal() - voucherDiscount))
                            font.bold: true
                            font.pixelSize: 18
                            color: "#B45309"
                        }
                    }
                }

                // Khu vực Mã QR
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    implicitHeight: 130
                    radius: 12
                    color: "#FAF8F4"
                    border.color: "#E6D8C8"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 15

                        Image {
                            Layout.preferredWidth: 105
                            Layout.preferredHeight: 105
                            fillMode: Image.PreserveAspectFit
                            source: "file:///" + applicationDir + "/data/ma_qr.jpg"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 4

                            Text {
                                text: "Quét mã QR để thanh toán"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#6F4E37"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Sử dụng ứng dụng Ngân hàng hoặc Ví điện tử để quét mã."
                                font.pixelSize: 12
                                color: "#666666"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Cảm ơn Quý khách! ❤️"
                                font.pixelSize: 12
                                font.italic: true
                                color: "#8B5A2B"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Các nút tác vụ hóa đơn
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.bottomMargin: 20
                    spacing: 12

                    Item { Layout.fillWidth: true }

                    Button {
                        id: invoiceCancelButton
                        text: "Đóng"
                        implicitWidth: 110; implicitHeight: 40
                        onClicked: invoiceDialog.close()
                    }

                    Button {
                        id: finishButton
                        text: "🖨️ In Hóa Đơn"
                        implicitWidth: 150; implicitHeight: 40
                        highlighted: true

                        onClicked: {
                            console.log("Đã thanh toán hóa đơn " + invoiceNumber);

                            if (selectedVoucherCode !== "" && typeof customerHandler !== "undefined") {
                                customerHandler.useVoucher(selectedVoucherCode);
                                if (typeof accountHandler !== "undefined")
                                    accountHandler.saveCustomerLoyalty();
                            }

                            selectedVoucherCode = "";
                            voucherDiscount = 0;
                            if (typeof voucherCombo !== "undefined")
                                voucherCombo.currentIndex = 0;

                            cartModel.clear();
                            invoiceDialog.close();
                        }
                    }
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
            NumberAnimation { property: "scale"; from: 0.92; to: 1.0; duration: 180 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "scale"; from: 1; to: 0.92; duration: 150 }
        }

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.92
    }
}