import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: orderPage
    background: Rectangle { color: "#F4EBD0" } // Màu kem giấy cũ

    // Dữ liệu mẫu (Sẽ được thay thế bằng Model C++ từ QList<Menu> m_menuItems)
    ListModel {
        id: menuModel
        ListElement { name: "Cà phê Đen Pha Phin"; price: 25000; size: "M" }
        ListElement { name: "Bạc Xỉu Cốt Dừa"; price: 35000; size: "L" }
        ListElement { name: "Trà Sen Vàng"; price: 40000; size: "M" }
        ListElement { name: "Cacao Nóng Trứng"; price: 45000; size: "M" }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Phân vùng 1: Danh sách Menu
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 6
            color: "transparent"
            border.color: "#B68D40" // Viền vàng đồng
            border.width: 2
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Label {
                    text: "Thực Đơn Cổ Điển"
                    font.family: "Georgia"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#4E3629" // Nâu cà phê
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#B68D40" }

                GridView {
                    id: menuGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: width / 2
                    cellHeight: 120
                    model: menuModel
                    clip: true

                    delegate: Item {
                        width: menuGrid.cellWidth
                        height: menuGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "#E8DDB5"
                            radius: 5
                            border.color: "#D4C49A"

                            ColumnLayout {
                                anchors.centerIn: parent
                                Label {
                                    text: name
                                    font.family: "Times New Roman"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#3E2723"
                                }
                                Label {
                                    text: price + " VNĐ - Size: " + size
                                    font.family: "Times New Roman"
                                    font.pixelSize: 14
                                    color: "#5D4037"
                                }
                                Button {
                                    text: "+ Thêm vào đơn"
                                    font.family: "Georgia"
                                    background: Rectangle { color: "#B68D40"; radius: 3 }
                                    palette.buttonText: "white"
                                    // Logic gọi C++: GiangCoffeeSystem.addItem(...)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Phân vùng 2: Hóa đơn & Thanh toán
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 4
            color: "#FFF8E7"
            border.color: "#4E3629"
            border.width: 2
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15

                Label {
                    text: "Hóa Đơn Hiện Tại"
                    font.family: "Georgia"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#4E3629"
                }

                // Khu vực hiển thị danh sách món đã chọn (Giả lập trống)
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    // model: orderItemsModel (Từ C++ QList<Menu> m_items)
                }

                Rectangle { Layout.fillWidth: true; height: 2; color: "#4E3629" }

                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Tổng tiền:"; font.family: "Times New Roman"; font.pixelSize: 18; font.bold: true }
                    Item { Layout.fillWidth: true } // Spacer
                    Label {
                        text: "0 VNĐ" // Kết nối với hàm getTotalPrice() của class Order
                        font.family: "Times New Roman"; font.pixelSize: 18; color: "#D32F2F"; font.bold: true
                    }
                }

                Button {
                    text: "Thanh Toán & In Biên Lai"
                    font.family: "Georgia"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    background: Rectangle { color: "#4E3629"; radius: 5 }
                    palette.buttonText: "#F4EBD0"
                    // Logic gọi C++: currentOrder->printInvoice() và lưu dữ liệu
                }
            }
        }
    }
}