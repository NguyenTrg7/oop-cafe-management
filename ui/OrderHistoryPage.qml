import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    property string selectedInvoice: ""
    property var rawHistory: []

    // Danh sách cho các ComboBox bộ lọc
    property var dayList: {
        var arr = ["Tất cả ngày"];
        for(var i=1; i<=31; i++) arr.push(i.toString());
        return arr;
    }
    property var monthList: {
        var arr = ["Tất cả tháng"];
        for(var i=1; i<=12; i++) arr.push(i.toString());
        return arr;
    }
    property var yearList: {
        var arr = ["Tất cả năm", "2025", "2026", "2027"];
        return arr;
    }
    property var timeList: {
        var arr = ["Tất cả"];
        arr.push("07:30");
        for (var h = 8; h <= 21; h++) {
            var hh = (h < 10) ? "0" + h : "" + h;
            arr.push(hh + ":00");
            arr.push(hh + ":30");
        }
        return arr;
    }

    ListModel { id: filteredHistoryModel }

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("OrderHistoryPage.qml", "Lịch Sử Đơn Hàng")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("OrderHistoryPage.qml", "Lịch Sử Đơn Hàng")
            if (win.pageTitle !== undefined) win.pageTitle = "Lịch Sử Đơn Hàng"
        }
    }

    onVisibleChanged: {
        if (visible) {
            syncNavBar()
            loadHistory()
        }
    }

    Component.onCompleted: {
        syncNavBar()
        loadHistory()
    }

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
        }

        // BỘ LỌC THỜI GIAN
        Rectangle {
            Layout.fillWidth: true
            height: 55
            color: "#FFFFFF"
            radius: 8
            border.color: "#E2E8F0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text { text: "Ngày:"; font.bold: true; color: "#334155" }
                FilterCombo {
                    id: cbDay; model: dayList
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Text { text: "Tháng:"; font.bold: true; color: "#334155" }
                FilterCombo {
                    id: cbMonth; model: monthList
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Text { text: "Năm:"; font.bold: true; color: "#334155" }
                FilterCombo {
                    id: cbYear; model: yearList
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Item { Layout.preferredWidth: 10 }

                Text { text: "Từ giờ:"; font.bold: true; color: "#334155" }
                FilterCombo {
                    id: cbStartTime; model: timeList
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Text { text: "Đến giờ:"; font.bold: true; color: "#334155" }
                FilterCombo {
                    id: cbEndTime; model: timeList
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Item { Layout.fillWidth: true }
            }
        }

        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10

            model: filteredHistoryModel

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
                        selectedInvoice = model.invoiceNumber
                        var detail = orderHistoryManager.getOrderDetail(model.invoiceNumber)
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
                            text: model.invoiceNumber || ""
                            font.bold: true
                            font.pixelSize: 15
                            color: "#0C4A6E"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: (model.date || "") + "  •  " + (model.time || "")
                            font.pixelSize: 12
                            color: "#64748B"
                        }
                        Text {
                            text: (model.customerName || "Khách vãng lai") + "  •  "
                                  + (model.itemCount || 0) + " món"
                            font.pixelSize: 12
                            color: "#475569"
                        }
                    }

                    // Cột giá (cố định chiều rộng → thẳng hàng)
                    Text {
                        text: formatVND(model.totalAmount)
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
                text: "Chưa có đơn hàng nào khớp với tìm kiếm"
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
            loadHistory()
        }
    }
}