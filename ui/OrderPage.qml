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

                ButtonGroup {
                    id: categoryGroup
                }

                Button {
                    text: "☕ Đồ uống"
                    Layout.fillWidth: true
                    checkable: true
                    checked: orderPageRoot.selectedCategory === "Drink"
                    ButtonGroup.group: categoryGroup

                    onClicked: {
                        orderPageRoot.selectedCategory = "Drink"
                        menuGrid.model = getMenuData("Drink")
                    }
                }

                Button {
                    text: "🍰 Món ăn"
                    Layout.fillWidth: true
                    checkable: true
                    checked: orderPageRoot.selectedCategory === "Food"
                    ButtonGroup.group: categoryGroup

                    onClicked: {
                        orderPageRoot.selectedCategory = "Food"
                        menuGrid.model = getMenuData("Food")
                    }
                }
                Button {
                    text: "📦 Quản lý tồn kho"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        if (StackView.view)
                            StackView.view.push("InventoryPage.qml")
                        else if (typeof stackView !== "undefined")
                            stackView.push("InventoryPage.qml")
                    }
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

                    // Kiểm tra món còn hàng hay không
                    property bool isAvailable: modelData.isAvailable !== undefined ? modelData.isAvailable : true
                    property int maxStock: modelData.maxStock !== undefined ? modelData.maxStock : 999

                    Rectangle {
                        id: cardBackground
                        anchors.fill: parent
                        anchors.margins: 5
                        // Nếu hết hàng thì làm mờ nền
                        color: !isAvailable ? "#E0E0E0" : (mouseArea.containsMouse ? "#F2EBE1" : "#FFFDF9")
                        border.color: !isAvailable ? "#B0BEC5" : (mouseArea.containsMouse ? "#8B5A2B" : "#D8C4B6")
                        radius: 8
                        opacity: isAvailable ? 1.0 : 0.6

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
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 4

                                Text {
                                    text: modelData.name || ""
                                    font.bold: true
                                    font.pixelSize: 14
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

                                // --- NÓI RÕ TRẠNG THÁI HẾT HÀNG / BÁO ĐỘNG ---
                                Rectangle {
                                    visible: !isAvailable || maxStock <= 5
                                    implicitWidth: lblStock.implicitWidth + 8
                                    implicitHeight: 18
                                    radius: 4
                                    color: !isAvailable ? "#D32F2F" : "#E65100"

                                    Text {
                                        id: lblStock
                                        anchors.centerIn: parent
                                        text: !isAvailable ? "HẾT HÀNG" : ("Còn " + maxStock + " phần")
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
                            enabled: isAvailable // Khóa click nếu hết hàng
                            hoverEnabled: true
                            cursorShape: isAvailable ? Qt.PointingHandCursor : Qt.ForbiddenCursor
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
                        invoiceDialog.open()

                        var earned = calculateLoyaltyPoints()
                        if (typeof customerHandler !== "undefined" && earned > 0) {
                            customerHandler.addPoints(earned)
                            if (typeof accountHandler !== "undefined")
                                accountHandler.saveCustomerLoyalty()
                            console.log("Tich +" + earned + " diem")
                        }
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

        function openDialog(data, cat){

            itemData = data
            category = cat
            basePrice = Number(data.price || 0)

            if(cat === "Drink" && data.sizes && data.sizes.length>0){

                sizeCombo.model = data.sizes
                sizeRow.visible = true
            }
            else{

                sizeCombo.model = ["Standard"]
                sizeRow.visible = false
            }

            var defaultSize = (data.sizes && data.sizes.length > 0) ? data.sizes[0] :"M"
            if (typeof ingredientManager !== "undefined"){
                maxAllowedQuantity = ingredientManager.getMaxServings(data.id, defaultSize)
            }
            else {
                maxAllowedQuantity = data.maxStock !== undefined ? data.maxStock : 999
            }

            sizeCombo.currentIndex = 0
            quantityField.text = "1"
            tfNote.text = ""

            updatePrice()

            open()
        }

        function updatePrice(){

            var extra = 0

            if(category==="Drink" && itemData && itemData.sizes){

                var list = itemData.sizes
                var current = sizeCombo.currentText

                if(sizeCombo.currentIndex>0){

                    if(list[0]==="S"){

                        if(current==="M")
                            extra = 5000
                        else
                            extra = 10000
                    }
                    else if(list[0]==="M"){

                        if(current==="L")
                            extra = 5000
                    }
                }
            }

            var quantity = parseInt(quantityField.text)

            if(isNaN(quantity))
                quantity = 0

            calculatedPrice =
                    (basePrice + extra)
                    * quantity
        }

        background: Rectangle{

            radius:20

            color:"#FFFDF8"

            border.color:"#E6D6C8"

            border.width:1
        }

        header: Rectangle{

            height:95

            color:"transparent"

            Column{

                anchors{

                    left: parent.left
                    leftMargin:25

                    verticalCenter: parent.verticalCenter
                }

                spacing:6

                Text{

                    text:"Tùy chọn món"

                    color:"#777"

                    font.pixelSize:17
                }

                Text{

                    text:itemDialog.itemData ?
                         itemDialog.itemData.name : ""

                    font.pixelSize:30

                    font.bold:true

                    color:"#3E2723"
                }
            }
        }

        ColumnLayout{

            anchors{

                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: footer.top

                // leftMargin:25
                // rightMargin:25
                // topMargin:15
                // bottomMargin:20
                margins: 20
            }

            spacing:18

            Rectangle{

                id:sizeRow

                Layout.fillWidth:true

                height:60

                radius:8

                color:"#F8F4EF"

                border.color:"#E8DDD2"

                RowLayout{

                    anchors.fill:parent

                    anchors.margins:15

                    Text{

                        text:"☕  Kích thước"

                        font.bold:true

                        font.pixelSize:15
                    }

                    Item{

                        Layout.fillWidth:true
                    }

                    ComboBox{

                        id:sizeCombo

                        implicitWidth:130

                        onCurrentTextChanged:{
                            itemDialog.updatePrice()
                            if (itemDialog.itemData && typeof ingredientManager !== "undefined"){
                                itemDialog.maxAllowedQuantity = ingredientManager.getMaxServings(itemDialog.itemData.id, currentText)
                        }
                    }
                    }
                }
            }

            Rectangle{

                Layout.fillWidth:true

                height:60

                radius:12

                color:"#F8F4EF"

                border.color:"#E8DDD2"

                RowLayout{

                    anchors.fill:parent

                    anchors.margins:15

                    Text{

                        text:"🛒  Số lượng"

                        font.bold:true

                        font.pixelSize:15
                    }

                    Item{

                        Layout.fillWidth:true
                    }

                    RowLayout{

                        spacing:8

                        Button{

                            id:minusButton

                            text:"−"

                            implicitWidth:40
                            implicitHeight:40

                            onClicked:{

                                var n = parseInt(quantityField.text)

                                if(isNaN(n))
                                    n = 0

                                quantityField.text = String(n-1)

                                itemDialog.updatePrice()
                            }
                        }

                        TextField{

                            id:quantityField

                            text:"1"

                            horizontalAlignment: Text.AlignHCenter

                            verticalAlignment: Text.AlignVCenter

                            implicitWidth:40
                            implicitHeight:40

                            validator:IntValidator{

                                bottom:0
                                top:999
                            }

                            onTextChanged:{
                                itemDialog.updatePrice()
                            }
                        }
                        Text{
                            id: warnStocktext
                            Layout.fillWidth: true
                            visible: parseInt(quantityField.text) > itemDialog.maxAllowedQuantity
                            text: "⚠️ Không đủ nguyên liệu! Tối đa còn " + itemDialog.maxAllowedQuantity + "."
                            color: "#D32F2F"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Button{

                            id:plusButton

                            text:"+"

                            implicitWidth:40
                            implicitHeight:40
                            enabled: parseInt(quantityField.text) < itemDialog.maxAllowedQuantity

                            onClicked:{

                                var n = parseInt(quantityField.text)

                                if(isNaN(n)) n = 0

                                if (n < itemDialog.maxAllowedQuantity){
                                quantityField.text = String(n+1)

                                itemDialog.updatePrice()
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout{

                Layout.fillWidth:true

                spacing:8

                Text{

                    text:"📝 Ghi chú"

                    font.bold:true

                    font.pixelSize:15
                }

                TextArea{

                    id:tfNote

                    Layout.fillWidth:true

                    Layout.preferredHeight:90

                    wrapMode: TextArea.Wrap

                    placeholderText:
                        "Nhập ghi chú món ở đây..."

                    background: Rectangle{

                        radius:12

                        color:"#F8F4EF"

                        border.color:"#E8DDD2"
                    }
                }
            }

            Rectangle{

                Layout.fillWidth:true

                height:1

                color:"#E8DDD2"
            }

            Rectangle{

                Layout.fillWidth:true

                height:70

                radius:14

                color:"#FFF6ED"

                border.color:"#F2D8B8"

                RowLayout{

                    anchors.fill:parent

                    anchors.margins:18

                    Text{

                        text:"💰 Thành tiền"

                        font.bold:true

                        font.pixelSize:17
                    }

                    Item{

                        Layout.fillWidth:true
                    }

                    Text{

                        text:formatVND(itemDialog.calculatedPrice)

                        font.bold:true

                        font.pixelSize:28

                        color:"#A45A1D"
                    }
                }
            }

            Item{

                Layout.fillHeight:true
            }
        }
        footer: Rectangle{

            height:90

            color:"transparent"

            RowLayout{

                anchors.fill: parent
                anchors.margins:20

                spacing:15

                Item{
                    Layout.fillWidth:true
                }

                Button{

                    id:cancelButton

                    text:"HỦY"

                    implicitWidth:120
                    implicitHeight:45

                    onClicked:itemDialog.close()

                    background: Rectangle{

                        radius:12

                        color: cancelButton.down ?
                               "#E6E6E6" :
                               (cancelButton.hovered ? "#F0F0F0" : "#FFFFFF")

                        border.color:"#CFCFCF"

                    }

                    contentItem: Text{

                        text:cancelButton.text

                        horizontalAlignment:Text.AlignHCenter
                        verticalAlignment:Text.AlignVCenter

                        color:"#555"

                        font.bold:true
                    }
                }

                Button{

                    id:okButton

                    text:"XÁC NHẬN"

                    implicitWidth:120
                    implicitHeight:45

                    onClicked:itemDialog.accept()

                    background: Rectangle{

                        radius:12

                        color: okButton.down ?
                               "#8A4F22" :
                               (okButton.hovered ? "#A5622E" : "#9B5D2F")
                    }

                    contentItem: Text{

                        text:okButton.text

                        horizontalAlignment:Text.AlignHCenter
                        verticalAlignment:Text.AlignVCenter

                        color:"white"

                        font.bold:true
                    }
                }
            }
        }

        enter: Transition{

            NumberAnimation{

                property:"opacity"

                from:0
                to:1

                duration:180
            }

            NumberAnimation{

                property:"scale"

                from:0.9
                to:1.0

                duration:180
            }
        }

        exit: Transition{

            NumberAnimation{

                property:"opacity"

                from:1
                to:0

                duration:150
            }

            NumberAnimation{

                property:"scale"

                from:1
                to:0.9

                duration:150
            }
        }

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.9

        onAccepted:{
                    var quantity = parseInt(quantityField.text)

                    if(isNaN(quantity) || quantity <= 0){
                        quantityField.forceActiveFocus()
                        return
                    }

                    cartModel.append({
                        "id": itemDialog.itemData.id,
                        "name": itemDialog.itemData.name,
                        "category": itemDialog.category, // <--- THÊM DÒNG NÀY ĐỂ LƯU ĐÚNG DRINK HOẶC FOOD
                        "size": sizeRow.visible ? sizeCombo.currentText : "",
                        "quantity": quantity,
                        "note": tfNote.text,
                        "totalPrice": itemDialog.calculatedPrice
                    })

                    close()
                }
    }
    Dialog {
                id: invoiceDialog
                modal: true
                width: 620
                height: 680
                anchors.centerIn: parent
                padding: 0

                background: Rectangle {
                    color: "#FFFDF9"
                    radius: 18
                    border.color: "#D8C4B6"
                    border.width: 1
                }

                // Dùng ScrollView làm container chính chứa toàn bộ giao diện
                ScrollView {
                    id: invoiceScrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                    ColumnLayout {
                        width: invoiceScrollView.availableWidth - 10
                        spacing: 15

                        // ---------------------------------------------------------
                        // 1. HEADER (TÊN QUÁN)
                        // ---------------------------------------------------------
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            spacing: 4

                            Text {
                                text: "☕ GIANG'S COFFEE"
                                font.pixelSize: 26
                                font.bold: true
                                color: "#6F4E37"

                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                text: "Thank you for your order ❤️"
                                color: "#888888"
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // ---------------------------------------------------------
                        // 2. THÔNG TIN HÓA ĐƠN
                        // ---------------------------------------------------------
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

                                Text {
                                    text: "🧾  Mã hóa đơn:  " + invoiceNumber
                                    font.bold: true
                                    font.pixelSize: 13
                                }
                                Text {
                                    text: "📅  Ngày: " + invoiceDate
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "🕒  Giờ: " + invoiceTime
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Text {
                            text: "CHI TIẾT ĐƠN HÀNG"
                            font.bold: true
                            font.pixelSize: 15
                            color: "#6F4E37"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // ---------------------------------------------------------
                        // 3. DANH SÁCH CÁC MÓN ĐÃ CHỌN (HIỂN THỊ ẢNH THẬT NGUYÊN BẢN)
                       // ---------------------------------------------------------
                         ListView {
                                id: invoiceList
                                Layout.fillWidth: true
                                Layout.leftMargin: 20
                                Layout.rightMargin: 20
                                implicitHeight: contentHeight
                                interactive: false // Để ScrollView bên ngoài chịu trách nhiệm cuộn
                                spacing: 8
                                model: cartModel

                                delegate: Rectangle {
                                    width: invoiceList.width
                                    implicitHeight: 70
                                    radius: 10
                                    color: "#FCFAF6"
                                    border.color: "#E7DBCF"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 12

                                        // Hiển thị hình ảnh thật của món đã chọn
                                        Image {
                                            Layout.preferredWidth: 50
                                            Layout.preferredHeight: 50
                                            fillMode: Image.PreserveAspectCrop
                                            clip: true
                                            source: getImagePath(model.name, model.category ? model.category : orderPageRoot.selectedCategory)

                                            // Khung vuông bo tròn viền ảnh
                                            Rectangle {
                                                anchors.fill: parent
                                                color: "transparent"
                                                border.color: "#E0E0E0"
                                                radius: 6
                                            }

                                            // Ô nền thay thế nếu ảnh bị lỗi hoặc không tìm thấy
                                            Rectangle {
                                                anchors.fill: parent
                                                color: "#E0E0E0"
                                                visible: parent.status === Image.Error || parent.status === Image.Null
                                                radius: 6

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "📷"
                                                    font.pixelSize: 18
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

                                            Text {
                                                text: "SL: " + quantity
                                                font.pixelSize: 11
                                                color: "#666666"
                                            }

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


                         // Dong voucher rieng (chi hien khi co giam)
                         Text {
                             Layout.fillWidth: true
                             Layout.leftMargin: 20
                             Layout.rightMargin: 20
                             visible: voucherDiscount > 0
                             text: "Voucher " + selectedVoucherCode + ":  -" + formatVND(voucherDiscount)
                             font.pixelSize: 13
                             font.bold: true
                             color: "#2E7D32"
                         }

                         // ---------------------------------------------------------
                         // 4. TỔNG THANH TOÁN
                         // ---------------------------------------------------------
                         Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            radius: 12
                            color: "#FFF7ED"
                            border.color: "#F2D9B6"
                            implicitHeight: 55

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12

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

                        // ---------------------------------------------------------
                        // 5. MÃ QR BÊN TRÁI & CHỮ BÊN PHẢI
                        // ---------------------------------------------------------
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            implicitHeight: 140
                            radius: 14
                            color: "#FAF8F4"
                            border.color: "#E6D8C8"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 15

                                Image {
                                    Layout.preferredWidth: 115
                                    Layout.preferredHeight: 115
                                    fillMode: Image.PreserveAspectFit
                                    source: "file:///" + applicationDir + "/data/ma_qr.jpg"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 6

                                    Text {
                                        text: "Quét mã QR để thanh toán"
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#6F4E37"
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "Sử dụng app ngân hàng hoặc ví điện tử để quét mã."
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

                        // ---------------------------------------------------------
                        // 6. CÁC NÚT BẤM (ĐÓNG / HOÀN TẤT)
                        // ---------------------------------------------------------
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            Layout.bottomMargin: 20
                            spacing: 12

                            Item { Layout.fillWidth: true }

                            Button {
                                id: invoiceCancelButton
                                text: "Đóng"
                                implicitWidth: 110
                                implicitHeight: 40
                                onClicked: invoiceDialog.close()
                            }

                            Button {
                                id: finishButton
                                text: "In Hóa Đơn"
                                implicitWidth: 170
                                implicitHeight: 40
                                highlighted: true

                                onClicked: {
                                    // Trừ kho nguyên liệu cho từng món trong cartModel
                                    for (var i = 0; i < cartModel.count; i++) {
                                        var item = cartModel.get(i);
                                        if (typeof ingredientManager !== "undefined") {
                                            ingredientManager.deductIngredientsForOrder(item.id, item.size ||"M", item.quantity);
                                        }
                                    }

                                    // Cập nhật lại giao diện menu để phản ánh tồn kho mới
                                    menuGrid.model = getMenuData(orderPageRoot.selectedCategory)
                                    cartModel.clear()
                                    invoiceDialog.close()
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