import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: orderPageRoot
    anchors.fill: parent

    property string selectedVoucherCode: ""
    property double voucherDiscount: 0
    property string selectedCategory: "Drink"

    ListModel { id: cartModel }
    ListModel { id: phoneVoucherModel }   // voucher theo SĐT

    function formatVND(value) {
        value = Math.round(Number(value));
        return Qt.locale("vi_VN").toString(value) + " VNĐ";
    }

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

    function calculateGrandTotal() {
        var total = 0;
        for (var i = 0; i < cartModel.count; i++) {
            total += cartModel.get(i).totalPrice;
        }
        return total;
    }

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

    property string invoiceNumber: ""
    property string invoiceDate: ""
    property string invoiceTime: ""

    function generateInvoiceNumber() {
        var d = new Date()
        return "HD" + d.getFullYear()
                + ("0"+(d.getMonth()+1)).slice(-2)
                + ("0"+d.getDate()).slice(-2)
                + "-"
                + ("0"+d.getHours()).slice(-2)
                + ("0"+d.getMinutes()).slice(-2)
                + ("0"+d.getSeconds()).slice(-2)
    }

    function updateInvoiceInfo() {
        var d = new Date()
        invoiceNumber = generateInvoiceNumber()
        invoiceDate = ("0"+d.getDate()).slice(-2) + "/" + ("0"+(d.getMonth()+1)).slice(-2) + "/" + d.getFullYear()
        invoiceTime = ("0"+d.getHours()).slice(-2) + ":" + ("0"+d.getMinutes()).slice(-2) + ":" + ("0"+d.getSeconds()).slice(-2)
    }

    function getMenuData(type) {
        if (typeof coffeeSystem !== "undefined" && coffeeSystem && coffeeSystem.menuManager) {
            return coffeeSystem.menuManager.getMenuByCategory(type);
        }
        return [];
    }

    // ====================== GIAO DIỆN CHÍNH ======================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // CỘT TRÁI - MENU
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

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
                        anchors.fill: parent
                        anchors.margins: 5
                        color: mouseArea.containsMouse ? "#F2EBE1" : "#FFFDF9"
                        border.color: mouseArea.containsMouse ? "#8B5A2B" : "#D8C4B6"
                        border.width: mouseArea.containsMouse ? 2 : 1
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

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
                                    Text { anchors.centerIn: parent; text: "📷"; font.pixelSize: 20 }
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
                            onClicked: itemDialog.openDialog(modelData, orderPageRoot.selectedCategory)
                        }
                    }
                }
            }
        }

        // CỘT PHẢI - GIỎ HÀNG (đã bỏ voucher)
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

                Rectangle { Layout.fillWidth: true; height: 1; color: "#D8C4B6" }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "TỔNG CỘNG:"; font.bold: true; font.pixelSize: 15; color: "#2C1D11" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: formatVND(calculateGrandTotal())
                        font.bold: true
                        font.pixelSize: 16
                        color: "#C0392B"
                    }
                }

                Button {
                    text: "THANH TOÁN"
                    Layout.fillWidth: true
                    implicitHeight: 42
                    highlighted: true
                    enabled: cartModel.count > 0
                    onClicked: {
                        updateInvoiceInfo()
                        phoneVoucherModel.clear()
                        selectedVoucherCode = ""
                        voucherDiscount = 0
                        invoiceDialog.open()
                    }
                }

                Button {
                    text: "⭐ Xem điểm Loyalty"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        if (StackView.view) StackView.view.push("LoyaltyPage.qml")
                        else if (typeof stackView !== "undefined") stackView.push("LoyaltyPage.qml")
                    }
                }

                Button {
                    text: "🪑 Xem trạng thái bàn"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        if (StackView.view) StackView.view.push("SeatingPage.qml")
                        else if (typeof stackView !== "undefined") stackView.push("SeatingPage.qml")
                    }
                }
            }
        }
    }

    // ====================== DIALOG TÙY CHỌN MÓN ======================
    Dialog {
        id: itemDialog
        modal: true
        focus: true
        width: 520
        height: 560
        padding: 0
        x: (orderPageRoot.width - width) / 2
        y: (orderPageRoot.height - height) / 2

        property var itemData: null
        property string category: "Drink"
        property real basePrice: 0
        property real calculatedPrice: 0

        function openDialog(data, cat) {
            itemData = data
            category = cat
            basePrice = Number(data.price || 0)
            if (cat === "Drink" && data.sizes && data.sizes.length > 0) {
                sizeCombo.model = data.sizes
                sizeRow.visible = true
            } else {
                sizeCombo.model = ["Standard"]
                sizeRow.visible = false
            }
            sizeCombo.currentIndex = 0
            quantityField.text = "1"
            tfNote.text = ""
            updatePrice()
            open()
        }

        function updatePrice() {
            var extra = 0
            if (category === "Drink" && itemData && itemData.sizes) {
                var list = itemData.sizes
                var current = sizeCombo.currentText
                if (sizeCombo.currentIndex > 0) {
                    if (list[0] === "S") {
                        if (current === "M") extra = 5000
                        else extra = 10000
                    } else if (list[0] === "M") {
                        if (current === "L") extra = 5000
                    }
                }
            }
            var quantity = parseInt(quantityField.text)
            if (isNaN(quantity)) quantity = 0
            calculatedPrice = (basePrice + extra) * quantity
        }

        background: Rectangle { radius: 20; color: "#FFFDF8"; border.color: "#E6D6C8" }

        header: Rectangle {
            height: 95
            color: "transparent"
            Column {
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Text { text: "Tùy chọn món"; color: "#777"; font.pixelSize: 17 }
                Text {
                    text: itemDialog.itemData ? itemDialog.itemData.name : ""
                    font.pixelSize: 30
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
            spacing: 18

            Rectangle {
                id: sizeRow
                Layout.fillWidth: true
                height: 60
                radius: 8
                color: "#F8F4EF"
                border.color: "#E8DDD2"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    Text { text: "☕  Kích thước"; font.bold: true; font.pixelSize: 15 }
                    Item { Layout.fillWidth: true }
                    ComboBox {
                        id: sizeCombo
                        implicitWidth: 130
                        onCurrentTextChanged: itemDialog.updatePrice()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 12
                color: "#F8F4EF"
                border.color: "#E8DDD2"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    Text { text: "🛒  Số lượng"; font.bold: true; font.pixelSize: 15 }
                    Item { Layout.fillWidth: true }
                    RowLayout {
                        spacing: 8
                        Button {
                            text: "−"
                            implicitWidth: 40
                            implicitHeight: 40
                            onClicked: {
                                var n = parseInt(quantityField.text)
                                if (isNaN(n)) n = 0
                                quantityField.text = String(Math.max(0, n-1))
                                itemDialog.updatePrice()
                            }
                        }
                        TextField {
                            id: quantityField
                            text: "1"
                            horizontalAlignment: Text.AlignHCenter
                            implicitWidth: 45
                            validator: IntValidator { bottom: 0; top: 999 }
                            onTextChanged: itemDialog.updatePrice()
                        }
                        Button {
                            text: "+"
                            implicitWidth: 40
                            implicitHeight: 40
                            onClicked: {
                                var n = parseInt(quantityField.text)
                                if (isNaN(n)) n = 0
                                quantityField.text = String(n+1)
                                itemDialog.updatePrice()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Text { text: "📝 Ghi chú"; font.bold: true; font.pixelSize: 15 }
                TextArea {
                    id: tfNote
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    wrapMode: TextArea.Wrap
                    placeholderText: "Nhập ghi chú món ở đây..."
                    background: Rectangle { radius: 12; color: "#F8F4EF"; border.color: "#E8DDD2" }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 70
                radius: 14
                color: "#FFF6ED"
                border.color: "#F2D8B8"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    Text { text: "💰 Thành tiền"; font.bold: true; font.pixelSize: 17 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: formatVND(itemDialog.calculatedPrice)
                        font.bold: true
                        font.pixelSize: 28
                        color: "#A45A1D"
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }

        footer: Rectangle {
            height: 90
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                Item { Layout.fillWidth: true }
                Button {
                    text: "HỦY"
                    implicitWidth: 120
                    implicitHeight: 45
                    onClicked: itemDialog.close()
                }
                Button {
                    text: "XÁC NHẬN"
                    implicitWidth: 120
                    implicitHeight: 45
                    onClicked: itemDialog.accept()
                    background: Rectangle {
                        radius: 12
                        color: parent.down ? "#8A4F22" : (parent.hovered ? "#A5622E" : "#9B5D2F")
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        onAccepted: {
            var quantity = parseInt(quantityField.text)
            if (isNaN(quantity) || quantity <= 0) {
                quantityField.forceActiveFocus()
                return
            }
            cartModel.append({
                "id": itemDialog.itemData.id,
                "name": itemDialog.itemData.name,
                "category": itemDialog.category,
                "size": sizeRow.visible ? sizeCombo.currentText : "",
                "quantity": quantity,
                "note": tfNote.text,
                "totalPrice": itemDialog.calculatedPrice
            })
            close()
        }
    }

    // ====================== INVOICE DIALOG (ĐÃ THÊM SĐT + VOUCHER) ======================
    Dialog {
        id: invoiceDialog
        modal: true
        width: 620
        height: 720
        anchors.centerIn: parent
        padding: 0

        background: Rectangle {
            color: "#FFFDF9"
            radius: 18
            border.color: "#D8C4B6"
        }

        function loadVouchersForPhone(phone) {
            phoneVoucherModel.clear()
            selectedVoucherCode = ""
            voucherDiscount = 0

            if (!phone || !/^0\d{9}$/.test(phone) || typeof customerHandler === "undefined")
                return

            customerHandler.loadByPhone(phone)
            var list = customerHandler.activeVouchers || []

            for (var i = 0; i < list.length; i++) {
                var v = list[i]
                phoneVoucherModel.append({
                    code: v.code || "",
                    percent: v.percent || 0,
                    display: (v.code || "") + " (" + (v.percent || 0) + "%)"
                })
            }
        }

        ScrollView {
            anchors.fill: parent
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: invoiceDialog.availableWidth - 20
                spacing: 14

                // Header
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    spacing: 4
                    Text {
                        text: "☕ GIANG'S COFFEE"
                        font.pixelSize: 26
                        font.bold: true
                        color: "#6F4E37"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Thank you for your order ❤️"
                        color: "#888"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // ===== NHẬP SỐ ĐIỆN THOẠI + CHỌN VOUCHER =====
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    radius: 12
                    color: "#F0FDF4"
                    border.color: "#86EFAC"
                    implicitHeight: 130

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "📱 Số điện thoại tích điểm & dùng voucher"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#166534"
                        }

                        TextField {
                            id: invoicePhoneInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            placeholderText: "Nhập SĐT (để trống nếu không tích điểm)"
                            inputMethodHints: Qt.ImhDigitsOnly
                            font.pixelSize: 14
                            background: Rectangle {
                                radius: 8
                                color: "white"
                                border.color: parent.activeFocus ? "#16A34A" : "#BBF7D0"
                            }
                            validator: RegularExpressionValidator { regularExpression: /0\d{0,9}/ }

                            onTextChanged: {
                                if (text.length === 10)
                                    invoiceDialog.loadVouchersForPhone(text.trim())
                                else {
                                    phoneVoucherModel.clear()
                                    selectedVoucherCode = ""
                                    voucherDiscount = 0
                                }
                            }
                        }

                        ComboBox {
                            id: invoiceVoucherCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            enabled: phoneVoucherModel.count > 0
                            model: phoneVoucherModel
                            textRole: "display"

                            displayText: {
                                if (phoneVoucherModel.count === 0)
                                    return invoicePhoneInput.text.length === 10 ? "Không có voucher" : "Nhập SĐT để xem voucher"
                                if (currentIndex < 0) return "— Chọn voucher (nếu có) —"
                                return phoneVoucherModel.get(currentIndex).display
                            }

                            onActivated: {
                                if (currentIndex >= 0) {
                                    var item = phoneVoucherModel.get(currentIndex)
                                    selectedVoucherCode = item.code
                                    voucherDiscount = customerHandler.applyVoucher(item.code, calculateGrandTotal())
                                } else {
                                    selectedVoucherCode = ""
                                    voucherDiscount = 0
                                }
                            }
                        }
                    }
                }

                // Thông tin hóa đơn
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    implicitHeight: 80
                    radius: 10
                    color: "#F9F5EF"
                    border.color: "#E6D8C8"
                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4
                        Text { text: "🧾  Mã hóa đơn:  " + invoiceNumber; font.bold: true; font.pixelSize: 13 }
                        Text { text: "📅  Ngày: " + invoiceDate; font.pixelSize: 12 }
                        Text { text: "🕒  Giờ: " + invoiceTime; font.pixelSize: 12 }
                    }
                }

                Text {
                    text: "CHI TIẾT ĐƠN HÀNG"
                    font.bold: true
                    font.pixelSize: 15
                    color: "#6F4E37"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Danh sách món
                ListView {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    implicitHeight: contentHeight
                    interactive: false
                    spacing: 8
                    model: cartModel

                    delegate: Rectangle {
                        width: ListView.view.width
                        implicitHeight: 70
                        radius: 10
                        color: "#FCFAF6"
                        border.color: "#E7DBCF"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            Image {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 50
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                source: getImagePath(model.name, model.category || orderPageRoot.selectedCategory)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: name + (size !== "" ? " (" + size + ")" : "")
                                    font.bold: true
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                                Text { text: "SL: " + quantity; font.pixelSize: 11; color: "#666" }
                            }

                            Text {
                                text: formatVND(totalPrice)
                                font.bold: true
                                font.pixelSize: 13
                                color: "#8B5A2B"
                            }
                        }
                    }
                }

                // Tổng tiền
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    radius: 12
                    color: "#FFF7ED"
                    border.color: "#F2D9B6"
                    implicitHeight: voucherDiscount > 0 ? 90 : 55

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        RowLayout {
                            visible: voucherDiscount > 0
                            Layout.fillWidth: true
                            Text { text: "Giảm giá voucher"; color: "#15803D"; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Text { text: "−" + formatVND(voucherDiscount); color: "#15803D"; font.bold: true }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "💰 Tổng thanh toán"
                                font.bold: true
                                font.pixelSize: 15
                                color: "#6F4E37"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: formatVND(Math.max(0, calculateGrandTotal() - voucherDiscount))
                                font.bold: true
                                font.pixelSize: 20
                                color: "#B45309"
                            }
                        }
                    }
                }

                // QR
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    implicitHeight: 130
                    radius: 14
                    color: "#FAF8F4"
                    border.color: "#E6D8C8"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 14
                        Image {
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 110
                            fillMode: Image.PreserveAspectFit
                            source: "file:///" + applicationDir + "/data/ma_qr.jpg"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text {
                                text: "Quét mã QR để thanh toán"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#6F4E37"
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: "Sử dụng app ngân hàng hoặc ví điện tử."
                                font.pixelSize: 12
                                color: "#666"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // Nút
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.bottomMargin: 20
                    spacing: 12
                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Đóng"
                        implicitWidth: 110
                        implicitHeight: 40
                        onClicked: invoiceDialog.close()
                    }

                    Button {
                        text: "In Hóa Đơn"
                        implicitWidth: 170
                        implicitHeight: 40
                        highlighted: true

                        onClicked: {
                            var phone = invoicePhoneInput.text.trim()

                            // Dùng voucher
                            if (selectedVoucherCode !== "" && typeof customerHandler !== "undefined") {
                                customerHandler.useVoucher(selectedVoucherCode)
                                customerHandler.save()
                            }

                            // Tích điểm (chỉ khi có SĐT hợp lệ)
                            if (phone !== "" && /^0\d{9}$/.test(phone)) {
                                var earned = calculateLoyaltyPoints()
                                if (earned > 0 && typeof customerHandler !== "undefined") {
                                    customerHandler.loadByPhone(phone)
                                    customerHandler.addPoints(earned)
                                    customerHandler.save()
                                }
                            }

                            // Reset
                            selectedVoucherCode = ""
                            voucherDiscount = 0
                            phoneVoucherModel.clear()
                            cartModel.clear()
                            invoiceDialog.close()
                        }
                    }
                }
            }
        }
    }
}