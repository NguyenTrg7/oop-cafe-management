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

    Rectangle {
        anchors.fill: parent
        color: "#F0F9FF"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "📜 LỊCH SỬ ĐƠN HÀNG"
                font.pixelSize: 22
                font.bold: true
                color: "#0C4A6E"
            }

            Item { Layout.fillWidth: true }

            // Button {
            //     text: "← Quay lại"
            //     onClicked: {
            //         if (typeof orderPageRoot !== "undefined") {
            //             orderPageRoot.showingInventory = false
            //             orderPageRoot.showingHistory = false
            //         } else if (StackView.view) {
            //             StackView.view.pop()
            //         }
            //     }
            // }
        }

        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10

            model: typeof orderHistoryManager !== "undefined"
                   ? orderHistoryManager.getHistory()
                   : []

            delegate: Rectangle {
                width: historyList.width
                height: 86
                radius: 12
                color: selectedInvoice === modelData.invoiceNumber ? "#E0F2FE" : "#FFFFFF"
                border.color: selectedInvoice === modelData.invoiceNumber ? "#3B82F6" : "#BAE6FD"
                border.width: selectedInvoice === modelData.invoiceNumber ? 2 : 1.5
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
                    spacing: 16

                    // Cột thông tin bên trái
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.invoiceNumber || ""
                            font.bold: true
                            font.pixelSize: 15
                            color: "#0C4A6E"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: (modelData.date || "") + "  •  " + (modelData.time || "")
                            font.pixelSize: 12
                            color: "#64748B"
                        }
                        Text {
                            text: (modelData.customerName || "Khách vãng lai") + "  •  "
                                  + (modelData.itemCount || 0) + " món"
                            font.pixelSize: 12
                            color: "#475569"
                        }
                    }

                    // Cột giá (cố định chiều rộng → thẳng hàng)
                    Text {
                        text: formatVND(modelData.totalAmount)
                        font.bold: true
                        font.pixelSize: 16
                        color: "#0369A1"
                        Layout.preferredWidth: 140
                        Layout.minimumWidth: 140
                        Layout.maximumWidth: 140
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
                color: "#94A3B8"
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