import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: orderPageRoot
    anchors.fill: parent

    property string selectedVoucherCode: ""
    property double voucherDiscount: 0
    property string selectedCategory: "Drink"
    property int maxAllowedQuantity: itemData ? (itemData.maxStock !== undefined ? itemDialog.maxStock : 999) : 999

    property bool showingInventory: false
    property bool showingHistory: false
    property var fullMenuData: []

    function filterMenu() {
        var source = getMenuData(orderPageRoot.selectedCategory)
        var keyword = searchField.text.trim().toLowerCase()
        var cat = categoryFilter.currentText

        var result = []
        for (var i = 0; i < source.length; i++) {
            var item = source[i]
            var matchName = keyword === "" || item.name.toLowerCase().indexOf(keyword) !== -1
            var matchCat  = cat === "Tất cả" || item.category === cat

            if (matchName && matchCat)
                result.push(item)
        }
        menuGrid.model = result
    }

    // Model giỏ hàng tạm thời
    ListModel {
        id: cartModel
    }

    function formatVND(value) {
        value = Math.round(Number(value));
        return Qt.locale("vi_VN").toString(value) + " VNĐ";
    }

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

    //Bill
    property string invoiceNumber: ""
    property string invoiceDate: ""
    property string invoiceTime: ""

    function generateInvoiceNumber()
    {
        var d = new Date()

        return "HD"
                + d.getFullYear()
                + ("0"+(d.getMonth()+1)).slice(-2)
                + ("0"+d.getDate()).slice(-2)
                + "-"
                + ("0"+d.getHours()).slice(-2)
                + ("0"+d.getMinutes()).slice(-2)
                + ("0"+d.getSeconds()).slice(-2)
    }

    function updateInvoiceInfo()
    {
        var d = new Date()

        invoiceNumber = generateInvoiceNumber()

        invoiceDate =
                ("0"+d.getDate()).slice(-2)
                + "/"
                + ("0"+(d.getMonth()+1)).slice(-2)
                + "/"
                + d.getFullYear()

        invoiceTime =
                ("0"+d.getHours()).slice(-2)
                + ":"
                + ("0"+d.getMinutes()).slice(-2)
                + ":"
                + ("0"+d.getSeconds()).slice(-2)
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
        anchors.margins: 12
        spacing: 12

        // =====================================================================
        // 1. SIDEBAR DỌC BÊN TRÁI
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            color: "#F9F6F0"
            border.color: "#E0D5C8"
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "MENU"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#8D6E63"
                    Layout.bottomMargin: 6
                }

                // Nút Đồ uống
                Button {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: "☕  Đồ uống"
                    checkable: true
                    checked: orderPageRoot.selectedCategory === "Drink" && !showingInventory && !showingHistory
                    onClicked: {
                        showingInventory = false
                        showingHistory = false
                        orderPageRoot.selectedCategory = "Drink"
                        menuGrid.model = getMenuData("Drink")
                    }
                }

                // Nút Món ăn
                Button {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: "🍰  Món ăn"
                    checkable: true
                    checked: orderPageRoot.selectedCategory === "Food" && !showingInventory && !showingHistory
                    onClicked: {
                        showingInventory = false
                        showingHistory = false
                        orderPageRoot.selectedCategory = "Food"
                        menuGrid.model = getMenuData("Food")
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#E0D5C8"; Layout.topMargin: 8; Layout.bottomMargin: 8 }

                // Nút Quản lý tồn kho
                Button {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: "📦  Tồn kho"
                    checkable: true
                    checked: showingInventory
                    onClicked: {
                        showingInventory = true
                        showingHistory = false
                    }
                }

                // Nút Lịch sử đơn hàng
                Button {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: "📜  Lịch sử"
                    checkable: true
                    checked: showingHistory
                    onClicked: {
                        showingHistory = true
                        showingInventory = false
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // =====================================================================
        // 2. KHU VỰC GIỮA (Menu / Tồn kho / Lịch sử)
        // =====================================================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ========== A. MENU ĐỒ UỐNG / MÓN ĂN ==========
            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                visible: !showingInventory && !showingHistory

                // Thanh tìm kiếm + lọc
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "🔍  Tìm món theo tên..."
                        selectByMouse: true
                        onTextChanged: filterMenu()
                    }

                    ComboBox {
                        id: categoryFilter
                        Layout.preferredWidth: 180
                        model: orderPageRoot.selectedCategory === "Drink"
                               ? ["Tất cả", "Cà phê", "Cà phê pha máy", "Trà trái cây", "Trà sữa", "Đá xay", "Nước ép", "Cacao"]
                               : ["Tất cả", "Bánh ngọt", "Bánh mặn", "Pizza", "Sandwich", "Đồ ăn vặt", "Salad", "Món chính", "Combo"]
                        onCurrentTextChanged: filterMenu()
                    }
                }

                // Grid món
                GridView {
                    id: menuGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: Math.floor(width / 2) - 4
                    cellHeight: 100
                    model: getMenuData(orderPageRoot.selectedCategory)

                    delegate: Item {
                        width: menuGrid.cellWidth
                        height: menuGrid.cellHeight

                        property bool isAvailable: modelData.isAvailable !== undefined ? modelData.isAvailable : true
                        property int maxStock: modelData.maxStock !== undefined ? modelData.maxStock : 999

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            color: !isAvailable ? "#E0E0E0" : (mouseArea.containsMouse ? "#F2EBE1" : "#FFFDF9")
                            border.color: !isAvailable ? "#B0BEC5" : (mouseArea.containsMouse ? "#8B5A2B" : "#D8C4B6")
                            radius: 10
                            opacity: isAvailable ? 1.0 : 0.6

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                Image {
                                    Layout.preferredWidth: 64
                                    Layout.preferredHeight: 64
                                    source: getImagePath(modelData.name, orderPageRoot.selectedCategory)
                                    fillMode: Image.PreserveAspectCrop
                                    clip: true
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        text: modelData.name || ""
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: isAvailable ? "#2C1D11" : "#757575"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: formatVND(modelData.price)
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: isAvailable ? "#8B5A2B" : "#757575"
                                    }

                                    Rectangle {
                                        visible: !isAvailable || maxStock <= 5
                                        implicitWidth: lblStock.implicitWidth + 8
                                        implicitHeight: 18
                                        radius: 4
                                        color: !isAvailable ? "#D32F2F" : "#E65100"

                                        Text {
                                            id: lblStock
                                            anchors.centerIn: parent
                                            text: !isAvailable ? "HẾT HÀNG" : ("Còn " + maxStock)
                                            color: "white"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                enabled: isAvailable
                                hoverEnabled: true
                                cursorShape: isAvailable ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                                onClicked: itemDialog.openDialog(modelData, orderPageRoot.selectedCategory)
                            }
                        }
                    }
                }
            }

            // ========== B. TRANG TỒN KHO ==========
            Loader {
                id: inventoryLoader
                anchors.fill: parent
                active: showingInventory
                visible: showingInventory
                source: showingInventory ? Qt.resolvedUrl("InventoryPage.qml") : ""

                onStatusChanged: {
                    if (status === Loader.Error)
                        console.error("Không load được InventoryPage.qml")
                    else if (status === Loader.Ready)
                        console.log("InventoryPage đã load xong")
                }
            }

            // ========== C. TRANG LỊCH SỬ ==========
            Loader {
                id: historyLoader
                anchors.fill: parent
                active: showingHistory
                visible: showingHistory
                source: showingHistory ? Qt.resolvedUrl("OrderHistoryPage.qml") : ""

                onStatusChanged: {
                    if (status === Loader.Error)
                        console.error("Không load được OrderHistoryPage.qml")
                    else if (status === Loader.Ready)
                        console.log("OrderHistoryPage đã load xong")
                }
            }
        }

        // =====================================================================
        // CỘT BÊN PHẢI: GIỎ HÀNG & TỔNG TIỀN ĐƠN HÀNG
        // Ẩn khi đang xem Tồn kho hoặc Lịch sử để không đè lên
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: (showingInventory || showingHistory) ? 0 : 320
            Layout.fillHeight: true
            visible: !showingInventory && !showingHistory
            color: "#F9F6F0"
            border.color: "#D8C4B6"
            radius: 12
            clip: true

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
                        height: colCart.implicitHeight + 16
                        color: "#FFFFFF"
                        radius: 4
                        border.color: "#E0E0E0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            ColumnLayout {
                                id: colCart
                                Layout.fillWidth: true
                                spacing: 2

                                // Tên + size + số lượng
                                Text {
                                    text: model.name + (model.size ? " (" + model.size + ")" : "") + " x" + model.quantity
                                    font.bold: true
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Mức đá
                                Text {
                                    visible: model.ice && model.ice !== "" && model.ice !== "Bình thường"
                                    text: "🧊 " + model.ice
                                    font.pixelSize: 11
                                    color: "#0277BD"
                                }

                                // Topping
                                Text {
                                    visible: model.toppings && model.toppings !== "" && model.toppings !== "undefined"
                                    text: "🍒 " + model.toppings
                                    font.pixelSize: 11
                                    color: "#6A1B9A"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Ghi chú
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
                ComboBox {
                    id: voucherCombo
                    Layout.fillWidth: true
                    model: {
                        var items = ["Không dùng voucher"]
                        if (typeof customerHandler !== "undefined") {
                            var list = customerHandler.activeVouchers
                            for (var i = 0; i < list.length; i++)
                                items.push(list[i].code + " (" + list[i].percent + "%)")
                        }
                        return items
                    }
                    onActivated: {
                        if (currentIndex <= 0) {
                            selectedVoucherCode = ""
                            voucherDiscount = 0
                        } else if (typeof customerHandler !== "undefined") {
                            var list = customerHandler.activeVouchers
                            var v = list[currentIndex - 1]
                            selectedVoucherCode = v.code
                            voucherDiscount = customerHandler.applyVoucher(v.code, calculateGrandTotal())
                        }
                    }
                }

                Text {
                    visible: voucherDiscount > 0
                    text: "Giảm giá: " + formatVND(voucherDiscount)
                    color: "#2E7D32"
                    font.bold: true
                    font.pixelSize: 13
                }

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
                        font.pixelSize: 14
                        color: "#757575"
                        font.strikeout: voucherDiscount > 0
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: true

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

                Button {
                    text: "THANH TOÁN"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    highlighted: true
                    enabled: cartModel.count > 0

                    onClicked: {
                        updateInvoiceInfo()

                        var items = []
                        for (var i = 0; i < cartModel.count; i++) {
                            var it = cartModel.get(i)

                            var tops = []
                            if (it.toppings && it.toppings.length > 0) {
                                for (var t = 0; t < it.toppings.length; t++) {
                                    tops.push({
                                        name: it.toppings[t].name || "",
                                        price: it.toppings[t].price || 0
                                    })
                                }
                            }

                            items.push({
                                id: it.id || "",
                                name: it.name || "",
                                size: it.size || "",
                                quantity: it.quantity || 1,
                                note: it.note || "",
                                totalPrice: it.totalPrice || 0,
                                category: it.category || "Drink",
                                ice: it.ice || "",
                                toppings: it.toppings || ""
                            })
                        }

                        invoiceDialog.openWith({
                            invoiceNumber: invoiceNumber,
                            date: invoiceDate,
                            time: invoiceTime,
                            customerName: "Khách vãng lai",
                            totalAmount: Math.max(0, calculateGrandTotal() - voucherDiscount),
                            discount: voucherDiscount,
                            voucherCode: selectedVoucherCode,
                            items: items
                        })
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
    // DIALOG TÙY CHỌN MÓN (giao diện mới – dễ nhìn, hiện đại)
    // =========================================================================
    Dialog {
        id: itemDialog
        modal: true
        focus: true
        width: 540
        height: 680
        padding: 0
        x: (orderPageRoot.width - width) / 2
        y: (orderPageRoot.height - height) / 2

        property var itemData: null
        property string category: "Drink"
        property real basePrice: 0
        property real calculatedPrice: 0
        property int maxAllowedQuantity: 999
        property string selectedSize: "S"
        property string selectedIce: "Bình thường"
        property var availableSizes: ["S", "M", "L"]
        property int quantityValue: 1

        // ===== HÀM MỞ DIALOG =====
        function openDialog(data, cat) {
            itemData = data
            category = cat
            basePrice = Number(data.price || 0)

            // Size
            if (cat === "Drink" && data.sizes && data.sizes.length > 0) {
                availableSizes = data.sizes
                sizeSection.visible = true
                selectedSize = data.sizes[0]
            } else {
                availableSizes = ["Standard"]
                sizeSection.visible = false
                selectedSize = "Standard"
            }

            // Lấy tồn kho mới nhất từ IngredientManager
            var maxStock = 999
            if (typeof ingredientManager !== "undefined" && ingredientManager) {
                var sz = selectedSize || "M"
                maxStock = ingredientManager.getMaxServings(data.id, sz)
            } else if (data.maxStock !== undefined && data.maxStock !== null) {
                maxStock = Number(data.maxStock)
            }

            // Hết hàng → không mở dialog
            if (maxStock <= 0) {
                console.warn("Hết hàng:", data.name)
                // Có thể hiện thông báo ở đây
                return
            }

            maxAllowedQuantity = Math.max(1, maxStock)
            quantityValue = 1
            if (typeof quantityField !== "undefined" && quantityField)
                quantityField.text = "1"

            tfNote.text = ""
            selectedIce = "Bình thường"

            // Reset topping
            for (var i = 0; i < toppingRepeater.count; i++) {
                if (toppingRepeater.itemAt(i))
                    toppingRepeater.itemAt(i).checked = false
            }

            updatePrice()
            open()
        }

        function updatePrice() {
            var extra = 0

            // Phụ thu size
            if (category === "Drink" && itemData && itemData.sizes) {
                var list = itemData.sizes
                var current = selectedSize
                if (list[0] === "S") {
                    if (current === "M") extra = 5000
                    else if (current === "L") extra = 10000
                } else if (list[0] === "M") {
                    if (current === "L") extra = 5000
                }
            }

            // Cộng tiền topping
            var toppingExtra = 0
            for (var i = 0; i < toppingRepeater.count; i++) {
                var btn = toppingRepeater.itemAt(i)
                if (btn && btn.checked)
                    toppingExtra += btn.toppingPrice
            }

            calculatedPrice = (basePrice + extra + toppingExtra) * quantityValue
        }

        background: Rectangle {
            radius: 24
            color: "#FFFCFA"
            border.color: "#E8DDD2"
            border.width: 1
        }

        // ===== HEADER =====
        header: Rectangle {
            height: 96
            color: "transparent"

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: "Tùy chọn món"
                    color: "#A1887F"
                    font.pixelSize: 13
                    font.letterSpacing: 0.5
                }
                Text {
                    text: itemDialog.itemData ? itemDialog.itemData.name : ""
                    font.pixelSize: 26
                    font.bold: true
                    color: "#3E2723"
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                height: 1
                color: "#EFE6DC"
            }
        }

        // ===== NỘI DUNG CHÍNH (dùng contentItem để Dialog layout đúng) =====
        contentItem: Flickable {
            id: contentFlick
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: contentColumn.implicitHeight + 32
            contentWidth: width

            ColumnLayout {
                id: contentColumn
                width: contentFlick.width - 48
                x: 24
                y: 16
                spacing: 18

                // ─── 1. KÍCH THƯỚC (pill buttons) ───
                ColumnLayout {
                    id: sizeSection
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "☕  Kích thước"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    Row {
                        spacing: 10

                        Repeater {
                            model: itemDialog.availableSizes

                            delegate: Rectangle {
                                width: 72
                                height: 44
                                radius: 12
                                color: itemDialog.selectedSize === modelData ? "#6D4C41" : "#F5F0EB"
                                border.color: itemDialog.selectedSize === modelData ? "#6D4C41" : "#E0D5C8"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.bold: true
                                    font.pixelSize: 16
                                    color: itemDialog.selectedSize === modelData ? "white" : "#5D4037"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        itemDialog.selectedSize = modelData

                                        // Cập nhật tồn kho theo size mới
                                        if (typeof ingredientManager !== "undefined" && ingredientManager && itemDialog.itemData) {
                                            itemDialog.maxAllowedQuantity =
                                                ingredientManager.getMaxServings(itemDialog.itemData.id, modelData)

                                            // Nếu số lượng đang chọn vượt tồn → cắt xuống
                                            if (itemDialog.quantityValue > itemDialog.maxAllowedQuantity) {
                                                itemDialog.quantityValue = Math.max(1, itemDialog.maxAllowedQuantity)
                                            }
                                        }

                                        itemDialog.updatePrice()
                                    }
                                }
                            }
                        }
                    }
                }

                // ─── 2. SỐ LƯỢNG (stepper to rõ) ───
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "🛒  Số lượng"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    Row {
                        spacing: 0

                        // Nút −
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 14
                            color: itemDialog.quantityValue <= 1 ? "#F0EBE6" : "#EFEBE9"
                            border.color: "#D7CCC8"

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 22
                                font.bold: true
                                color: itemDialog.quantityValue <= 1 ? "#BCAAA4" : "#5D4037"
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: itemDialog.quantityValue > 1
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (itemDialog.quantityValue > 1) {
                                        itemDialog.quantityValue--
                                        itemDialog.updatePrice()
                                    }
                                }
                            }
                        }

                        // Ô số lượng — cho phép nhập bàn phím
                        TextField {
                            id: quantityField
                            width: 64
                            height: 48
                            text: "" + itemDialog.quantityValue
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 20
                            font.bold: true
                            color: "#3E2723"
                            selectByMouse: true
                            validator: IntValidator { bottom: 1; top: 999 }
                            inputMethodHints: Qt.ImhDigitsOnly

                            background: Rectangle {
                                color: "#FFFFFF"
                                border.color: quantityField.activeFocus ? "#A1887F" : "#D7CCC8"
                                border.width: 1.5
                            }

                            onTextChanged: {
                                var n = parseInt(text)
                                if (!isNaN(n) && n >= 1) {
                                    if (n !== itemDialog.quantityValue) {
                                        itemDialog.quantityValue = n
                                        itemDialog.updatePrice()
                                    }
                                }
                            }

                            // Khi mất focus mà để trống / không hợp lệ → reset về 1
                            onEditingFinished: {
                                var n = parseInt(text)
                                if (isNaN(n) || n < 1) {
                                    itemDialog.quantityValue = 1
                                    text = "1"
                                    itemDialog.updatePrice()
                                } else if (n > itemDialog.maxAllowedQuantity) {
                                    itemDialog.quantityValue = itemDialog.maxAllowedQuantity
                                    text = "" + itemDialog.maxAllowedQuantity
                                    itemDialog.updatePrice()
                                }
                            }

                            // Đồng bộ khi bấm − / +
                            Connections {
                                target: itemDialog
                                function onQuantityValueChanged() {
                                    if (quantityField.text !== ("" + itemDialog.quantityValue))
                                        quantityField.text = "" + itemDialog.quantityValue
                                }
                            }
                        }

                        // Nút +
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 14
                            color: itemDialog.quantityValue >= itemDialog.maxAllowedQuantity ? "#F0EBE6" : "#EFEBE9"
                            border.color: "#D7CCC8"

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 22
                                font.bold: true
                                color: itemDialog.quantityValue >= itemDialog.maxAllowedQuantity ? "#BCAAA4" : "#5D4037"
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: itemDialog.quantityValue < itemDialog.maxAllowedQuantity
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (itemDialog.quantityValue < itemDialog.maxAllowedQuantity) {
                                        itemDialog.quantityValue++
                                        itemDialog.updatePrice()
                                    }
                                }
                            }
                        }
                    }

                    // Cảnh báo tồn kho — chỉ hiện khi vượt quá tồn (và tồn < 999)
                    Text {
                        visible: itemDialog.maxAllowedQuantity < 999
                                 && itemDialog.quantityValue > itemDialog.maxAllowedQuantity
                        text: "⚠️ Không đủ nguyên liệu! Tối đa còn " + itemDialog.maxAllowedQuantity
                        color: "#C62828"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                // ─── 3. GHI CHÚ ───
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "📝  Ghi chú"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    TextArea {
                        id: tfNote
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        wrapMode: TextArea.Wrap
                        placeholderText: "Ví dụ: Ít đường, thêm sữa..."
                        font.pixelSize: 14
                        color: "#3E2723"
                        selectByMouse: true

                        background: Rectangle {
                            radius: 12
                            color: "#FFFFFF"
                            border.color: parent.activeFocus ? "#A1887F" : "#E0D5C8"
                            border.width: 1.5
                        }
                    }
                }

                // ─── 4. MỨC ĐÁ (pill buttons) ───
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: itemDialog.category === "Drink"

                    Text {
                        text: "🧊  Mức đá"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: ["Bình thường", "Ít đá", "Nhiều đá", "Không đá"]

                            delegate: Rectangle {
                                width: iceLabel.implicitWidth + 28
                                height: 40
                                radius: 20
                                color: itemDialog.selectedIce === modelData ? "#5D4037" : "#F5F0EB"
                                border.color: itemDialog.selectedIce === modelData ? "#5D4037" : "#E0D5C8"
                                border.width: 1.5

                                Text {
                                    id: iceLabel
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 13
                                    font.bold: itemDialog.selectedIce === modelData
                                    color: itemDialog.selectedIce === modelData ? "white" : "#5D4037"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        itemDialog.selectedIce = modelData
                                    }
                                }
                            }
                        }
                    }
                }

                // ─── 5. TOPPING ───
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: itemDialog.category === "Drink"

                    Text {
                        text: "🍒  Topping thêm"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 10

                        Repeater {
                            id: toppingRepeater
                            model: [
                                { name: "Trân châu", price: 10000 },
                                { name: "Whipping", price: 15000 },
                                { name: "Thạch", price: 12000 },
                                { name: "Kem cheese", price: 20000 }
                            ]

                            delegate: Rectangle {
                                width: 118
                                height: 56
                                radius: 14
                                property bool checked: false
                                property real toppingPrice: modelData.price
                                property string toppingName: modelData.name

                                color: checked ? "#6D4C41" : "#FFFFFF"
                                border.color: checked ? "#6D4C41" : "#E0D5C8"
                                border.width: 1.5

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.name
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: checked ? "white" : "#3E2723"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "+" + formatVND(modelData.price)
                                        font.pixelSize: 11
                                        color: checked ? "#FFE0B2" : "#8D6E63"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        checked = !checked
                                        itemDialog.updatePrice()
                                    }
                                }
                            }
                        }
                    }
                }

                // ─── 6. THÀNH TIỀN ───
                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    radius: 16
                    color: "#FFF3E0"
                    border.color: "#FFCC80"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 18

                        Text {
                            text: "Thành tiền"
                            font.bold: true
                            font.pixelSize: 15
                            color: "#E65100"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatVND(itemDialog.calculatedPrice)
                            font.bold: true
                            font.pixelSize: 26
                            color: "#BF360C"
                        }
                    }
                }
            }
        }

        // ===== FOOTER =====
        footer: Rectangle {
            height: 88
            color: "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                height: 1
                color: "#EFE6DC"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Item { Layout.fillWidth: true }

                // Nút Hủy
                Rectangle {
                    width: 120
                    height: 48
                    radius: 14
                    color: "#F5F0EB"
                    border.color: "#D7CCC8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "HỦY"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#5D4037"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: itemDialog.close()
                    }
                }

                // Nút Xác nhận
                Rectangle {
                    width: 140
                    height: 48
                    radius: 14
                    color: "#5D4037"

                    Text {
                        anchors.centerIn: parent
                        text: "XÁC NHẬN"
                        font.bold: true
                        font.pixelSize: 14
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: itemDialog.accept()
                    }
                }
            }
        }

        onAccepted: {
            if (quantityValue <= 0) return

            // Lấy danh sách topping đã chọn
            var toppingNames = []
            for (var i = 0; i < toppingRepeater.count; i++) {
                var btn = toppingRepeater.itemAt(i)
                if (btn && btn.checked) {
                    toppingNames.push(btn.toppingName)
                }
            }

            cartModel.append({
                "id": itemDialog.itemData.id,
                "name": itemDialog.itemData.name,
                "category": itemDialog.category,
                "size": sizeSection.visible ? selectedSize : "",
                "ice": itemDialog.category === "Drink" ? selectedIce : "",
                "toppings": toppingNames.join(", "),
                "quantity": quantityValue,
                "note": tfNote.text,
                "totalPrice": itemDialog.calculatedPrice
            })

            close()
        }
    }

    InvoiceDialog {
        id: invoiceDialog
        showFinishButton: true

        onFinished: {
            console.log("=== Bắt đầu In Hóa Đơn ===")

            // Copy dữ liệu giỏ ra trước (tránh list thay đổi giữa chừng)
            var cartCopy = []
            for (var i = 0; i < cartModel.count; i++) {
                var it = cartModel.get(i)
                if (!it || !it.id) continue
                cartCopy.push({
                    id: it.id,
                    size: it.size || "M",
                    quantity: parseInt(it.quantity) || 1,
                    name: it.name || "",
                    note: it.note || "",
                    totalPrice: it.totalPrice || 0,
                    category: it.category || "Drink",
                    ice: it.ice || "",
                    toppings: it.toppings || ""
                })
            }

            try {
                // 1. Trừ kho
                if (typeof ingredientManager !== "undefined" && ingredientManager) {
                    for (var k = 0; k < cartCopy.length; k++) {
                        var item = cartCopy[k]
                        try {
                            ingredientManager.deductIngredientsForOrder(item.id, item.size, item.quantity)
                        } catch (e) {
                            console.error("Lỗi trừ kho món", item.id, e)
                        }
                    }
                }

                // 2. Lưu lịch sử
                if (typeof orderHistoryManager !== "undefined" && orderHistoryManager) {
                    orderHistoryManager.addOrder({
                        invoiceNumber: invoiceNumber || "",
                        date: invoiceDate || "",
                        time: invoiceTime || "",
                        customerName: "Khách vãng lai",
                        totalAmount: Math.max(0, calculateGrandTotal() - voucherDiscount),
                        discount: voucherDiscount || 0,
                        voucherCode: selectedVoucherCode || "",
                        items: cartCopy
                    })
                }

                // 3. Xóa giỏ + refresh
                cartModel.clear()
                menuGrid.model = getMenuData(orderPageRoot.selectedCategory)

                console.log("=== Hoàn tất ===")
            } catch (e) {
                console.error("LỖI In Hóa Đơn:", e)
            }
        }
    }
}