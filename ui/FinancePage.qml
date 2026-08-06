import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: financePage
    title: "Quản Lý Tài Chính & Ngân Sách"

    // -------------------------------------------------------------------------
    // PROPERTIES & DATA MODELS
    // -------------------------------------------------------------------------
    ListModel { id: rawFinanceModel }      // Chứa toàn bộ dữ liệu từ CSV
    ListModel { id: filteredFinanceModel } // Dữ liệu đã lọc

    property double totalRevenue: 0.0
    property double totalExpense: 0.0
    property double netProfit: 0.0
    property double budgetTarget: 50000000.0

    // Dữ liệu dùng cho vẽ biểu đồ
    property var chartLabels: []
    property var chartRev: []
    property var chartExp: []
    property var chartProfit: []
    property var chartIsFuture: [] // Mảng cờ đánh dấu các mốc ở tương lai

    Component.onCompleted: {
        // Init years model
        var currentYear = new Date().getFullYear();
        var years = [];
        for (var i = currentYear - 5; i <= currentYear + 5; i++) {
            years.push(i.toString());
        }
        cbYear.model = years;
        cbYear.currentIndex = 5; // Focus vào năm hiện tại
        cbMonth.currentIndex = new Date().getMonth();

        refreshFinance();
    }

    // -------------------------------------------------------------------------
    // XỬ LÝ LOGIC TÍNH TOÁN & LỌC DỮ LIỆU
    // -------------------------------------------------------------------------
    function formatMoney(val) {
        if (val === undefined || val === null || isNaN(val)) return "0";
        var num = Math.round(val);
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }

    function formatAxisNumber(val) {
        if (val === undefined || val === null || isNaN(val)) return "0";
        var absVal = Math.abs(val);
        var sign = val < 0 ? "-" : "";
        if (absVal >= 1000000000) return sign + (absVal / 1000000000).toFixed(1).replace(/\.0$/, '') + "b";
        if (absVal >= 1000000) return sign + (absVal / 1000000).toFixed(1).replace(/\.0$/, '') + "m";
        if (absVal >= 1000) return sign + (absVal / 1000).toFixed(1).replace(/\.0$/, '') + "k";
        return sign + Math.round(absVal).toString();
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

        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadFinance) {
            var data = coffeeSystem.loadFinance();
            for (var i = 0; i < data.length; i++) {
                rawFinanceModel.append(data[i]);
            }
        }
        Qt.callLater(applyFilters);
    }

    function applyFilters() {
        var m_mode = cbViewMode.currentIndex; // 0: Tuần, 1: Tháng, 2: Năm
        var m_year = parseInt(cbYear.currentText);
        // Fallback an toàn nếu UI chưa kịp map text của ComboBox
        if (isNaN(m_year)) m_year = new Date().getFullYear();

        var m_month = cbMonth.currentIndex; // 0-11
        var m_week = cbWeek.currentIndex; // 0-3
        var m_measure = cbYearMeasure.currentIndex; // 0: Tháng, 1: Quý

        var labels = [];
        var rev = [];
        var exp = [];
        var profit = [];
        var isFuture = [];
        var numBuckets = 0;

        var now = new Date();
        var curY = now.getFullYear();
        var curM = now.getMonth();
        var curD = now.getDate();
        // Mốc so sánh ngày hiện tại (Bỏ qua giờ phút giây)
        var today = new Date(curY, curM, curD);

        // 1. THIẾT LẬP TRỤC X & XÁC ĐỊNH MỐC TƯƠNG LAI
        if (m_mode === 0) {
            numBuckets = 7;
            var startDay = m_week * 7 + 1;
            for (var i = 0; i < 7; i++) {
                var dayDate = startDay + i;
                var dObj = new Date(m_year, m_month, dayDate);
                labels.push("Ngày " + dayDate);
                rev.push(0); exp.push(0); profit.push(0);
                isFuture.push(dObj > today);
            }
        } else if (m_mode === 1) {
            numBuckets = 4;
            labels = ["Tuần 1", "Tuần 2", "Tuần 3", "Tuần 4"];
            for (var iw = 0; iw < 4; iw++) {
                var wStart = new Date(m_year, m_month, iw * 7 + 1);
                rev.push(0); exp.push(0); profit.push(0);
                isFuture.push(wStart > today);
            }
        } else if (m_mode === 2) {
            if (m_measure === 0) { // Năm chia theo tháng
                numBuckets = 12;
                labels = ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"];
                for (var m = 0; m < 12; m++) {
                    rev.push(0); exp.push(0); profit.push(0);
                    var mStart = new Date(m_year, m, 1);
                    isFuture.push(mStart > today);
                }
            } else { // Năm chia theo quý
                numBuckets = 4;
                labels = ["Quý 1", "Quý 2", "Quý 3", "Quý 4"];
                for (var q = 0; q < 4; q++) {
                    rev.push(0); exp.push(0); profit.push(0);
                    var qStart = new Date(m_year, q * 3, 1);
                    isFuture.push(qStart > today);
                }
            }
        }

        // 2. TÍNH TOÁN DỮ LIỆU CHO BIỂU ĐỒ & TỔNG QUAN
        var totalRevChart = 0.0;
        var totalExpChart = 0.0;

        for (var i = 0; i < rawFinanceModel.count; i++) {
            var item = rawFinanceModel.get(i);
            var itemDate = parseDateStr(item.date);
            var dYear = itemDate.getFullYear();
            var dMonth = itemDate.getMonth();
            var dDate = itemDate.getDate();

            var matchPeriod = false;
            var bucketIndex = -1;

            if (m_mode === 0) {
                var startDayW = m_week * 7 + 1;
                var endDayW = (m_week === 3) ? 31 : (startDayW + 6);
                if (dYear === m_year && dMonth === m_month && dDate >= startDayW && dDate <= endDayW) {
                    matchPeriod = true;
                    bucketIndex = Math.min(dDate - startDayW, 6);
                }
            } else if (m_mode === 1) {
                if (dYear === m_year && dMonth === m_month) {
                    matchPeriod = true;
                    bucketIndex = Math.floor((dDate - 1) / 7);
                    if (bucketIndex > 3) bucketIndex = 3;
                }
            } else if (m_mode === 2) {
                if (dYear === m_year) {
                    matchPeriod = true;
                    if (m_measure === 0) bucketIndex = dMonth;
                    else bucketIndex = Math.floor(dMonth / 3);
                }
            }

            if (matchPeriod) {
                var amount = Number(item.amount);
                if (item.type === "Thu") {
                    totalRevChart += amount;
                    if (bucketIndex >= 0 && bucketIndex < numBuckets) rev[bucketIndex] += amount;
                } else if (item.type === "Chi") {
                    totalExpChart += amount;
                    if (bucketIndex >= 0 && bucketIndex < numBuckets) exp[bucketIndex] += amount;
                }
            }
        }

        for (var j = 0; j < numBuckets; j++) {
            profit[j] = rev[j] - exp[j];
        }

        totalRevenue = totalRevChart;
        totalExpense = totalExpChart;
        netProfit = totalRevenue - totalExpense;

        financePage.chartLabels = labels;
        financePage.chartRev = rev;
        financePage.chartExp = exp;
        financePage.chartProfit = profit;
        financePage.chartIsFuture = isFuture;

        // 3. LỌC DỮ LIỆU DANH SÁCH LỊCH SỬ BÊN DƯỚI
        filteredFinanceModel.clear();
        var searchTxt = searchInput.text ? searchInput.text.toLowerCase().trim() : "";
        var typeFilter = typeFilterCombo.currentIndex;

        for (var idx = 0; idx < rawFinanceModel.count; idx++) {
            var fItem = rawFinanceModel.get(idx);
            var fDate = parseDateStr(fItem.date);
            var fdYear = fDate.getFullYear();
            var fdMonth = fDate.getMonth();
            var fdDate = fDate.getDate();

            var fMatchPeriod = false;
            if (m_mode === 0) {
                var sDay = m_week * 7 + 1;
                var eDay = (m_week === 3) ? 31 : (sDay + 6);
                if (fdYear === m_year && fdMonth === m_month && fdDate >= sDay && fdDate <= eDay) fMatchPeriod = true;
            } else if (m_mode === 1) {
                if (fdYear === m_year && fdMonth === m_month) fMatchPeriod = true;
            } else if (m_mode === 2) {
                if (fdYear === m_year) fMatchPeriod = true;
            }

            var fMatchType = (typeFilter === 0) || (typeFilter === 1 && fItem.type === "Thu") || (typeFilter === 2 && fItem.type === "Chi");
            var fNote = fItem.note ? fItem.note.toString().toLowerCase() : "";
            var fMatchSearch = searchTxt === "" || fNote.indexOf(searchTxt) !== -1;

            if (fMatchPeriod && fMatchType && fMatchSearch) {
                filteredFinanceModel.append(fItem);
            }
        }

        // Ép vẽ lại biểu đồ
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

        // --- BỘ LỌC THỜI GIAN & CHẾ ĐỘ XEM BIỂU ĐỒ ---
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

                Text { text: "Chế độ xem:"; font.bold: true; color: "#334155"; font.pixelSize: 13 }
                ComboBox {
                    id: cbViewMode
                    model: ["Tuần", "Tháng", "Năm"]
                    currentIndex: 1
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Text { text: "Khảo sát:"; font.bold: true; color: "#334155"; font.pixelSize: 13; Layout.leftMargin: 15 }

                ComboBox {
                    id: cbYear
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                    onCurrentTextChanged: Qt.callLater(applyFilters)
                }

                ComboBox {
                    id: cbMonth
                    model: ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"]
                    visible: cbViewMode.currentIndex < 2
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                ComboBox {
                    id: cbWeek
                    model: ["Tuần 1", "Tuần 2", "Tuần 3", "Tuần 4"]
                    visible: cbViewMode.currentIndex === 0
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                ComboBox {
                    id: cbYearMeasure
                    model: ["Theo Tháng", "Theo Quý"]
                    visible: cbViewMode.currentIndex === 2
                    onCurrentIndexChanged: Qt.callLater(applyFilters)
                }

                Item { Layout.fillWidth: true }
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

        // --- KHU VỰC BIỂU ĐỒ (CHART CANVAS) KẾT HỢP HAI TRỤC ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            color: "#FFFFFF"
            radius: 10
            border.color: "#E2E8F0"

            Canvas {
                id: chartCanvas
                anchors.fill: parent
                anchors.margins: 10

                // Đảm bảo Canvas resize sẽ kích hoạt vẽ lại
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var w = width;
                    var h = height;

                    var labels = financePage.chartLabels;
                    var revData = financePage.chartRev;
                    var expData = financePage.chartExp;
                    var profitData = financePage.chartProfit;
                    var isFuture = financePage.chartIsFuture;

                    if (labels.length === 0) return;

                    // 1. TÍNH TOÁN GIỚI HẠN TRỤC TRÁI (Cho Cột Thu / Chi)
                    var maxBar = 10;
                    for (var i = 0; i < labels.length; i++) {
                        if (!isFuture[i]) {
                            maxBar = Math.max(maxBar, revData[i], expData[i]);
                        }
                    }
                    maxBar *= 1.2;

                    // 2. TÍNH TOÁN GIỚI HẠN TRỤC PHẢI (Cho Đường Lợi Nhuận)
                    var pMax = -Infinity;
                    var pMin = Infinity;
                    var hasValidProfit = false;

                    for (var i = 0; i < labels.length; i++) {
                        if (!isFuture[i]) {
                            pMax = Math.max(pMax, profitData[i]);
                            pMin = Math.min(pMin, profitData[i]);
                            hasValidProfit = true;
                        }
                    }

                    if (!hasValidProfit) { pMax = 100; pMin = 0; }
                    if (pMin > 0) pMin = 0; // Đảm bảo số 0 được căn thẳng dưới đáy nếu lợi nhuận luôn dương
                    if (pMax === pMin) { pMax += 100; pMin -= 100; }

                    // Thêm khoảng đệm cho biên độ Lợi nhuận
                    var pRange = pMax - pMin;
                    pMax += pRange * 0.1;
                    if (pMin < 0) pMin -= pRange * 0.1;
                    pRange = pMax - pMin;

                    var paddingLeft = 55;
                    var paddingRight = 55;
                    var paddingTop = 40;
                    var paddingBottom = 30;
                    var chartW = w - paddingLeft - paddingRight;
                    var chartH = h - paddingTop - paddingBottom;
                    var stepX = chartW / labels.length;

                    // 3. VẼ LƯỚI GRID & NHÃN HAI TRỤC (AXES LABELS)
                    ctx.strokeStyle = "#E2E8F0";
                    ctx.lineWidth = 1;
                    ctx.font = "10px sans-serif";

                    for (var gl = 0; gl <= 4; gl++) {
                        var yPos = h - paddingBottom - (gl * chartH / 4);

                        // Vẽ lưới ngang
                        ctx.beginPath();
                        ctx.moveTo(paddingLeft, yPos);
                        ctx.lineTo(w - paddingRight, yPos);
                        ctx.stroke();

                        // Label trục trái (Thu/Chi)
                        var leftVal = gl * maxBar / 4;
                        ctx.textAlign = "right";
                        ctx.fillStyle = "#64748B";
                        ctx.fillText(formatAxisNumber(leftVal), paddingLeft - 8, yPos + 4);

                        // Label trục phải (Lợi nhuận)
                        var rightVal = pMin + gl * pRange / 4;
                        ctx.textAlign = "left";
                        ctx.fillStyle = "#0284C7"; // Màu xanh lam đồng bộ với đường
                        ctx.fillText(formatAxisNumber(rightVal), w - paddingRight + 8, yPos + 4);
                    }

                    // Vẽ Đơn vị ở trên đỉnh các trục
                    ctx.textAlign = "right";
                    ctx.fillStyle = "#64748B";
                    ctx.fillText("(VNĐ)", paddingLeft, paddingTop - 15);

                    ctx.textAlign = "left";
                    ctx.fillStyle = "#0284C7";
                    ctx.fillText("(VNĐ)", w - paddingRight, paddingTop - 15);

                    // 4. VẼ BIỂU ĐỒ CỘT THU/CHI VÀ GOM TỌA ĐỘ ĐIỂM LỢI NHUẬN
                    ctx.textAlign = "center";
                    var barW = stepX * 0.25;
                    if (barW > 30) barW = 30;
                    var profitPointsX = [];
                    var profitPointsY = [];

                    for (var b = 0; b < labels.length; b++) {
                        var xCenter = paddingLeft + b * stepX + stepX / 2;

                        if (!isFuture[b]) {
                            // Cột Thu
                            var hRev = (revData[b] / maxBar) * chartH;
                            ctx.fillStyle = "#22C55E";
                            ctx.fillRect(xCenter - barW - 1, h - paddingBottom - hRev, barW, hRev);

                            // Cột Chi
                            var hExp = (expData[b] / maxBar) * chartH;
                            ctx.fillStyle = "#EF4444";
                            ctx.fillRect(xCenter + 1, h - paddingBottom - hExp, barW, hExp);

                            // Tọa độ đường Lợi Nhuận
                            var hProf = ((profitData[b] - pMin) / pRange) * chartH;
                            profitPointsX.push(xCenter);
                            profitPointsY.push(h - paddingBottom - hProf);
                        }

                        // Nhãn mốc thời gian trục X (Hiển thị toàn bộ cả tương lai)
                        ctx.fillStyle = "#334155";
                        ctx.fillText(labels[b], xCenter, h - 10);
                    }

                    // 5. VẼ ĐƯỜNG LỢI NHUẬN (Chỉ vẽ các điểm không phải mốc tương lai)
                    if (profitPointsX.length > 0) {
                        ctx.beginPath();
                        ctx.strokeStyle = "#0284C7";
                        ctx.lineWidth = 2.5;
                        for (var p = 0; p < profitPointsX.length; p++) {
                            if (p === 0) ctx.moveTo(profitPointsX[p], profitPointsY[p]);
                            else ctx.lineTo(profitPointsX[p], profitPointsY[p]);
                        }
                        ctx.stroke();

                        // Vẽ dấu chấm trên đường
                        for (var pt = 0; pt < profitPointsX.length; pt++) {
                            ctx.fillStyle = "#0369A1";
                            ctx.beginPath();
                            ctx.arc(profitPointsX[pt], profitPointsY[pt], 4, 0, 2 * Math.PI);
                            ctx.fill();
                        }
                    }

                    // 6. VẼ CHÚ THÍCH (LEGEND)
                    ctx.font = "12px sans-serif";
                    ctx.textAlign = "left";
                    var lx = paddingLeft + 10;
                    var ly = 10;

                    ctx.fillStyle = "#22C55E";
                    ctx.fillRect(lx, ly, 15, 15);
                    ctx.fillStyle = "#334155";
                    ctx.fillText("Thu", lx + 20, ly + 12);

                    ctx.fillStyle = "#EF4444";
                    ctx.fillRect(lx + 60, ly, 15, 15);
                    ctx.fillStyle = "#334155";
                    ctx.fillText("Chi", lx + 80, ly + 12);

                    ctx.fillStyle = "#0284C7";
                    ctx.beginPath();
                    ctx.arc(lx + 130, ly + 7, 5, 0, 2 * Math.PI);
                    ctx.fill();
                    ctx.fillStyle = "#334155";
                    ctx.fillText("Lợi nhuận ròng", lx + 140, ly + 12);
                }
            }
        }

        // --- BẢNG LỊCH SỬ TÀI CHÍNH ---
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
                        placeholderText: "🔍 Tìm theo ghi chú..."
                        Layout.preferredWidth: 220
                        onTextChanged: Qt.callLater(applyFilters)
                    }

                    ComboBox {
                        id: typeFilterCombo
                        model: ["Tất cả loại", "🟢 Thu", "🔴 Chi"]
                        onCurrentIndexChanged: Qt.callLater(applyFilters)
                    }
                }

                // Tiêu đề Bảng
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

                // Danh sách
                ListView {
                    id: historyListView // <--- THÊM ID CHO LISTVIEW
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: filteredFinanceModel
                    clip: true
                    spacing: 4

                    delegate: Rectangle {
                        // Thay vì dùng parent.width, ta gọi trực tiếp id của ListView
                        width: historyListView.width
                        height: 40
                        color: index % 2 === 0 ? "#FFFFFF" : "#F8FAFC"
                        radius: 4
                        border.color: "#F1F5F9"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 10

                            Text { text: model.date; Layout.preferredWidth: 120; color: "#334155"; font.pixelSize: 13 }

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

                            Text {
                                text: (model.type === "Thu" ? "+" : "-") + formatMoney(model.amount) + " VNĐ"
                                font.bold: true
                                color: model.type === "Thu" ? "#16A34A" : "#DC2626"
                                Layout.preferredWidth: 150
                                font.pixelSize: 13
                            }

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

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.addTransactionCSV) {
                            coffeeSystem.addTransactionCSV(dateStr, inputType.currentText, amt, noteStr);
                            refreshFinance();
                        }

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