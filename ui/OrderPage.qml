import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: orderPageRoot
    anchors.fill: parent

    property string selectedVoucherCode: ""
    property double voucherDiscount: 0
    property string selectedCategory: "Drink"

    property bool showingInventory: false
    property bool showingHistory: false
    property var fullMenuData: []

    // Model giỏ hàng & voucher theo SĐT
    ListModel { id: cartModel }
    ListModel { id: phoneVoucherModel }

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

    function formatVND(value) {
        value = Math.round(Number(value));
        return Qt.locale("vi_VN").toString(value) + " VNĐ";
    }

    function getImagePath(itemName, category) {
        if (!itemName)
            return "";

        var fileName = itemName.toLowerCase()
                               .normalize("NFD")
                               .replace(/[\u0300-\u036f]/g, "")
                               .replace(/[đĐ]/g, "d")
                               .replace(/\s+/g, "_")
                               .replace(/[^a-z0-9_]/g, "");

        var folder = category === "Food" ? "Food" : "Drink";

        // Ưu tiên dùng đường dẫn từ main.cpp
        if (typeof savesDirUrl !== "undefined" && savesDirUrl) {
            return savesDirUrl + folder + "/" + fileName + ".png";
        }

        // Fallback (nếu chưa sửa main)
        var appDir = (typeof applicationDir !== "undefined" && applicationDir) ? applicationDir : "";
        appDir = appDir.replace(/\\/g, "/");
        if (appDir.length > 0 && !appDir.endsWith("/"))
            appDir += "/";

        return "file:///" + appDir + "saves/" + folder + "/" + fileName + ".png";
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

    // Invoice Info
    property string invoiceNumber: ""
    property string invoiceDate: ""
    property string invoiceTime: ""

    function generateInvoiceNumber() {
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

                // Button {
                //     Layout.fillWidth: true
                //     implicitHeight: 44
                //     text: "📦  Tồn kho"
                //     checkable: true
                //     checked: showingInventory
                //     onClicked: {
                //         showingInventory = true
                //         showingHistory = false
                //     }
                // }

                // Button {
                //     Layout.fillWidth: true
                //     implicitHeight: 44
                //     text: "📜  Lịch sử"
                //     checkable: true
                //     checked: showingHistory
                //     onClicked: {
                //         showingHistory = true
                //         showingInventory = false
                //     }
                // }

                Item { Layout.fillHeight: true }
            }
        }

        // =====================================================================
        // 2. KHU VỰC GIỮA (Menu / Tồn kho / Lịch sử)
        // =====================================================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // MENU ĐỒ UỐNG / MÓN ĂN
            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                visible: !showingInventory && !showingHistory

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
                               : ["Tất cả", "Bánh ngọt", "Bánh quy", "Dessert" ,"Combo"]
                        onCurrentTextChanged: filterMenu()
                    }
                }

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

            // TRANG TỒN KHO
            Loader {
                id: inventoryLoader
                anchors.fill: parent
                active: showingInventory
                visible: showingInventory
                asynchronous: true
                source: "InventoryPage.qml"

                onStatusChanged: {
                    if (status === Loader.Error)
                        console.error("Không load được InventoryPage.qml")
                    else if (status === Loader.Ready)
                        console.log("InventoryPage đã load xong")
                }
            }

            // TRANG LỊCH SỬ
            Loader {
                id: historyLoader
                anchors.fill: parent
                active: showingHistory
                visible: showingHistory
                asynchronous: true
                source: "OrderHistoryPage.qml"

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
                        clip: true

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            ColumnLayout {
                                id: colCart
                                Layout.fillWidth: true
                                Layout.maximumWidth: parent.width - 110
                                spacing: 2

                                Text {
                                    text: model.name + (model.size ? " (" + model.size + ")" : "") + " x" + model.quantity
                                    font.bold: true
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: model.ice && model.ice !== "" && model.ice !== "Bình thường"
                                    text: model.ice
                                    font.pixelSize: 11
                                    color: "#0277BD"
                                }

                                Text {
                                    visible: model.toppings && model.toppings !== "" && model.toppings !== "undefined"
                                    text: model.toppings
                                    font.pixelSize: 11
                                    color: "#6A1B9A"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.note !== "" ? "Ghi chú: " + model.note : "Không ghi chú"
                                    font.pixelSize: 10
                                    color: "#757575"
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.WrapAnywhere
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: formatVND(model.totalPrice)
                                font.bold: true
                                font.pixelSize: 12
                                color: "#8B5A2B"
                                Layout.preferredWidth: 70
                                Layout.alignment: Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }

                            Button {
                                text: "X"
                                implicitWidth: 24
                                implicitHeight: 24
                                Layout.preferredWidth: 28
                                Layout.alignment: Qt.AlignVCenter
                                onClicked: {
                                    var itemId = model.id
                                    var itemSize = model.size || "M"
                                    var itemQty = model.quantity
                                    cartModel.remove(index)
                                    // Hoàn lại tồn kho
                                    if (typeof ingredientManager !== "undefined" && ingredientManager) {
                                        ingredientManager.restoreIngredientsForOrder(itemId, itemSize, itemQty)
                                    }
                                    menuGrid.model = getMenuData(orderPageRoot.selectedCategory)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#D8C4B6"
                }

                // ComboBox {
                //     id: voucherCombo
                //     Layout.fillWidth: true
                //     model: {
                //         var items = ["Không dùng voucher"]
                //         if (typeof customerHandler !== "undefined" && customerHandler) {
                //             var list = customerHandler.activeVouchers || []
                //             for (var i = 0; i < list.length; i++)
                //                 items.push(list[i].code + " (" + list[i].percent + "%)")
                //         }
                //         return items
                //     }
                //     onActivated: {
                //         if (currentIndex <= 0) {
                //             selectedVoucherCode = ""
                //             voucherDiscount = 0
                //         } else if (typeof customerHandler !== "undefined" && customerHandler) {
                //             var list = customerHandler.activeVouchers || []
                //             if (currentIndex - 1 < list.length) {
                //                 var v = list[currentIndex - 1]
                //                 selectedVoucherCode = v.code
                //                 voucherDiscount = customerHandler.applyVoucher(v.code, calculateGrandTotal())
                //             }
                //         }
                //     }
                // }

                // Text {
                //     visible: voucherDiscount > 0
                //     text: "Giảm giá: " + formatVND(voucherDiscount)
                //     color: "#2E7D32"
                //     font.bold: true
                //     font.pixelSize: 13
                // }

                // RowLayout {
                //     Layout.fillWidth: true

                //     Text {
                //         text: "TỔNG CỘNG:"
                //         font.bold: true
                //         font.pixelSize: 15
                //         color: "#2C1D11"
                //     }

                //     Item { Layout.fillWidth: true }

                //     Text {
                //         text: formatVND(calculateGrandTotal())
                //         font.bold: true
                //         font.pixelSize: 14
                //         color: "#757575"
                //         font.strikeout: voucherDiscount > 0
                //     }
                // }

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

                Button {
                    text: "THANH TOÁN"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    highlighted: true
                    enabled: cartModel.count > 0

                    onClicked: {
                        updateInvoiceInfo()
                        phoneVoucherModel.clear()
                        invoiceDialog.open()
                    }
                }

                // Button {
                //     text: "⭐ Xem điểm Loyalty"
                //     Layout.fillWidth: true
                //     implicitHeight: 40
                //     onClicked: {
                //         if (typeof StackView !== "undefined" && StackView.view)
                //             StackView.view.push("LoyaltyPage.qml")
                //         else if (typeof stackView !== "undefined" && stackView)
                //             stackView.push("LoyaltyPage.qml")
                //     }
                // }

                // Button {
                //     text: "🪑 Xem trạng thái bàn"
                //     Layout.fillWidth: true
                //     implicitHeight: 40
                //     onClicked: {
                //         if (typeof StackView !== "undefined" && StackView.view)
                //             StackView.view.push("SeatingPage.qml")
                //         else if (typeof stackView !== "undefined" && stackView)
                //             stackView.push("SeatingPage.qml")
                //     }
                // }
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
        width: Math.min(560, orderPageRoot.width > 0 ? orderPageRoot.width - 24 : 560)
        height: Math.min(640, orderPageRoot.height > 0 ? orderPageRoot.height - 20 : 640)
        padding: 0
        x: Math.max(0, (orderPageRoot.width - width) / 2)
        y: Math.max(10, Math.floor((orderPageRoot.height - height) / 2) - 60)

        property var itemData: null
        property string category: "Drink"
        property real basePrice: 0
        property real calculatedPrice: 0
        property int maxAllowedQuantity: 999
        property bool isQuantityValid: quantityValue >= 1 && quantityValue <= maxAllowedQuantity
        property string selectedSize: "S"
        property string selectedIce: "Bình thường"
        property var availableSizes: ["S", "M", "L"]
        property int quantityValue: 1

        function openDialog(data, cat) {
            itemData = data
            category = cat
            basePrice = Number(data.price || 0)

            if (cat === "Drink" && data.sizes && data.sizes.length > 0) {
                availableSizes = data.sizes
                sizeSection.visible = true
                selectedSize = data.sizes[0]
            } else {
                availableSizes = ["Standard"]
                sizeSection.visible = false
                selectedSize = "Standard"
            }

            var maxStock = 999
            if (typeof ingredientManager !== "undefined" && ingredientManager) {
                var sz = selectedSize || "M"
                maxStock = ingredientManager.getMaxServings(data.id, sz)
            } else if (data.maxStock !== undefined && data.maxStock !== null) {
                maxStock = Number(data.maxStock)
            }

            if (maxStock <= 0) {
                console.warn("Hết hàng:", data.name)
                return
            }

            maxAllowedQuantity = Math.max(1, maxStock)
            quantityValue = 1
            quantityField.text = "1"
            if (typeof quantityField !== "undefined" && quantityField)
                quantityField.text = "1"

            tfNote.text = ""
            selectedIce = "Bình thường"

            for (var i = 0; i < toppingRepeater.count; i++) {
                if (toppingRepeater.itemAt(i))
                    toppingRepeater.itemAt(i).checked = false
            }

            updatePrice()
            open()
        }

        function updatePrice() {
            var extra = 0

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

            var toppingExtra = 0
            for (var i = 0; i < toppingRepeater.count; i++) {
                var btn = toppingRepeater.itemAt(i)
                if (btn && btn.checked)
                    toppingExtra += btn.toppingPrice
            }

            calculatedPrice = (basePrice + extra + toppingExtra) * quantityValue
        }

        background: Rectangle {
            radius: 20
            color: "#FFFCFA"
            border.color: "#E8DDD2"
            border.width: 1
        }

        header: Rectangle {
            height: 60
            color: "transparent"

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Tùy chọn món"
                    color: "#A1887F"
                    font.pixelSize: 12
                    font.letterSpacing: 0.5
                }
                Text {
                    text: itemDialog.itemData ? itemDialog.itemData.name : ""
                    font.pixelSize: 20
                    font.bold: true
                    color: "#3E2723"
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                height: 1
                color: "#EFE6DC"
            }
        }

        contentItem: ScrollView {
            id: dialogScrollView
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                id: contentColumn
                width: itemDialog.availableWidth - 32
                x: 16
                y: 12
                spacing: 14

                ColumnLayout {
                    id: sizeSection
                    Layout.fillWidth: true
                    spacing: 8

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
                                height: 38
                                radius: 10
                                color: itemDialog.selectedSize === modelData ? "#6D4C41" : "#F5F0EB"
                                border.color: itemDialog.selectedSize === modelData ? "#6D4C41" : "#E0D5C8"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: itemDialog.selectedSize === modelData ? "white" : "#5D4037"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        itemDialog.selectedSize = modelData

                                        if (typeof ingredientManager !== "undefined" && ingredientManager && itemDialog.itemData) {
                                            itemDialog.maxAllowedQuantity =
                                                ingredientManager.getMaxServings(itemDialog.itemData.id, modelData)

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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "🛒  Số lượng"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    Row {
                        spacing: 0

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: itemDialog.quantityValue <= 1 ? "#F0EBE6" : "#EFEBE9"
                            border.color: "#D7CCC8"

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 20
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
                                        quantityField.text = "" + itemDialog.quantityValue
                                        itemDialog.updatePrice()
                                    }
                                }
                            }
                        }

                        TextField {
                            id: quantityField
                            width: 54
                            height: 40
                            text: "" + itemDialog.quantityValue
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16
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
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: itemDialog.quantityValue >= itemDialog.maxAllowedQuantity ? "#F0EBE6" : "#EFEBE9"
                            border.color: "#D7CCC8"

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 20
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
                                        quantityField.text = "" + itemDialog.quantityValue
                                        itemDialog.updatePrice()
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: itemDialog.maxAllowedQuantity < 999
                                 && itemDialog.quantityValue > itemDialog.maxAllowedQuantity
                        text: "⚠️ Không đủ nguyên liệu! Tối đa còn " + itemDialog.maxAllowedQuantity
                        color: "#C62828"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

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
                        Layout.preferredHeight: 55
                        wrapMode: TextArea.Wrap
                        placeholderText: "Ví dụ: Ít đường, thêm sữa..."
                        font.pixelSize: 13
                        color: "#3E2723"
                        selectByMouse: true

                        background: Rectangle {
                            radius: 10
                            color: "#FFFFFF"
                            border.color: parent.activeFocus ? "#A1887F" : "#E0D5C8"
                            border.width: 1.5
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: itemDialog.category === "Drink"

                    Text {
                        text: " Mức đá"
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
                                width: iceLabel.implicitWidth + 20
                                height: 34
                                radius: 17
                                color: itemDialog.selectedIce === modelData ? "#5D4037" : "#F5F0EB"
                                border.color: itemDialog.selectedIce === modelData ? "#5D4D37" : "#E0D5C8"
                                border.width: 1.5

                                Text {
                                    id: iceLabel
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 12
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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: itemDialog.category === "Drink"

                    Text {
                        text: "Topping thêm"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#4E342E"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            id: toppingRepeater
                            model: [
                                { name: "Trân châu", price: 10000 },
                                { name: "Whipping", price: 15000 },
                                { name: "Thạch", price: 12000 },
                                { name: "Kem cheese", price: 20000 }
                            ]

                            delegate: Rectangle {
                                width: 105
                                height: 46
                                radius: 10
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
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: checked ? "white" : "#3E2723"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "+" + formatVND(modelData.price)
                                        font.pixelSize: 10
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

                // KHUNG THÀNH TIỀN
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 12
                    color: "#FFF3E0"
                    border.color: "#FFCC80"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12

                        Text {
                            text: "Thành tiền"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#E65100"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatVND(itemDialog.calculatedPrice)
                            font.bold: true
                            font.pixelSize: 20
                            color: "#BF360C"
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16
                }
            }
        }

        footer: Rectangle {
            height: 56
            color: "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                height: 1
                color: "#EFE6DC"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 100
                    height: 38
                    radius: 10
                    color: "#F5F0EB"
                    border.color: "#D7CCC8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "HỦY"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#5D4037"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: itemDialog.close()
                    }
                }

                Rectangle {
                    width: 120
                    height: 38
                    radius: 10
                    color: itemDialog.isQuantityValid ? "#5D4037" : "#BDBDBD"
                    opacity: itemDialog.isQuantityValid ? 1.0 : 0.6

                    Text {
                        anchors.centerIn: parent
                        text: "XÁC NHẬN"
                        font.bold: true
                        font.pixelSize: 13
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: itemDialog.isQuantityValid
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        onClicked: itemDialog.accept()
                    }
                }
            }
        }

        onAccepted: {
            if (quantityValue <= 0) return

            if (typeof ingredientManager !== "undefined" && ingredientManager && itemDialog.itemData) {
                var success = ingredientManager.deductIngredientsForOrder(
                    itemDialog.itemData.id,
                    sizeSection.visible ? selectedSize : "M",
                    quantityValue
                )
                if (!success) {
                    console.warn("Không đủ nguyên liệu để thêm món:", itemDialog.itemData.name)
                    return
                }
            }

            var toppingNames = []
            for (var i = 0; i < toppingRepeater.count; i++) {
                var btn = toppingRepeater.itemAt(i)
                if (btn && btn.checked) {
                    toppingNames.push(btn.toppingName)
                }
            }

            cartModel.append({
                "id": itemDialog.itemData ? itemDialog.itemData.id : "",
                "name": itemDialog.itemData ? itemDialog.itemData.name : "",
                "category": itemDialog.category,
                "size": sizeSection.visible ? selectedSize : "",
                "ice": itemDialog.category === "Drink" ? selectedIce : "",
                "toppings": toppingNames.join(", "),
                "quantity": quantityValue,
                "note": tfNote.text,
                "totalPrice": itemDialog.calculatedPrice
            })

            menuGrid.model = getMenuData(orderPageRoot.selectedCategory)
            close()
        }
    }

    // =========================================================================
    // DIALOG HÓA ĐƠN & THANH TOÁN
    // =========================================================================
    Dialog {
        id: invoiceDialog
        modal: true
        width: Math.min(640, orderPageRoot.width > 0 ? orderPageRoot.width - 40 : 640)
        height: Math.min(600, orderPageRoot.height > 0 ? orderPageRoot.height - 60 : 600)
        x: Math.max(0, (orderPageRoot.width - width) / 2)
        y: Math.max(10, Math.floor((orderPageRoot.height - height) / 2) - 40)
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

            if (!phone || !/^0\d{9}$/.test(phone) || typeof customerHandler === "undefined" || !customerHandler)
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

        header: Rectangle {
            height: 60
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    text: "☕ GIANG'S COFFEE"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#6F4E37"
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Thank you for your order ❤️"
                    color: "#888"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: "#EFE6DC"
            }
        }

        contentItem: ScrollView {
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: invoiceDialog.availableWidth - 24
                x: 12
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    radius: 12
                    color: "#F0FDF4"
                    border.color: "#86EFAC"
                    implicitHeight: 120

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: "📱 Số điện thoại tích điểm & dùng voucher"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#166534"
                        }

                        TextField {
                            id: invoicePhoneInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            placeholderText: "Nhập SĐT (để trống nếu không tích điểm)"
                            inputMethodHints: Qt.ImhDigitsOnly
                            font.pixelSize: 13
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
                            Layout.preferredHeight: 34
                            enabled: phoneVoucherModel.count > 0
                            model: phoneVoucherModel
                            textRole: "display"

                            displayText: {
                                if (phoneVoucherModel.count === 0)
                                    return invoicePhoneInput.text.length === 10 ? "Không có voucher" : "Nhập SĐT để xem voucher"
                                if (currentIndex < 0 || currentIndex >= phoneVoucherModel.count) return "— Chọn voucher (nếu có) —"
                                var item = phoneVoucherModel.get(currentIndex)
                                return item ? item.display : "— Chọn voucher (nếu có) —"
                            }

                            onActivated: {
                                if (currentIndex >= 0 && currentIndex < phoneVoucherModel.count && typeof customerHandler !== "undefined" && customerHandler) {
                                    var item = phoneVoucherModel.get(currentIndex)
                                    if (item) {
                                        selectedVoucherCode = item.code
                                        voucherDiscount = customerHandler.applyVoucher(item.code, calculateGrandTotal())
                                    }
                                } else {
                                    selectedVoucherCode = ""
                                    voucherDiscount = 0
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 74
                    radius: 10
                    color: "#F9F5EF"
                    border.color: "#E6D8C8"
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 3
                        Text { text: "🧾  Mã hóa đơn:  " + invoiceNumber; font.bold: true; font.pixelSize: 12 }
                        Text { text: "📅  Ngày: " + invoiceDate; font.pixelSize: 11 }
                        Text { text: "🕒  Giờ: " + invoiceTime; font.pixelSize: 11 }
                    }
                }

                Text {
                    text: "CHI TIẾT ĐƠN HÀNG"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#6F4E37"
                    Layout.alignment: Qt.AlignHCenter
                }

                ListView {
                    Layout.fillWidth: true
                    implicitHeight: contentHeight
                    interactive: false
                    spacing: 6
                    model: cartModel

                    delegate: Rectangle {
                        width: ListView.view.width
                        implicitHeight: Math.max(60, col.implicitHeight + 20)
                        radius: 10
                        color: "#FCFAF6"
                        border.color: "#E7DBCF"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            spacing: 12

                            // Ảnh
                            Image {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignVCenter
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                source: getImagePath(model.name, model.category || "Drink")
                            }

                            // Thông tin món
                            ColumnLayout {
                                id: col
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: (model.name || "") + (model.size ? " (" + model.size + ")" : "")
                                    font.bold: true
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "SL: " + (model.quantity || 1)
                                    font.pixelSize: 11
                                    color: "#666"
                                }

                                // Mức đá
                                Text {
                                    visible: model.ice && modela.ice !== "" && model.ice !== "Bình thường"
                                    text: model.ice
                                    font.pixelSize: 11
                                    color: "#0277BD"
                                }

                                // Topping
                                Text {
                                    visible: model.toppings && model.toppings !== "" && model.toppings !== "undefined"
                                    text:  model.toppings
                                    font.pixelSize: 11
                                    color: "#6A1B9A"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Ghi chú
                                Text {
                                    visible: model.note && model.note !== ""
                                    text: "📝 " + model.note
                                    font.pixelSize: 11
                                    color: "#757575"
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }

                            // Giá (cố định để thẳng hàng)
                            Text {
                                text: formatVND(model.totalPrice)
                                font.bold: true
                                font.pixelSize: 13
                                color: "#8B5A2B"
                                Layout.preferredWidth: 110
                                Layout.minimumWidth: 110
                                Layout.maximumWidth: 110
                                horizontalAlignment: Text.AlignRight
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 12
                    color: "#FFF7ED"
                    border.color: "#F2D9B6"
                    implicitHeight: voucherDiscount > 0 ? 80 : 50

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            visible: voucherDiscount > 0
                            Layout.fillWidth: true
                            Text { text: "Giảm giá voucher"; color: "#15803D"; font.bold: true; font.pixelSize: 12 }
                            Item { Layout.fillWidth: true }
                            Text { text: "−" + formatVND(voucherDiscount); color: "#15803D"; font.bold: true; font.pixelSize: 12 }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "💰 Tổng thanh toán"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#6F4E37"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: formatVND(Math.max(0, calculateGrandTotal() - voucherDiscount))
                                font.bold: true
                                font.pixelSize: 18
                                color: "#B45309"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 110
                    radius: 14
                    color: "#FAF8F4"
                    border.color: "#E6D8C8"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Image {
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 90
                            fillMode: Image.PreserveAspectFit
                            source: (typeof savesDirUrl !== "undefined" && savesDirUrl)
                                    ? savesDirUrl + "ma_qr.jpg"
                                    : ""

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: qrZoomDialog.open()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Quét mã QR để thanh toán"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#6F4E37"
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: "Sử dụng app ngân hàng hoặc ví điện tử.\n👉 Bấm vào ảnh QR để phóng to."
                                font.pixelSize: 11
                                color: "#666"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16
                }
            }
        }

        footer: Rectangle {
            height: 56
            color: "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: "#EFE6DC"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Item { Layout.fillWidth: true }

                Button {
                    text: "Đóng"
                    implicitWidth: 100
                    implicitHeight: 38
                    onClicked: invoiceDialog.close()
                }

                Button {
                    text: "In Hóa Đơn"
                    implicitWidth: 140
                    implicitHeight: 38
                    highlighted: true

                    onClicked: {
                        var phone = invoicePhoneInput.text.trim()

                        var cartCopy = []
                        for (var i = 0; i < cartModel.count; i++) {
                            var it = cartModel.get(i)
                            if (!it) continue
                            cartCopy.push({
                                id: it.id !== undefined ? it.id : "",
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

                        if (selectedVoucherCode !== "" && typeof customerHandler !== "undefined" && customerHandler) {
                            customerHandler.useVoucher(selectedVoucherCode)
                            customerHandler.save()
                        }

                        if (phone !== "" && /^0\d{9}$/.test(phone)) {
                            var earned = calculateLoyaltyPoints()
                            if (earned > 0 && typeof customerHandler !== "undefined" && customerHandler) {
                                customerHandler.loadByPhone(phone)
                                customerHandler.addPoints(earned)
                                customerHandler.save()
                            }
                        }

                        if (typeof orderHistoryManager !== "undefined" && orderHistoryManager) {
                            orderHistoryManager.addOrder({
                                invoiceNumber: invoiceNumber || "",
                                date: invoiceDate || "",
                                time: invoiceTime || "",
                                customerName: phone !== "" ? ("Khách SĐT: " + phone) : "Khách vãng lai",
                                totalAmount: Math.max(0, calculateGrandTotal() - voucherDiscount),
                                discount: voucherDiscount || 0,
                                voucherCode: selectedVoucherCode || "",
                                items: cartCopy
                            })
                        }

                        selectedVoucherCode = ""
                        voucherDiscount = 0
                        phoneVoucherModel.clear()
                        invoicePhoneInput.text = ""
                        cartModel.clear()
                        menuGrid.model = getMenuData(orderPageRoot.selectedCategory)

                        invoiceDialog.close()
                    }
                }
            }
        }
    }

    // =========================================================================
    // DIALOG PHÓNG TO MÃ QR
    // =========================================================================
    Dialog {
        id: qrZoomDialog
        modal: true
        focus: true
        width: Math.min(420, orderPageRoot.width > 0 ? orderPageRoot.width - 20 : 420)
        height: Math.min(460, orderPageRoot.height > 0 ? orderPageRoot.height - 20 : 460)
        x: Math.max(0, (orderPageRoot.width - width) / 2)
        y: Math.max(10, (orderPageRoot.height - height) / 2)
        padding: 16

        background: Rectangle {
            color: "#FFFDF9"
            radius: 18
            border.color: "#D8C4B6"
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: "🔍 MÃ QR THANH TOÁN"
                font.bold: true
                font.pixelSize: 16
                color: "#6F4E37"
                Layout.alignment: Qt.AlignHCenter
            }

            Image {
                Layout.fillWidth: true
                Layout.fillHeight: true
                fillMode: Image.PreserveAspectFit
                source: (typeof savesDirUrl !== "undefined" && savesDirUrl)
                        ? savesDirUrl + "ma_qr.jpg"
                        : ""
            }

            Button {
                text: "Đóng"
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 120
                implicitHeight: 38
                onClicked: qrZoomDialog.close()
            }
        }
    }

    Connections {
        target: typeof ingredientManager !== "undefined" ? ingredientManager : null
        function onIngredientsChanged() {
            if (!showingInventory && !showingHistory) {
                menuGrid.model = getMenuData(orderPageRoot.selectedCategory)
            }
        }
    }
}