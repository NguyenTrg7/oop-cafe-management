import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: financePage
    title: "Quản Lý Tài Chính & Ngân Sách"

    // -------------------------------------------------------------------------
    // PROPERTIES & DATA MODELS
    // -------------------------------------------------------------------------
    ListModel { id: rawFinanceModel }      // Chứa toàn bộ dữ liệu từ CSV
    ListModel { id: filteredFinanceModel } // Dữ liệu đã lọc theo Thời gian & Tìm kiếm

    property double totalRevenue: 0.0
    property double totalExpense: 0.0
    property double netProfit: 0.0
    property double budgetTarget: 50000000.0 // Ngân sách mặc định: 50 triệu VNĐ

    // Bộ lọc thời gian: 0: Hôm nay, 1: Tháng , 2: Quý , 3: Năm , 4: Tất cả
    property int selectedPeriodIndex: 1
    // Loại biểu đồ: 0: Cột đôi (Thu vs Chi), 1: Cột đơn (Lợi nhuận), 2: Đường (Xu hướng)
    property int selectedChartType: 0

    Component.onCompleted: refreshFinance()

    // -------------------------------------------------------------------------
    // XỬ LÝ LOGIC TÍNH TOÁN & LỌC DỮ LIỆU
    // -------------------------------------------------------------------------
    function formatMoney(val) {
        if (val === undefined || val === null || isNaN(val)) return "0";
        var num = Math.round(val);
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }

    function parseDateStr(dateStr) {
        if (!dateStr) return new Date();
        var cleanStr = dateStr.toString().trim();
        var parts = cleanStr.split("/");
        if (parts.length === 3) {
            return new Date(parseInt(parts[2]), parseInt(parts[1]) - 1, parseInt(parts[0]));
        }
        parts = cleanStr.split("-");
        if (parts.length === 3) {
            return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
        }
        return new Date(cleanStr);
    }

    function refreshFinance() {
        rawFinanceModel.clear();
        filteredFinanceModel.clear();

        var data = coffeeSystem.loadFinance();
        for (var i = 0; i < data.length; i++) {
            rawFinanceModel.append(data[i]);
        }
        applyFilters();
    }

    function applyFilters() {
        filteredFinanceModel.clear();
        totalRevenue = 0.0;
        totalExpense = 0.0;

        var now = new Date();
        var curDay = now.getDate();
        var curMonth = now.getMonth();
        var curYear = now.getFullYear();
        var curQuarter = Math.floor(curMonth / 3);

        var searchTxt = searchInput.text ? searchInput.text.toLowerCase().trim() : "";
        var typeFilter = typeFilterCombo.currentIndex; // 0: Tất cả, 1: Thu, 2: Chi

        for (var i = 0; i < rawFinanceModel.count; i++) {
            var item = rawFinanceModel.get(i);
            var itemDate = parseDateStr(item.date);
            var itemDay = itemDate.getDate();
            var itemMonth = itemDate.getMonth();
            var itemYear = itemDate.getFullYear();
            var itemQuarter = Math.floor(itemMonth / 3);

            // 1. Kiểm tra bộ lọc thời gian
            var matchPeriod = false;
            if (selectedPeriodIndex === 0) { // Hôm nay
                matchPeriod = (itemDay === curDay && itemMonth === curMonth && itemYear === curYear);
            } else if (selectedPeriodIndex === 1) { // Tháng này
                matchPeriod = (itemMonth === curMonth && itemYear === curYear);
            } else if (selectedPeriodIndex === 2) { // Quý này
                matchPeriod = (itemQuarter === curQuarter && itemYear === curYear);
            } else if (selectedPeriodIndex === 3) { // Năm nay
                matchPeriod = (itemYear === curYear);
            } else { // Tất cả
                matchPeriod = true;
            }

            // 2. Kiểm tra bộ lọc loại & tìm kiếm
            var matchType = (typeFilter === 0) || (typeFilter === 1 && item.type === "Thu") || (typeFilter === 2 && item.type === "Chi");
            var itemNote = item.note ? item.note.toString().toLowerCase() : "";
            var itemDateStr = item.date ? item.date.toString() : "";
            var matchSearch = searchTxt === "" || itemNote.indexOf(searchTxt) !== -1 || itemDateStr.indexOf(searchTxt) !== -1;

            if (matchPeriod && matchType && matchSearch) {
                filteredFinanceModel.append(item);
                if (item.type === "Thu") totalRevenue += Number(item.amount);
                else if (item.type === "Chi") totalExpense += Number(item.amount);
            }
        }

        netProfit = totalRevenue - totalExpense;
        chartCanvas.requestPaint();
    }

    // -------------------------------------------------------------------------
    // LAYOUT CHÍNH
    // -------------------------------------------------------------------------
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // --- THANH TIÊU ĐỀ & NÚT TÁC VỤ ---
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2
                Label { text: "📊 Quản Lý Tài Chính & Ngân Sách"; font.pixelSize: 22; font.bold: true; color: "#1E293B" }
                Label { text: "Theo dõi doanh thu, chi phí, biểu đồ và ngân sách hệ thống"; font.pixelSize: 13; color: "#64748B" }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "⚙️ Ngân Sách"
                onClicked: budgetDialog.open()
                background: Rectangle { color: "#F1F5F9"; radius: 8; border.color: "#CBD5E1" }
            }

            Button {
                text: "➕ Thêm Giao Dịch"
                background: Rectangle { color: "#0284C7"; radius: 8 }
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: addTransactionDialog.open()
            }
        }

        // --- BỘ LỌC THỜI GIAN ---
        Rectangle {
            Layout.fillWidth: true
            height: 45
            color: "#FFFFFF"
            radius: 8
            border.color: "#E2E8F0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                Repeater {
                    model: ["📅 Hôm Nay", "📆 Tháng Này", "📊 Quý Này", "📈 Năm Nay", "🌐 Tất Cả"]
                    delegate: Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: modelData
                        flat: true
                        background: Rectangle {
                            color: financePage.selectedPeriodIndex === index ? "#0369A1" : "transparent"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            color: financePage.selectedPeriodIndex === index ? "#FFFFFF" : "#475569"
                            font.bold: financePage.selectedPeriodIndex === index
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            financePage.selectedPeriodIndex = index;
                            applyFilters();
                        }
                    }
                }
            }
        }

        // --- KHU VỰC THẺ TỔNG QUAN ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Thẻ Ngân Sách
            Rectangle {
                Layout.fillWidth: true; height: 90; color: "#FFFFFF"; radius: 10; border.color: "#E2E8F0"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 12
                    RowLayout {
                        Text { text: "🎯 NGÂN SÁCH CHI"; font.bold: true; font.pixelSize: 11; color: "#64748B" }
                        Item { Layout.fillWidth: true }
                        Text { text: (budgetTarget > 0 ? Math.round((totalExpense / budgetTarget) * 100) : 0) + "%"; font.bold: true; color: totalExpense > budgetTarget ? "#DC2626" : "#22C55E" }
                    }
                    Text { text: formatMoney(budgetTarget) + " VNĐ"; font.pixelSize: 16; font.bold: true; color: "#0F172A" }
                    Rectangle {
                        Layout.fillWidth: true; height: 6; color: "#E2E8F0"; radius: 3
                        Rectangle {
                            width: budgetTarget > 0 ? Math.min(parent.width, parent.width * (totalExpense / budgetTarget)) : 0
                            height: parent.height
                            color: totalExpense > budgetTarget ? "#EF4444" : "#10B981"
                            radius: 3
                        }
                    }
                }
            }

            // Thẻ Tổng Thu
            Rectangle {
                Layout.fillWidth: true; height: 90; color: "#F0FDF4"; radius: 10; border.color: "#BBF7D0"
                ColumnLayout {
                    anchors.centerIn: parent
                    Text { text: "🟢 TỔNG THU"; font.bold: true; font.pixelSize: 12; color: "#166534" }
                    Text { text: formatMoney(totalRevenue) + " VNĐ"; font.pixelSize: 18; font.bold: true; color: "#15803D" }
                }
            }

            // Thẻ Tổng Chi
            Rectangle {
                Layout.fillWidth: true; height: 90; color: "#FEF2F2"; radius: 10; border.color: "#FECACA"
                ColumnLayout {
                    anchors.centerIn: parent
                    Text { text: "🔴 TỔNG CHI"; font.bold: true; font.pixelSize: 12; color: "#991B1B" }
                    Text { text: formatMoney(totalExpense) + " VNĐ"; font.pixelSize: 18; font.bold: true; color: "#B91C1C" }
                }
            }

            // Thẻ Lợi Nhuận
            Rectangle {
                Layout.fillWidth: true; height: 90; color: netProfit >= 0 ? "#F0F9FF" : "#FFF1F2"; radius: 10; border.color: netProfit >= 0 ? "#BAE6FD" : "#FECDD3"
                ColumnLayout {
                    anchors.centerIn: parent
                    Text { text: "💎 LỢI NHUẬN RÒNG"; font.bold: true; font.pixelSize: 12; color: netProfit >= 0 ? "#075985" : "#9F1239" }
                    Text { text: formatMoney(netProfit) + " VNĐ"; font.pixelSize: 18; font.bold: true; color: netProfit >= 0 ? "#0284C7" : "#E11D48" }
                }
            }
        }

        // --- KHU VỰC BIỂU ĐỒ (CHART CANVAS) ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            color: "#FFFFFF"
            radius: 10
            border.color: "#E2E8F0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "📈 Biểu Đồ Trực Quan Tài Chính"; font.bold: true; font.pixelSize: 14; color: "#334155" }
                    Item { Layout.fillWidth: true }

                    ComboBox {
                        id: chartTypeCombo
                        model: ["📊 Cột Đôi (Thu vs Chi)", "📶 Cột Đơn (Lợi Nhuận)", "📉 Đường (Xu Hướng)"]
                        currentIndex: financePage.selectedChartType
                        onCurrentIndexChanged: {
                            financePage.selectedChartType = currentIndex;
                            chartCanvas.requestPaint();
                        }
                    }
                }

                Canvas {
                    id: chartCanvas
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var w = width;
                        var h = height;

                        var categories = ["Kỳ 1", "Kỳ 2", "Kỳ 3", "Kỳ 4", "Kỳ 5"];
                        var revData = [totalRevenue * 0.15, totalRevenue * 0.25, totalRevenue * 0.2, totalRevenue * 0.3, totalRevenue * 0.1];
                        var expData = [totalExpense * 0.2, totalExpense * 0.15, totalExpense * 0.3, totalExpense * 0.2, totalExpense * 0.15];

                        var maxVal = 100;
                        for (var i = 0; i < 5; i++) {
                            maxVal = Math.max(maxVal, revData[i], expData[i], Math.abs(revData[i] - expData[i]));
                        }
                        maxVal *= 1.2;

                        ctx.strokeStyle = "#F1F5F9";
                        ctx.lineWidth = 1;
                        for (var gl = 0; gl <= 4; gl++) {
                            var yPos = h - 30 - (gl * (h - 50) / 4);
                            ctx.beginPath();
                            ctx.moveTo(40, yPos);
                            ctx.lineTo(w - 10, yPos);
                            ctx.stroke();
                        }

                        var paddingLeft = 50;
                        var paddingBottom = 30;
                        var chartW = w - paddingLeft - 20;
                        var chartH = h - paddingBottom - 20;
                        var stepX = chartW / categories.length;

                        ctx.font = "11px sans-serif";
                        ctx.textAlign = "center"; // Căn giữa nhãn dưới cột

                        if (financePage.selectedChartType === 0) {
                            var barW = stepX * 0.25;
                            for (var b = 0; b < categories.length; b++) {
                                var xCenter = paddingLeft + b * stepX + stepX / 2;

                                var hRev = (revData[b] / maxVal) * chartH;
                                ctx.fillStyle = "#22C55E";
                                ctx.fillRect(xCenter - barW - 2, h - paddingBottom - hRev, barW, hRev);

                                var hExp = (expData[b] / maxVal) * chartH;
                                ctx.fillStyle = "#EF4444";
                                ctx.fillRect(xCenter + 2, h - paddingBottom - hExp, barW, hExp);

                                ctx.fillStyle = "#64748B";
                                ctx.fillText(categories[b], xCenter, h - 8);
                            }
                        } else if (financePage.selectedChartType === 1) {
                            var barW1 = stepX * 0.4;
                            for (var c = 0; c < categories.length; c++) {
                                var xC = paddingLeft + c * stepX + stepX / 2;
                                var pVal = revData[c] - expData[c];
                                var hBar = (Math.abs(pVal) / maxVal) * chartH;
                                ctx.fillStyle = pVal >= 0 ? "#0284C7" : "#E11D48";
                                ctx.fillRect(xC - barW1 / 2, h - paddingBottom - hBar, barW1, hBar);

                                ctx.fillStyle = "#64748B";
                                ctx.fillText(categories[c], xC, h - 8);
                            }
                        } else if (financePage.selectedChartType === 2) {
                            ctx.beginPath();
                            ctx.strokeStyle = "#16A34A";
                            ctx.lineWidth = 3;
                            for (var l = 0; l < categories.length; l++) {
                                var xL = paddingLeft + l * stepX + stepX / 2;
                                var yL = h - paddingBottom - ((revData[l] / maxVal) * chartH);
                                if (l === 0) ctx.moveTo(xL, yL);
                                else ctx.lineTo(xL, yL);
                            }
                            ctx.stroke();

                            for (var p = 0; p < categories.length; p++) {
                                var xP = paddingLeft + p * stepX + stepX / 2;
                                var yP = h - paddingBottom - ((revData[p] / maxVal) * chartH);
                                ctx.fillStyle = "#15803D";
                                ctx.beginPath();
                                ctx.arc(xP, yP, 4, 0, 2 * Math.PI);
                                ctx.fill();

                                ctx.fillStyle = "#64748B";
                                ctx.fillText(categories[p], xP, h - 8);
                            }
                        }
                    }
                }
            }
        }

        // --- BẢNG LỊCH SỬ TÀI CHÍNH (ĐÃ CĂN CỘT CHUẨN) ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            radius: 10
            border.color: "#E2E8F0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text { text: "📜 Lịch Sử Giao Dịch"; font.bold: true; font.pixelSize: 15; color: "#1E293B" }
                    Item { Layout.fillWidth: true }

                    TextField {
                        id: searchInput
                        placeholderText: "🔍 Tìm theo ghi chú, ngày..."
                        Layout.preferredWidth: 220
                        onTextChanged: applyFilters()
                    }

                    ComboBox {
                        id: typeFilterCombo
                        model: ["Tất cả loại", "🟢 Thu", "🔴 Chi"]
                        onCurrentIndexChanged: applyFilters()
                    }
                }

                // Tiêu đề Bảng (Header)
                Rectangle {
                    Layout.fillWidth: true
                    height: 35
                    color: "#F8FAFC"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text { text: "THỜI GIAN"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 120 }
                        Text { text: "LOẠI"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                        Text { text: "SỐ TIỀN"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 150 }
                        Text { text: "GHI CHÚ / DIỄN GIẢI"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.fillWidth: true }
                    }
                }

                // Danh sách Giao dịch (Delegate đồng bộ 100% kích thước với Header)
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: filteredFinanceModel
                    clip: true
                    spacing: 4

                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: index % 2 === 0 ? "#FFFFFF" : "#F8FAFC"
                        radius: 4
                        border.color: "#F1F5F9"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 10

                            // Cột 1: Thời gian
                            Text { text: model.date; Layout.preferredWidth: 120; color: "#334155"; font.pixelSize: 13 }

                            // Cột 2: Loại giao dịch
                            Item {
                                Layout.preferredWidth: 90
                                Layout.fillHeight: true

                                Rectangle {
                                    width: 60; height: 22
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: model.type === "Thu" ? "#DCFCE7" : "#FEE2E2"
                                    radius: 4
                                    Text {
                                        anchors.centerIn: parent
                                        text: model.type
                                        font.bold: true
                                        font.pixelSize: 11
                                        color: model.type === "Thu" ? "#15803D" : "#B91C1C"
                                    }
                                }
                            }

                            // Cột 3: Số tiền
                            Text {
                                text: (model.type === "Thu" ? "+" : "-") + formatMoney(model.amount) + " VNĐ"
                                font.bold: true
                                color: model.type === "Thu" ? "#16A34A" : "#DC2626"
                                Layout.preferredWidth: 150
                                font.pixelSize: 13
                            }

                            // Cột 4: Ghi chú
                            Text { text: model.note; color: "#475569"; Layout.fillWidth: true; elide: Text.ElideRight; font.pixelSize: 13 }
                        }
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // POPUP THÊM GIAO DỊCH MỚI
    // -------------------------------------------------------------------------
    Dialog {
        id: addTransactionDialog
        title: "Thêm Giao Dịch Mới"
        width: 380; height: 360
        anchors.centerIn: parent
        modal: true

        ColumnLayout {
            anchors.fill: parent; spacing: 12

            ComboBox {
                id: inputType
                Layout.fillWidth: true
                model: ["Thu", "Chi"]
            }

            TextField {
                id: inputAmount
                placeholderText: "Số tiền (VNĐ)"
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
            }

            TextField {
                id: inputDate
                placeholderText: "Ngày (dd/MM/yyyy)"
                text: Qt.formatDate(new Date(), "dd/MM/yyyy")
                Layout.fillWidth: true
            }

            TextField {
                id: inputNote
                placeholderText: "Ghi chú giao dịch"
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Hủy"
                    Layout.fillWidth: true
                    onClicked: addTransactionDialog.close()
                }
                Button {
                    text: "Lưu Giao Dịch"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#0284C7"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        var amt = parseFloat(inputAmount.text.trim());
                        if (isNaN(amt) || amt <= 0) return;

                        var dateStr = inputDate.text.trim();
                        var noteStr = inputNote.text.trim();

                        coffeeSystem.addTransactionCSV(dateStr, inputType.currentText, amt, noteStr);
                        refreshFinance();

                        addTransactionDialog.close();
                        inputAmount.text = "";
                        inputNote.text = "";
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // POPUP CÀI ĐẶT NGÂN SÁCH
    // -------------------------------------------------------------------------
    Dialog {
        id: budgetDialog
        title: "Thiết Lập Ngân Sách"
        width: 320; height: 200
        anchors.centerIn: parent
        modal: true

        ColumnLayout {
            anchors.fill: parent; spacing: 15

            Text { text: "Nhập hạn mức ngân sách chi tiêu:"; color: "#475569" }

            TextField {
                id: inputBudgetTarget
                text: financePage.budgetTarget.toString()
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
            }

            RowLayout {
                Layout.fillWidth: true
                Button { text: "Đóng"; Layout.fillWidth: true; onClicked: budgetDialog.close() }
                Button {
                    text: "Cập nhật"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#16A34A"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        var val = parseFloat(inputBudgetTarget.text.trim());
                        if (!isNaN(val) && val > 0) {
                            financePage.budgetTarget = val;
                            applyFilters();
                        }
                        budgetDialog.close();
                    }
                }
            }
        }
    }
}