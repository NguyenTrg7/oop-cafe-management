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

        if (!cat || cat.length === 0)
                cat = "Tất cả"

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

    // ==================== TOPPING & ICE ====================
    property var toppingInventoryMap: ({
        "Trân châu":       { id: "ING014", amount: 40 },
        "Whipping Cream":  { id: "ING024", amount: 30 },
        "Thạch trái cây":  { id: "ING026", amount: 30 },
        "Kem cheese":      { id: "ING027", amount: 40 }
    })

    property var iceBySize: ({ "S": 150, "M": 180, "L": 220, "Standard": 180 })
    property var iceAdjustFactor: ({
        "Bình thường": 0,
        "Ít đá": -0.4,
        "Nhiều đá": 0.4,
        "Không đá": -1.0
    })
    property string iceIngredientId: "ING010"

    function getIngredientById(id) {
        if (typeof ingredientManager === "undefined" || !ingredientManager) return null
        var all = ingredientManager.getAllIngredients()
        for (var i = 0; i < all.length; i++)
            if (all[i].id === id) return all[i]
        return null
    }
    function getIngredientQuantity(id) {
        var ing = getIngredientById(id)
        return ing ? Number(ing.quantity) : 0
    }
    function adjustIngredientQuantity(id, delta) {
        if (typeof ingredientManager === "undefined" || !ingredientManager) return false
        var ing = getIngredientById(id)
        if (!ing) return false
        ingredientManager.setQuantity(id, Math.max(0, Number(ing.quantity) + delta))
        return true
    }
    function getRecipeIceAmount(size) {
        return iceBySize[size] || 180
    }

    function canDeductToppings(names, qty) {
        if (!names || names.length === 0) return true
        var need = {}
        for (var i = 0; i < names.length; i++) {
            var info = toppingInventoryMap[names[i]]
            if (!info) continue
            need[info.id] = (need[info.id] || 0) + info.amount * qty
        }
        for (var id in need)
            if (getIngredientQuantity(id) < need[id]) return false
        return true
    }
    function canDeductIce(level, size, qty) {
        var f = iceAdjustFactor[level] || 0
        if (f <= 0) return true
        return getIngredientQuantity(iceIngredientId) >= getRecipeIceAmount(size) * f * qty
    }

    function deductToppingsAndIce(names, level, size, qty) {
        if (qty <= 0) return true
        for (var i = 0; i < (names || []).length; i++) {
            var info = toppingInventoryMap[names[i]]
            if (info) adjustIngredientQuantity(info.id, -(info.amount * qty))
        }
        var f = iceAdjustFactor[level] || 0
        if (f !== 0)
            adjustIngredientQuantity(iceIngredientId, -(getRecipeIceAmount(size) * f * qty))
        return true
    }
    function restoreToppingsAndIce(names, level, size, qty) {
        if (qty <= 0) return true
        for (var i = 0; i < (names || []).length; i++) {
            var info = toppingInventoryMap[names[i]]
            if (info) adjustIngredientQuantity(info.id, info.amount * qty)
        }
        var f = iceAdjustFactor[level] || 0
        if (f !== 0)
            adjustIngredientQuantity(iceIngredientId, getRecipeIceAmount(size) * f * qty)
        return true
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
        // 2. KHU VỰC GIỮA (Menu / Tồn kho / Lịch sử)
        // =====================================================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // MENU ĐỒ UỐNG / MÓN ĂN
            ColumnLayout {
                anchors.fill: parent
                spacing: 16
                visible: !showingInventory && !showingHistory

                // ===== THANH TÌM KIẾM + LỌC =====
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: 14
                    color: "#FFFFFF"
                    border.color: "#BFDBFE"
                    border.width: 1.5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 10
                        spacing: 12

                        Text {
                            text: "🔍"
                            font.pixelSize: 18
                            color: "#60A5FA"
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Tìm món theo tên..."
                            font.pixelSize: 15
                            color: "#1E3A5F"
                            background: Item {}
                            selectByMouse: true
                            onTextChanged: filterMenu()
                        }

                        // Chỉ dùng 1 ComboBox làm nút Lọc
                        ComboBox {
                            id: categoryFilter
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 38

                            model: orderPageRoot.selectedCategory === "Drink"
                                   ? ["Tất cả", "Cà phê", "Cà phê pha máy", "Trà trái cây", "Trà sữa", "Đá xay", "Nước ép", "Cacao"]
                                   : ["Tất cả", "Bánh ngọt", "Bánh quy", "Dessert", "Combo"]

                            onCurrentTextChanged: filterMenu()

                            background: Rectangle {
                                radius: 10
                                color: "#3B82F6"
                            }

                            contentItem: Text {
                                text: "Lọc  ▾"
                                color: "white"
                                font.bold: true
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            indicator: Item {}     // ẩn mũi tên mặc định

                            popup: Popup {
                                y: parent.height + 6
                                width: 190
                                padding: 6

                                background: Rectangle {
                                    radius: 12
                                    color: "white"
                                    border.color: "#BFDBFE"
                                    border.width: 1
                                }

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: categoryFilter.popup.visible ? categoryFilter.delegateModel : null
                                    currentIndex: categoryFilter.highlightedIndex

                                    delegate: ItemDelegate {
                                        width: 178
                                        height: 40
                                        highlighted: categoryFilter.highlightedIndex === index

                                        background: Rectangle {
                                            color: highlighted ? "#DBEAFE" : "transparent"
                                            radius: 8
                                        }

                                        contentItem: Text {
                                            text: modelData
                                            color: "#1E3A5F"
                                            font.pixelSize: 14
                                            leftPadding: 12
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // ===== THANH DANH MỤC NGANG =====
                Row {
                    spacing: 10
                    Layout.leftMargin: 4

                    Repeater {
                        model: [
                            { text: "☕  Đồ uống", type: "Drink" },
                            { text: "🍰  Món ăn",  type: "Food" }
                        ]

                        delegate: Rectangle {
                            width: tabText.implicitWidth + 32
                            height: 40
                            radius: 20
                            color: orderPageRoot.selectedCategory === modelData.type && !showingInventory && !showingHistory
                                   ? "#3B82F6" : "#EFF6FF"
                            border.color: orderPageRoot.selectedCategory === modelData.type ? "#3B82F6" : "#BFDBFE"
                            border.width: 1

                            Text {
                                id: tabText
                                anchors.centerIn: parent
                                text: modelData.text
                                font.pixelSize: 14
                                font.bold: true
                                color: orderPageRoot.selectedCategory === modelData.type ? "white" : "#1E40AF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    showingInventory = false
                                    showingHistory = false
                                    orderPageRoot.selectedCategory = modelData.type
                                    menuGrid.model = getMenuData(modelData.type)
                                    categoryFilter.currentIndex = 0
                                    Qt.callLater(function() {
                                        filterMenu()
                                    })
                                }
                            }
                        }
                    }
                }

                GridView {
                    id: menuGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: Math.floor(width / 2) - 6
                    cellHeight: 110
                    model: getMenuData(orderPageRoot.selectedCategory)

                    delegate: Item {
                        width: menuGrid.cellWidth
                        height: menuGrid.cellHeight

                        property bool isAvailable: modelData.isAvailable !== undefined ? modelData.isAvailable : true
                        property int maxStock: modelData.maxStock !== undefined ? modelData.maxStock : 999

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: 14
                            color: !isAvailable ? "#F1F5F9" : (mouseArea.containsMouse ? "#EFF6FF" : "#FFFFFF")
                            border.color: !isAvailable ? "#CBD5E1" : (mouseArea.containsMouse ? "#3B82F6" : "#DBEAFE")
                            border.width: 1.5
                            opacity: isAvailable ? 1.0 : 0.65

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12

                                Image {
                                    Layout.preferredWidth: 70
                                    Layout.preferredHeight: 70
                                    source: getImagePath(modelData.name, orderPageRoot.selectedCategory)
                                    fillMode: Image.PreserveAspectCrop
                                    clip: true
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.name || ""
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: isAvailable ? "#1E3A5F" : "#64748B"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: formatVND(modelData.price)
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: isAvailable ? "#2563EB" : "#94A3B8"
                                    }

                                    Rectangle {
                                        visible: !isAvailable || maxStock <= 5
                                        implicitWidth: lblStock.implicitWidth + 10
                                        implicitHeight: 20
                                        radius: 6
                                        color: !isAvailable ? "#EF4444" : "#F59E0B"

                                        Text {
                                            id: lblStock
                                            anchors.centerIn: parent
                                            text: !isAvailable ? "HẾT HÀNG" : ("Còn " + maxStock)
                                            color: "white"
                                            font.pixelSize: 11
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
            color: "#F0F9FF"
            border.color: "#BAE6FD"
            radius: 16
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: "🛒 Chi tiết đơn hàng"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#0C4A6E"
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
                                    var itemId   = model.id
                                    var itemSize = model.size || "M"
                                    var itemQty  = model.quantity
                                    var itemIce  = model.ice || "Bình thường"
                                    var tops = (model.toppings || "").split(", ").filter(function(s){ return s.length > 0 })

                                    cartModel.remove(index)

                                    if (typeof ingredientManager !== "undefined" && ingredientManager)
                                        ingredientManager.restoreIngredientsForOrder(itemId, itemSize, itemQty)

                                    restoreToppingsAndIce(tops, itemIce, itemSize, itemQty)
                                    menuGrid.model = getMenuData(orderPageRoot.selectedCategory)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#BAE6FD"
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
                        color: "#0C4A6E"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: formatVND(Math.max(0, calculateGrandTotal() - voucherDiscount))
                        font.bold: true
                        font.pixelSize: 18
                        color: "#0369A1"
                    }
                }

                Button {
                    text: "THANH TOÁN"
                    Layout.fillWidth: true
                    implicitHeight: 44
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
                    color: "#FFFFFF"
                    border.color: "#BAE6FD"
                    border.width: 1.5
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
                    color: "#64748B"
                    font.pixelSize: 12
                    font.letterSpacing: 0.5
                }
                Text {
                    text: itemDialog.itemData ? itemDialog.itemData.name : ""
                    font.pixelSize: 20
                    font.bold: true
                    color: "#0C4A6E"
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
                color: "#FFFFF0"
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
                        text: "Kích thước"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#0C4A6E"
                    }

                    Row {
                        spacing: 10

                        Repeater {
                            model: itemDialog.availableSizes

                            delegate: Rectangle {
                                width: 72
                                height: 38
                                radius: 10
                                color: itemDialog.selectedSize === modelData ? "#3B82F6" : "#FFFFFF"
                                border.color: itemDialog.selectedSize === modelData ? "#3B82F6" : "#BAE6FD"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: itemDialog.selectedSize === modelData ? "white" : "#1E40AF"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        itemDialog.selectedSize = modelData

                                        // Cập nhật số lượng tối đa theo size mới
                                        if (typeof ingredientManager !== "undefined" && ingredientManager && itemDialog.itemData) {
                                            itemDialog.maxAllowedQuantity =
                                                ingredientManager.getMaxServings(itemDialog.itemData.id, modelData)

                                            // Nếu số lượng hiện tại vượt max mới → kéo về max
                                            if (itemDialog.quantityValue > itemDialog.maxAllowedQuantity) {
                                                itemDialog.quantityValue = Math.max(1, itemDialog.maxAllowedQuantity)
                                                quantityField.text = "" + itemDialog.quantityValue   // ← quan trọng
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
                        text: "🛒 Số lượng"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#0C4A6E"
                    }

                    Row {
                        spacing: 0

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: "#FFFFFF"                    // luôn trắng
                            border.color: "#BAE6FD"
                            border.width: 1.5
                            opacity: itemDialog.quantityValue <= 1 ? 0.5 : 1.0   // mờ nhẹ khi không bấm được

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#1E40AF"
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
                            color:"#0C4A6E"
                            selectByMouse: true
                            validator: IntValidator { bottom: 1; top: 999 }
                            inputMethodHints: Qt.ImhDigitsOnly

                            background: Rectangle {
                                color: "#FFFFFF"
                                border.color: quantityField.activeFocus ? "#3B82F6" : "#BAE6FD"
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
                            color: itemDialog.quantityValue >= itemDialog.maxAllowedQuantity ? "#3B82F6" : "#FFFFFF"
                            border.color: "#BAE6FD"
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 20
                                font.bold: true
                                color: itemDialog.quantityValue >= itemDialog.maxAllowedQuantity ? "white" : "#1E40AF"
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
                        color: "#DC2626"
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
                        color:"#0C4A6E"
                    }

                    TextArea {
                        id: tfNote
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        wrapMode: TextArea.Wrap
                        placeholderText: "Ví dụ: Ít đường, thêm sữa..."
                        font.pixelSize: 13
                        color: "#0C4A6E"
                        selectByMouse: true

                        background: Rectangle {
                            radius: 10
                            color: "#FFFFFF"
                            border.color: parent.activeFocus ? "#3B82F6" : "#BAE6FD"
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
                        color: "#0C4A6E"
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
                                property real iceNeed: {
                                    var factor = orderPageRoot.iceAdjustFactor[modelData] || 0
                                    if (factor <= 0) return 0
                                    return orderPageRoot.getRecipeIceAmount(itemDialog.selectedSize) * factor * itemDialog.quantityValue
                                }
                                property bool iceEnough: iceNeed <= 0 || orderPageRoot.getIngredientQuantity(orderPageRoot.iceIngredientId) >= iceNeed
                                property bool iceLow: orderPageRoot.iceIngredientId ? orderPageRoot.isIngredientLow(orderPageRoot.iceIngredientId) : false

                                color: itemDialog.selectedIce === modelData ? "#3B82F6" : (iceEnough ? "#FFFFFF" : "#FEF2F2")
                                border.color: itemDialog.selectedIce === modelData ? "#3B82F6" : (iceEnough ? (iceLow && modelData !== "Không đá" ? "#F59E0B" : "#BAE6FD") : "#FCA5A5")
                                border.width: 1.5
                                opacity: iceEnough ? 1.0 : 0.7

                                Text {
                                    id: iceLabel
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 12
                                    font.bold: itemDialog.selectedIce === modelData
                                    color: itemDialog.selectedIce === modelData ? "white" : (iceEnough ? "#1E40AF" : "#DC2626")
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: iceEnough ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                                    onClicked: {
                                        if (!iceEnough) {
                                            console.warn("Không đủ đá")
                                            return
                                        }
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
                        color: "#0C4A6E"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            id: toppingRepeater
                            model: [
                                { name: "Trân châu", price: 10000 },
                                { name: "Whipping Cream", price: 15000 },
                                { name: "Thạch trái cây", price: 12000 },
                                { name: "Kem cheese", price: 20000 }
                            ]

                            delegate: Rectangle {
                                width: 120
                                height: 52
                                radius: 10
                                property bool checked: false
                                property real toppingPrice: modelData.price
                                property string toppingName: modelData.name
                                property int stockQty: {
                                    var info = orderPageRoot.toppingInventoryMap[modelData.name]
                                    return info ? orderPageRoot.getIngredientQuantity(info.id) : 999
                                }
                                property bool isOutOfStock: stockQty <= 0
                                property bool isLowStock: {
                                    var info = orderPageRoot.toppingInventoryMap[modelData.name]
                                    return info ? orderPageRoot.isIngredientLow(info.id) : false
                                }

                                color: isOutOfStock ? "#F1F5F9" : (checked ? "#3B82F6" : "#FFFFFF")
                                border.color: isOutOfStock ? "#CBD5E1" : (checked ? "#3B82F6" : (isLowStock ? "#F59E0B" : "#BAE6FD"))
                                border.width: 1.5
                                opacity: isOutOfStock ? 0.55 : 1.0

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 1
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.name
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: isOutOfStock ? "#94A3B8" : (checked ? "white" : "#1E40AF")
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: isOutOfStock ? "HẾT HÀNG" : ("+" + formatVND(modelData.price))
                                        font.pixelSize: 10
                                        color: isOutOfStock ? "#EF4444" : (checked ? "#DBEAFE" : "#64748B")
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        visible: !isOutOfStock && isLowStock
                                        text: "⚠ Còn " + stockQty
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: checked ? "#FDE68A" : "#D97706"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: !isOutOfStock
                                    cursorShape: isOutOfStock ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                                    onClicked: {
                                        if (isOutOfStock) return
                                        if (checked) {
                                            checked = false
                                            itemDialog.updatePrice()
                                            return
                                        }
                                        var info = orderPageRoot.toppingInventoryMap[modelData.name]
                                        if (info && orderPageRoot.getIngredientQuantity(info.id) < itemDialog.quantityValue * info.amount) {
                                            console.warn("Không đủ tồn kho topping")
                                            return
                                        }
                                        checked = true
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
                    color: "#E0F2FE"
                    border.color: "#7DD3FC"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12

                        Text {
                            text: "Thành tiền"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#0C4A6E"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatVND(itemDialog.calculatedPrice)
                            font.bold: true
                            font.pixelSize: 20
                            color: "#f92867"
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
                color: "#BAE6FD"
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
                    color: "#EFF6FF"
                    border.color: "#BAE6FD"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: "HỦY"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#0C4A6E"
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
                    color: itemDialog.isQuantityValid ? "#3B82F6" : "#94A3B8"
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

            var toppingNames = []
            for (var i = 0; i < toppingRepeater.count; i++) {
                var btn = toppingRepeater.itemAt(i)
                if (btn && btn.checked) {
                    toppingNames.push(btn.toppingName)
                }
            }

            // Kiểm tra tồn kho topping + đá
            if (!canDeductToppings(toppingNames, quantityValue)) {
                console.warn("Không đủ topping")
                return
            }
            if (category === "Drink" && !canDeductIce(selectedIce, selectedSize, quantityValue)) {
                console.warn("Không đủ đá")
                return
            }

            if (typeof ingredientManager !== "undefined" && ingredientManager && itemData) {
                var ok = ingredientManager.deductIngredientsForOrder(
                    itemData.id,
                    sizeSection.visible ? selectedSize : "M",
                    quantityValue
                )
                if (!ok) {
                    console.warn("Không đủ nguyên liệu món")
                    return
                }
            }

            if (category === "Drink")
                deductToppingsAndIce(toppingNames, selectedIce, selectedSize, quantityValue)

            cartModel.append({
                "id": itemData ? itemData.id : "",
                "name": itemData ? itemData.name : "",
                "category": category,
                "size": sizeSection.visible ? selectedSize : "",
                "ice": category === "Drink" ? selectedIce : "",
                "toppings": toppingNames.join(", "),
                "quantity": quantityValue,
                "note": tfNote.text,
                "totalPrice": calculatedPrice
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
            color: "#FFFFFF"
            radius: 18
            border.color: "#BAE6FD"
            border.width: 1.5
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
                    text: "GIANG'S COFFEE"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#0C4A6E"
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Thank you for your order ❤️"
                    color: "#64748B"
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
                color: "#BAE6FD"
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
                    color: "#FFFFFF"
                    border.color: "#FFFFFF"
                    implicitHeight: 120

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: "📱 Số điện thoại tích điểm & dùng voucher"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#0C4A6E"
                        }

                        TextField {
                            id: invoicePhoneInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            placeholderText: "Nhập SĐT (để trống nếu không tích điểm)"
                            inputMethodHints: Qt.ImhDigitsOnly
                            font.pixelSize: 13
                            color: "#0C4A6E"
                            background: Rectangle {
                                radius: 8
                                color: "white"
                                border.color: parent.activeFocus ? "#3B82F6" : "#BAE6FD"
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

                            background: Rectangle {
                                radius: 8
                                color: "white"
                                border.color: "#BAE6FD"
                                border.width: 1.5
                            }

                            contentItem: Text {
                                text: parent.displayText
                                color: "#0C4A6E"
                                font.pixelSize: 13
                                leftPadding: 10
                                verticalAlignment: Text.AlignVCenter
                            }

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
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#BAE6FD"
                    border.width: 1
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 3
                        Text { text: "🧾  Mã hóa đơn:  " + invoiceNumber; font.bold: true; font.pixelSize: 12; color: "#0C4A6E" }
                        Text { text: "📅  Ngày: " + invoiceDate; font.pixelSize: 11; color: "#64748B" }
                        Text { text: "🕒  Giờ: " + invoiceTime; font.pixelSize: 11; color: "#64748B" }
                    }
                }

                Text {
                    text: "CHI TIẾT ĐƠN HÀNG"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#0C4A6E"
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
                        color: "#FFFFFF"
                        border.color: "#BAE6FD"
                        border.width: 1

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
                                    color: "#1E3A5F"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "SL: " + (model.quantity || 1)
                                    font.pixelSize: 11
                                    color: "#64748B"
                                }

                                // Mức đá
                                Text {
                                    visible: model.ice && model.ice !== "" && model.ice !== "Bình thường"
                                    text: model.ice
                                    font.pixelSize: 11
                                    color: "#0284C7"
                                }

                                // Topping
                                Text {
                                    visible: model.toppings && model.toppings !== "" && model.toppings !== "undefined"
                                    text:  model.toppings
                                    font.pixelSize: 11
                                    color: "#7C3AED"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Ghi chú
                                Text {
                                    visible: model.note && model.note !== ""
                                    text: "📝 " + model.note
                                    font.pixelSize: 11
                                    color: "#64748B"
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
                                color: "#0369A1"
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
                    color: "#E0F2FE"
                    border.color: "#7DD3FC"
                    implicitHeight: voucherDiscount > 0 ? 80 : 50

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            visible: voucherDiscount > 0
                            Layout.fillWidth: true
                            Text { text: "Giảm giá voucher"; color: "#059669"; font.bold: true; font.pixelSize: 12 }
                            Item { Layout.fillWidth: true }
                            Text { text: "−" + formatVND(voucherDiscount); color: "#059669"; font.bold: true; font.pixelSize: 12 }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "💰 Tổng thanh toán"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#0C4A6E"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: formatVND(Math.max(0, calculateGrandTotal() - voucherDiscount))
                                font.bold: true
                                font.pixelSize: 18
                                color: "#f50000"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 110
                    radius: 14
                    color: "#FFFFFF"
                    border.color: "#BAE6FD"
                    border.width: 1

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
                                color: "#0C4A6E"
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: "Sử dụng app ngân hàng hoặc ví điện tử.\n👉 Bấm vào ảnh QR để phóng to."
                                font.pixelSize: 11
                                color: "#64748B"
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
                color: "#BAE6FD"
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
                    background: Rectangle {
                        radius: 10
                        color: parent.down ? "#E0F2FE" : "#EFF6FF"
                        border.color: "#BAE6FD"
                        border.width: 1.5
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#0C4A6E"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: invoiceDialog.close()
                }

                Button {
                    text: "In Hóa Đơn"
                    implicitWidth: 140
                    implicitHeight: 38
                    background: Rectangle {
                        radius: 10
                        color: parent.down ? "#2563EB" : "#3B82F6"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

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

                        if (phone !== "" && /^0\d{9}$/.test(phone) && typeof customerHandler !== "undefined" && customerHandler) {
                            customerHandler.loadByPhone(phone)

                            if (selectedVoucherCode !== "") {
                                customerHandler.useVoucher(selectedVoucherCode)
                            }

                            var earned = calculateLoyaltyPoints()
                            if (earned > 0) {
                                customerHandler.addPoints(earned)
                            }

                            customerHandler.save()
                        } else if (selectedVoucherCode !== "" && typeof customerHandler !== "undefined" && customerHandler) {
                            customerHandler.useVoucher(selectedVoucherCode)
                            customerHandler.save()
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

                        fireworksOverlay.explode()
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
            color: "#F0F9FF"
            radius: 18
            border.color: "#BAE6FD"
            border.width: 1.5
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: "🔍 MÃ QR THANH TOÁN"
                font.bold: true
                font.pixelSize: 16
                color: "#0C4A6E"
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
                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#2563EB" : "#3B82F6"
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
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
    // ==================== PHÁO HOA ====================
    Item {
        id: fireworksOverlay
        anchors.fill: parent
        z: 99999
        visible: false

        property var colors: [
            "#FFD700", "#FFA500", "#FF4500",   // vàng - cam
            "#00BFFF", "#1E90FF", "#00CED1",   // xanh dương
            "#FF69B4", "#DA70D6", "#FF1493",   // hồng - tím
            "#FFFFFF", "#FFFACD"
        ]

        function explode() {
            visible = true

            while (particleContainer.children.length > 0)
                particleContainer.children[0].destroy()

            // Bắn 7 quả pháo hoa
            for (var k = 0; k < 7; k++) {
                Qt.callLater(function() {
                    var cx = 120 + Math.random() * (width - 240)
                    var cy = 90 + Math.random() * (height * 0.4)

                    createCenterGlow(cx, cy)
                    createStreaks(cx, cy, 28 + Math.floor(Math.random() * 12))
                    createSparks(cx, cy, 40 + Math.floor(Math.random() * 25))
                }, k * 160)
            }

            hideTimer.restart()
        }

        // Lõi sáng ở giữa
        function createCenterGlow(cx, cy) {
            glowComp.createObject(particleContainer, {
                x: cx - 22,
                y: cy - 22
            })
        }

        // Các tia dài
        function createStreaks(cx, cy, count) {
            for (var i = 0; i < count; i++) {
                var angle = (Math.PI * 2 * i) / count + Math.random() * 0.3
                var length = 90 + Math.random() * 130
                var color = colors[Math.floor(Math.random() * colors.length)]

                streakComp.createObject(particleContainer, {
                    cx: cx,
                    cy: cy,
                    angle: angle * 180 / Math.PI,
                    streakLength: length,
                    streakColor: color
                })
            }
        }

        // Hạt lấp lánh nhỏ
        function createSparks(cx, cy, count) {
            for (var i = 0; i < count; i++) {
                var angle = Math.random() * Math.PI * 2
                var dist  = 40 + Math.random() * 160
                var color = colors[Math.floor(Math.random() * colors.length)]
                var size  = 2 + Math.random() * 5

                sparkComp.createObject(particleContainer, {
                    x: cx,
                    y: cy,
                    particleColor: color,
                    particleSize: size,
                    targetX: cx + Math.cos(angle) * dist,
                    targetY: cy + Math.sin(angle) * dist
                })
            }
        }

        Item {
            id: particleContainer
            anchors.fill: parent
        }

        // === Component lõi sáng ===
        Component {
            id: glowComp
            Rectangle {
                id: glow
                width: 44
                height: 44
                radius: 22
                color: "#FFFFFF"
                opacity: 0.95
                scale: 0.15

                ParallelAnimation {
                    running: true
                    NumberAnimation {
                        target: glow; property: "scale"
                        to: 2.6; duration: 380
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: glow; property: "opacity"
                        to: 0; duration: 480
                        easing.type: Easing.InQuad
                    }
                    onFinished: glow.destroy()
                }
            }
        }

        // === Component tia dài ===
        Component {
            id: streakComp
            Rectangle {
                id: streak
                width: 3
                height: 8
                radius: 1.5
                color: streakColor
                opacity: 1
                transformOrigin: Item.Bottom

                property real cx: 0
                property real cy: 0
                property real angle: 0
                property real streakLength: 100
                property color streakColor: "#FFD700"

                x: cx - width / 2
                y: cy - height

                rotation: angle

                ParallelAnimation {
                    running: true

                    NumberAnimation {
                        target: streak; property: "height"
                        to: streakLength
                        duration: 420
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: streak; property: "opacity"
                        to: 0
                        duration: 900
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: streak; property: "width"
                        to: 1.2
                        duration: 700
                    }
                    onFinished: streak.destroy()
                }
            }
        }

        // === Component hạt lấp lánh ===
        Component {
            id: sparkComp
            Rectangle {
                id: spark
                width: particleSize
                height: particleSize
                radius: width / 2
                color: particleColor
                opacity: 1
                scale: 0.4

                property real particleSize: 4
                property color particleColor: "white"
                property real targetX: 0
                property real targetY: 0

                ParallelAnimation {
                    running: true

                    NumberAnimation {
                        target: spark; property: "x"; to: targetX
                        duration: 700 + Math.random() * 500
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: spark; property: "y"; to: targetY
                        duration: 700 + Math.random() * 500
                        easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        NumberAnimation {
                            target: spark; property: "scale"
                            to: 1.4; duration: 200
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            target: spark; property: "scale"
                            to: 0.1; duration: 800
                        }
                    }
                    NumberAnimation {
                        target: spark; property: "opacity"
                        to: 0; duration: 1100
                        easing.type: Easing.InQuad
                    }
                    onFinished: spark.destroy()
                }
            }
        }

        Timer {
            id: hideTimer
            interval: 3200
            onTriggered: fireworksOverlay.visible = false
        }
    }
}