import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: orderPageRoot
    anchors.fill: parent

    // =========================================================================
    // BIẾN THUỘC TÍNH & MODEL QUẢN LÝ ĐƠN HÀNG
    // =========================================================================
    property double totalPrice: 0

    // ListModel lưu danh sách các món khách đã chọn
    ListModel {
        id: currentInvoiceModel
    }

    // ListModel chứa danh sách thực đơn mẫu
    ListModel {
        id: menuModel
        ListElement { name: "Cà phê Đen Pha Phin"; price: 25000; size: "M" }
        ListElement { name: "Bạc Xỉu Cốt Dừa"; price: 35000; size: "L" }
        ListElement { name: "Trà Sen Vàng"; price: 40000; size: "M" }
        ListElement { name: "Cacao Nóng Trứng"; price: 45000; size: "M" }
    }

    // =========================================================================
    // HÀM LOGIC XỬ LÝ ĐƠN HÀNG
    // =========================================================================

    // 1. Hàm thêm món vào hóa đơn
    function addItemToInvoice(itemName, itemPrice, itemSize) {
        var found = false;
        // Kiểm tra xem món này đã có trong hóa đơn chưa
        for (var i = 0; i < currentInvoiceModel.count; i++) {
            var item = currentInvoiceModel.get(i);
            if (item.name === itemName && item.size === itemSize) {
                // Nếu đã có thì tăng số lượng
                var newQty = item.quantity + 1;
                var newTotal = newQty * itemPrice;
                currentInvoiceModel.setProperty(i, "quantity", newQty);
                currentInvoiceModel.setProperty(i, "totalItemPrice", newTotal);
                found = true;
                break;
            }
        }

        // Nếu chưa có thì thêm dòng mới
        if (!found) {
            currentInvoiceModel.append({
                "name": itemName,
                "price": itemPrice,
                "size": itemSize,
                "quantity": 1,
                "totalItemPrice": itemPrice
            });
        }

        // Cập nhật lại tổng tiền toàn bộ hóa đơn
        recalculateTotal();
    }

    // 2. Hàm xóa bớt hoặc giảm số lượng món
    function removeItemFromInvoice(index) {
        var item = currentInvoiceModel.get(index);
        if (item.quantity > 1) {
            var newQty = item.quantity - 1;
            currentInvoiceModel.setProperty(index, "quantity", newQty);
            currentInvoiceModel.setProperty(index, "totalItemPrice", newQty * item.price);
        } else {
            currentInvoiceModel.remove(index);
        }
        recalculateTotal();
    }

    // 3. Hàm tính lại tổng tiền
    function recalculateTotal() {
        var sum = 0;
        for (var i = 0; i < currentInvoiceModel.count; i++) {
            sum += currentInvoiceModel.get(i).totalItemPrice;
        }
        totalPrice = sum;
    }

    // 4. Hàm Thanh toán & In biên lai
    function processPayment() {
        if (currentInvoiceModel.count === 0) {
            statusDialog.title = "Thông báo";
            statusDialog.text = "Hóa đơn hiện tại đang trống! Vui lòng chọn món trước khi thanh toán.";
            statusDialog.open();
            return;
        }

        // Gọi C++ lưu giao dịch vào file CSV (Finance)
        var currentDate = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss");
        var note = "Bán hàng (" + currentInvoiceModel.count + " món)";

        if (typeof coffeeSystem !== "undefined") {
            coffeeSystem.addTransactionCSV(currentDate, "Thu", totalPrice, note);
        }

        // Mở thông báo thanh toán thành công
        statusDialog.title = "Thanh toán thành công";
        statusDialog.text = "Đã in biên lai thành công!\nTổng tiền: " + totalPrice.toLocaleString(Qt.locale("vi_VN"), "f", 0) + " VNĐ";
        statusDialog.open();

        // Đặt lại hóa đơn về trống
        currentInvoiceModel.clear();
        recalculateTotal();
    }

    // Dialog thông báo
    MessageDialog {
        id: statusDialog
        buttons: MessageDialog.Ok
    }

    // =========================================================================
    // GIAO DIỆN (UI LAYOUT)
    // =========================================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // ---------------------------------------------------------------------
        // CỘT BÊN TRÁI: THỰC ĐƠN CỔ ĐIỂN
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 6
            color: "#FAF3E0"
            border.color: "#B39268"
            border.width: 1.5
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Tiêu đề Thực Đơn
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 45
                    color: "#EFE3C3"
                    border.color: "#B39268"
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "Thực Đơn Cổ Điển"
                        font.pixelSize: 20
                        font.bold: true
                        font.family: "Georgia"
                        color: "#4A3025"
                    }
                }

                // Danh sách món ăn/nước uống (Grid 2 cột)
                GridView {
                    id: menuGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: menuGrid.width / 2
                    cellHeight: 110
                    clip: true
                    model: menuModel

                    delegate: Item {
                        width: menuGrid.cellWidth
                        height: menuGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "#EFE3C3"
                            border.color: "#C8B282"
                            border.width: 1
                            radius: 6

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: model.name
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: "#2C1D11"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: model.price + " VNĐ - Size: " + model.size
                                    font.pixelSize: 12
                                    color: "#5C4033"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // Nút "+ Thêm vào đơn"
                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    implicitHeight: 28

                                    contentItem: Text {
                                        text: "+ Thêm vào đơn"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#FFFFFF"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: parent.down ? "#8C6339" : "#B38B42"
                                        radius: 4
                                    }

                                    onClicked: {
                                        addItemToInvoice(model.name, model.price, model.size);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // CỘT BÊN PHẢI: HÓA ĐƠN HIỆN TẠI
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 4
            color: "#FAF3E0"
            border.color: "#B39268"
            border.width: 1.5
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Tiêu đề Hóa Đơn
                Text {
                    text: "Hóa Đơn Hiện Tại"
                    font.pixelSize: 20
                    font.bold: true
                    font.family: "Georgia"
                    color: "#4A3025"
                }

                // Danh sách món trong hóa đơn
                ListView {
                    id: invoiceListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: currentInvoiceModel

                    delegate: Rectangle {
                        width: invoiceListView.width
                        height: 40
                        color: index % 2 === 0 ? "#F5EBE0" : "transparent"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5

                            Text {
                                text: model.name + " (" + model.size + ")"
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                color: "#332211"
                            }

                            Text {
                                text: "x" + model.quantity
                                font.bold: true
                                font.pixelSize: 13
                                color: "#B38B42"
                            }

                            Text {
                                text: model.totalItemPrice.toLocaleString(Qt.locale("vi_VN"), "f", 0) + "đ"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#4A3025"
                            }

                            // Nút xóa/giảm bớt món
                            Rectangle {
                                width: 22; height: 22
                                color: "#D9534F"
                                radius: 11
                                Text {
                                    anchors.centerIn: parent
                                    text: "-"
                                    color: "white"
                                    font.bold: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: removeItemFromInvoice(index)
                                }
                            }
                        }
                    }
                }

                // Đường gạch ngang phân cách
                Rectangle {
                    Layout.fillWidth: true
                    height: 1.5
                    color: "#4A3025"
                }

                // Dòng hiển thị tổng tiền
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Tổng tiền:"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2C1D11"
                    }

                    Item { Layout.fillWidth: true } // Khoảng trống đẩy tổng tiền về bên phải

                    Text {
                        text: totalPrice.toLocaleString(Qt.locale("vi_VN"), "f", 0) + " VNĐ"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#8B0000" // Màu đỏ đậm nổi bật
                    }
                }

                // Nút "Thanh Toán _In Biên Lai"
                Button {
                    Layout.fillWidth: true
                    implicitHeight: 48

                    contentItem: Text {
                        text: "Thanh Toán _In Biên Lai"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? "#33221A" : "#4A3025"
                        radius: 5
                    }

                    onClicked: {
                        processPayment();
                    }
                }
            }
        }
    }
}