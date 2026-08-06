import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    property string selectedInvoice: ""

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("OrderHistoryPage.qml", "Lịch Sử Đơn Hàng")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("OrderHistoryPage.qml", "Lịch Sử Đơn Hàng")
            if (win.pageTitle !== undefined) win.pageTitle = "Lịch Sử Đơn Hàng"
        }
    }

    onVisibleChanged: {
        if (visible) syncNavBar()
    }

    Component.onCompleted: syncNavBar()

    function formatVND(value) {
        value = Math.round(Number(value) || 0)
        return Qt.locale("vi_VN").toString(value) + " VNĐ"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "📜 LỊCH SỬ ĐƠN HÀNG"
                font.pixelSize: 22
                font.bold: true
                color: "#3E2723"
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "← Quay lại"
                onClicked: {
                    if (typeof orderPageRoot !== "undefined") {
                        orderPageRoot.showingInventory = false
                        orderPageRoot.showingHistory = false
                    } else if (StackView.view) {
                        StackView.view.pop()
                    }
                }
            }
        }

        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8

            model: typeof orderHistoryManager !== "undefined"
                   ? orderHistoryManager.getHistory()
                   : []

            delegate: Rectangle {
                width: historyList.width
                height: 82
                radius: 10
                color: selectedInvoice === modelData.invoiceNumber ? "#EFEBE9" : "#FFFDF9"
                border.color: selectedInvoice === modelData.invoiceNumber ? "#8D6E63" : "#E0D5C8"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        selectedInvoice = modelData.invoiceNumber
                        var detail = orderHistoryManager.getOrderDetail(modelData.invoiceNumber)
                        invoiceDialog.openWith(detail)
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 15

                    // Cột thông tin bên trái
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: modelData.invoiceNumber || ""
                            font.bold: true
                            font.pixelSize: 15
                            color: "#3E2723"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: (modelData.date || "") + "  •  " + (modelData.time || "")
                            font.pixelSize: 12
                            color: "#757575"
                        }
                        Text {
                            text: (modelData.customerName || "Khách vãng lai") + "  •  "
                                  + (modelData.itemCount || 0) + " món"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                    }

                    // Cột giá (cố định chiều rộng → thẳng hàng)
                    Text {
                        text: formatVND(modelData.totalAmount)
                        font.bold: true
                        font.pixelSize: 16
                        color: "#BF360C"
                        Layout.preferredWidth: 130
                        Layout.minimumWidth: 130
                        Layout.maximumWidth: 130
                        horizontalAlignment: Text.AlignRight
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: historyList.count === 0
                text: "Chưa có đơn hàng nào"
                font.pixelSize: 16
                color: "#9E9E9E"
            }
        }
    }

    InvoiceDialog {
        id: invoiceDialog
        showFinishButton: false
    }

    Connections {
        target: typeof orderHistoryManager !== "undefined" ? orderHistoryManager : null
        function onHistoryChanged() {
            historyList.model = orderHistoryManager.getHistory()
        }
    }
}