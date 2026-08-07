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

    function timeToMins(timeStr) {
        if (!timeStr) return 0;
        var p = timeStr.split(":");
        return parseInt(p[0]) * 60 + parseInt(p[1]);
    }

    function loadHistory() {
        if (typeof orderHistoryManager !== "undefined") {
            rawHistory = orderHistoryManager.getHistory();
            applyFilters();
        }
    }

    function applyFilters() {
        filteredHistoryModel.clear();

        var selDay = cbDay.currentIndex > 0 ? parseInt(cbDay.currentText) : -1;
        var selMonth = cbMonth.currentIndex > 0 ? parseInt(cbMonth.currentText) : -1;
        var selYear = cbYear.currentIndex > 0 ? parseInt(cbYear.currentText) : -1;
        var startMins = cbStartTime.currentIndex > 0 ? timeToMins(cbStartTime.currentText) : -1;
        var endMins = cbEndTime.currentIndex > 0 ? timeToMins(cbEndTime.currentText) : -1;

        for (var i = 0; i < rawHistory.length; i++) {
            var item = rawHistory[i];

            // Xử lý ngày (định dạng có thể là DD/MM/YYYY hoặc YYYY-MM-DD)
            var dYear = -1, dMonth = -1, dDay = -1;
            if (item.date.indexOf("/") !== -1) {
                var dParts = item.date.split("/");
                dDay = parseInt(dParts[0]);
                dMonth = parseInt(dParts[1]);
                dYear = parseInt(dParts[2]);
            } else {
                var dParts2 = item.date.split("-");
                dYear = parseInt(dParts2[0]);
                dMonth = parseInt(dParts2[1]);
                dDay = parseInt(dParts2[2]);
            }

            // Xử lý thời gian
            var itemMins = timeToMins(item.time);

            // Kiểm tra các điều kiện lọc
            if (selDay !== -1 && dDay !== selDay) continue;
            if (selMonth !== -1 && dMonth !== selMonth) continue;
            if (selYear !== -1 && dYear !== selYear) continue;
            if (startMins !== -1 && itemMins < startMins) continue;
            if (endMins !== -1 && itemMins > endMins) continue;

            filteredHistoryModel.append(item);
        }
    }

    // Component ComboBox giới hạn chiều cao tối đa (250px) để không bị che khuất màn hình
    component FilterCombo : ComboBox {
        id: control
        popup: Popup {
            y: control.height - 1
            width: control.width
            implicitHeight: Math.min(250, contentItem.implicitHeight)
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                border.color: "#CBD5E1"
                border.width: 1
                radius: 4
                color: "#FFFFFF"
            }
        }
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
            spacing: 8

            model: filteredHistoryModel

            delegate: Rectangle {
                width: historyList.width
                height: 82
                radius: 10
                // Lưu ý: Đã sửa từ modelData thành model
                color: selectedInvoice === model.invoiceNumber ? "#EFEBE9" : "#FFFDF9"
                border.color: selectedInvoice === model.invoiceNumber ? "#8D6E63" : "#E0D5C8"

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
                    spacing: 15

                    // Cột thông tin bên trái
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: model.invoiceNumber || ""
                            font.bold: true
                            font.pixelSize: 15
                            color: "#3E2723"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: (model.date || "") + "  •  " + (model.time || "")
                            font.pixelSize: 12
                            color: "#757575"
                        }
                        Text {
                            text: (model.customerName || "Khách vãng lai") + "  •  "
                                  + (model.itemCount || 0) + " món"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                    }

                    // Cột giá (cố định chiều rộng → thẳng hàng)
                    Text {
                        text: formatVND(model.totalAmount)
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
                text: "Chưa có đơn hàng nào khớp với tìm kiếm"
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
            loadHistory()
        }
    }
}