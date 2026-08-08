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

    // Dữ liệu dùng cho vẽ biểu đồ
    property var chartLabels: []
    property var chartRev: []
    property var chartExp: []
    property var chartProfit: []
    property var chartIsFuture: []

    // Lưu tọa độ để bắt sự kiện hover
    property var hitBoxes: []

    Component.onCompleted: {
        // Init years model (Chỉ khảo sát 2025 - 2027)
        cbYear.model = ["2025", "2026", "2027"];
        cbYear.currentIndex = 1; // Focus vào năm 2026

        var now = new Date();
        cbMonth.currentIndex = now.getMonth();

        // Tự động chọn tuần hiện tại (Tính từ ngày hiện tại: ngày 1-7 là tuần 1, 8-14 là tuần 2...)
        var currentDay = now.getDate();
        cbWeek.currentIndex = Math.min(Math.floor((currentDay - 1) / 7), 3);

        refreshData();
    }

    // Alias để hàm tự động được main.qml gọi mỗi khi focus vào trang Tài Chính
    function refreshData() {
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

    // Hàm lấy chính xác Date và Time để chuẩn hóa (Fix lỗi số 08, 09 ở hệ Octal)
    function parseDateStrFull(dateStr) {
        if (!dateStr) return new Date(0);
        var cleanStr = dateStr.toString().trim();
        var parts = cleanStr.split(" ");
        var dateOnly = parts[0];
        var timeOnly = parts.length > 1 ? parts[1] : "00:00:00";

        var y = 0, m = 0, d = 0;
        if (dateOnly.indexOf("/") !== -1) {
            var dParts = dateOnly.split("/");
            if (dParts.length >= 3) {
                y = parseInt(dParts[2], 10);
                m = parseInt(dParts[1], 10) - 1;
                d = parseInt(dParts[0], 10);
            }
        } else if (dateOnly.indexOf("-") !== -1) {
            var dParts2 = dateOnly.split("-");
            if (dParts2.length >= 3) {
                y = parseInt(dParts2[0], 10);
                m = parseInt(dParts2[1], 10) - 1;
                d = parseInt(dParts2[2], 10);
            }
        } else {
            return new Date(cleanStr);
        }

        var hh = 0, min = 0, ss = 0;
        var tParts = timeOnly.split(":");
        if (tParts.length > 0) hh = parseInt(tParts[0], 10);
        if (tParts.length > 1) min = parseInt(tParts[1], 10);
        if (tParts.length > 2) ss = parseInt(tParts[2], 10);

        if (isNaN(y) || isNaN(m) || isNaN(d)) return new Date(0);
        if (isNaN(hh)) hh = 0;
        if (isNaN(min)) min = 0;
        if (isNaN(ss)) ss = 0;

        return new Date(y, m, d, hh, min, ss);
    }

    // Hàm chuẩn hóa chuỗi Date xuất ra giao diện
    function normalizeDateString(dateStr) {
        var d = parseDateStrFull(dateStr);
        if (d.getTime() === 0) return dateStr;

        var yy = d.getFullYear();
        var mm = ("0" + (d.getMonth() + 1)).slice(-2);
        var dd = ("0" + d.getDate()).slice(-2);
        var h = ("0" + d.getHours()).slice(-2);
        var min = ("0" + d.getMinutes()).slice(-2);
        var sec = ("0" + d.getSeconds()).slice(-2);
        return yy + "-" + mm + "-" + dd + " " + h + ":" + min + ":" + sec;
    }

    function refreshFinance() {
        rawFinanceModel.clear();
        filteredFinanceModel.clear();

        var tempArr = [];

        // 1. Tải dữ liệu từ finance.csv (Chi phí cố định, giao dịch tay)
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadFinance) {
            var data = coffeeSystem.loadFinance();
            for (var i = 0; i < data.length; i++) {
                tempArr.push({
                    "date": normalizeDateString(data[i].date),
                    "type": data[i].type,
                    "amount": data[i].amount,
                    "note": data[i].note
                });
            }
        }

        // 2. Tải dữ liệu từ OrderHistoryManager (Lịch sử bán hàng tự động)
        if (typeof orderHistoryManager !== "undefined") {
            var orders = orderHistoryManager.getHistory();
            for (var j = 0; j < orders.length; j++) {
                var o = orders[j];
                var dtStr = o.date;
                if (o.time) {
                    dtStr += " " + o.time;
                }

                tempArr.push({
                    "date": normalizeDateString(dtStr),
                    "type": "Thu",
                    "amount": o.totalAmount,
                    "note": "Đơn hàng " + o.invoiceNumber
                });
            }
        }

        // 3. Sắp xếp mảng gộp lại (Giảm dần - Mới nhất lên đầu)
        tempArr.sort(function(a, b) {
            var da = parseDateStrFull(a.date);
            var db = parseDateStrFull(b.date);
            return db.getTime() - da.getTime();
        });

        // 4. Nhồi vào Model
        for (var k = 0; k < tempArr.length; k++) {
            rawFinanceModel.append(tempArr[k]);
        }

        Qt.callLater(applyFilters);
    }

    function applyFilters() {
        var m_mode = cbViewMode.currentIndex;
        if (m_mode < 0) m_mode = 0;

        var m_year = parseInt(cbYear.currentText, 10);
        if (isNaN(m_year)) m_year = new Date().getFullYear();

        var m_month = cbMonth.currentIndex;
        if (m_month < 0) m_month = new Date().getMonth();

        var m_week = cbWeek.currentIndex;
        if (m_week < 0) m_week = 0;

        var m_measure = cbYearMeasure.currentIndex;
        if (m_measure < 0) m_measure = 0;

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
            if (m_measure === 0) {
                numBuckets = 12;
                labels = ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"];
                for (var m = 0; m < 12; m++) {
                    rev.push(0); exp.push(0); profit.push(0);
                    var mStart = new Date(m_year, m, 1);
                    isFuture.push(mStart > today);
                }
            } else {
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

        for (var idx1 = 0; idx1 < rawFinanceModel.count; idx1++) {
            var item = rawFinanceModel.get(idx1);
            var itemDate = parseDateStrFull(item.date);
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
        var filterExactDate = filterDateField.text.trim();
        var typeFilter = typeFilterCombo.currentIndex;
        if (typeFilter < 0) typeFilter = 0;

        for (var idx2 = 0; idx2 < rawFinanceModel.count; idx2++) {
            var fItem = rawFinanceModel.get(idx2);
            var fDate = parseDateStrFull(fItem.date);
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

            // Lọc theo ngày cụ thể (YYYY-MM-DD)
            var fMatchExactDate = (filterExactDate === "" || fItem.date.indexOf(filterExactDate) !== -1);

            if (fMatchPeriod && fMatchType && fMatchSearch && fMatchExactDate) {
                filteredFinanceModel.append(fItem);
            }
        }

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
                Label { text: "Theo dõi doanh thu, chi phí và biểu đồ lợi nhuận"; font.pixelSize: 13; color: "#64748B" }
            }

            Item { Layout.fillWidth: true }

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
                    currentIndex: 0 // Đặt mặc định là Tuần
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
                    Text { text: "🔵 LỢI NHUẬN RÒNG"; font.bold: true; font.pixelSize: 12; color: netProfit >= 0 ? "#075985" : "#9F1239" }
                    Text { text: formatMoney(netProfit) + " VNĐ"; font.pixelSize: 18; font.bold: true; color: netProfit >= 0 ? "#0284C7" : "#E11D48" }
                }
            }
        }

        // --- KHU VỰC BIỂU ĐỒ KẾT HỢP HAI TRỤC ---
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

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    financePage.hitBoxes = []; // Reset hitBoxes mỗi lần vẽ lại

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
                    if (pMin > 0) pMin = 0;
                    if (pMax === pMin) { pMax += 100; pMin -= 100; }

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

                        ctx.beginPath();
                        ctx.moveTo(paddingLeft, yPos);
                        ctx.lineTo(w - paddingRight, yPos);
                        ctx.stroke();

                        var leftVal = gl * maxBar / 4;
                        ctx.textAlign = "right";
                        ctx.fillStyle = "#64748B";
                        ctx.fillText(formatAxisNumber(leftVal), paddingLeft - 8, yPos + 4);

                        var rightVal = pMin + gl * pRange / 4;
                        ctx.textAlign = "left";
                        ctx.fillStyle = "#0284C7";
                        ctx.fillText(formatAxisNumber(rightVal), w - paddingRight + 8, yPos + 4);
                    }

                    ctx.textAlign = "right";
                    ctx.fillStyle = "#64748B";
                    ctx.fillText("(VNĐ)", paddingLeft, paddingTop - 15);

                    ctx.textAlign = "left";
                    ctx.fillStyle = "#0284C7";
                    ctx.fillText("(VNĐ)", w - paddingRight, paddingTop - 15);

                    // 4. VẼ BIỂU ĐỒ CỘT THU/CHI VÀ LƯU TỌA ĐỘ HITBOX
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
                            var rx = xCenter - barW - 1;
                            var ry = h - paddingBottom - hRev;
                            ctx.fillStyle = "#22C55E";
                            ctx.fillRect(rx, ry, barW, hRev);
                            financePage.hitBoxes.push({type: 'bar', name: 'Thu', label: labels[b], val: revData[b], x: rx, y: ry, w: barW, h: hRev});

                            // Cột Chi
                            var hExp = (expData[b] / maxBar) * chartH;
                            var ex = xCenter + 1;
                            var ey = h - paddingBottom - hExp;
                            ctx.fillStyle = "#EF4444";
                            ctx.fillRect(ex, ey, barW, hExp);
                            financePage.hitBoxes.push({type: 'bar', name: 'Chi', label: labels[b], val: expData[b], x: ex, y: ey, w: barW, h: hExp});

                            // Tính tọa độ đường Lợi Nhuận
                            var hProf = ((profitData[b] - pMin) / pRange) * chartH;
                            profitPointsX.push(xCenter);
                            profitPointsY.push(h - paddingBottom - hProf);
                            financePage.hitBoxes.push({type: 'node', name: 'Lợi nhuận ròng', label: labels[b], val: profitData[b], x: xCenter, y: h - paddingBottom - hProf});
                        }

                        ctx.fillStyle = "#334155";
                        ctx.fillText(labels[b], xCenter, h - 10);
                    }

                    // 5. VẼ ĐƯỜNG LỢI NHUẬN
                    if (profitPointsX.length > 0) {
                        ctx.beginPath();
                        ctx.strokeStyle = "#0284C7";
                        ctx.lineWidth = 2.5;
                        for (var p = 0; p < profitPointsX.length; p++) {
                            if (p === 0) ctx.moveTo(profitPointsX[p], profitPointsY[p]);
                            else ctx.lineTo(profitPointsX[p], profitPointsY[p]);
                        }
                        ctx.stroke();

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

                // XỬ LÝ SỰ KIỆN HOVER QUA BIỂU ĐỒ
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPositionChanged: (mouse) => {
                        var mx = mouse.x;
                        var my = mouse.y;
                        var found = null;

                        for (var i = 0; i < financePage.hitBoxes.length; i++) {
                            var b = financePage.hitBoxes[i];
                            if (b.type === "node") {
                                var dx = mx - b.x;
                                var dy = my - b.y;
                                if (dx * dx + dy * dy <= 36) { // Bán kính bắt dính = 6
                                    found = b;
                                    break;
                                }
                            } else if (b.type === "bar") {
                                if (mx >= b.x && mx <= b.x + b.w && my >= b.y && my <= b.y + b.h) {
                                    found = b;
                                    break;
                                }
                            }
                        }

                        if (found) {
                            var sign = found.val > 0 ? "+" : "";
                            var colorCode = found.name === "Thu" ? "#16A34A" : (found.name === "Chi" ? "#DC2626" : "#0284C7");

                            chartToolTipText.text = "<b>" + found.label + " - " + found.name + "</b><br>"
                                                  + "<font color='" + colorCode + "'>" + sign + formatMoney(found.val) + " VNĐ</font>";

                            // Tránh tooltip bị tràn ra ngoài cạnh phải/dưới của Canvas
                            var tipX = mx + 15;
                            var tipY = my - 15;
                            if (tipX + chartToolTipRect.width > chartCanvas.width) tipX = mx - chartToolTipRect.width - 15;

                            chartToolTipRect.x = tipX;
                            chartToolTipRect.y = tipY;
                            chartToolTipRect.visible = true;
                        } else {
                            chartToolTipRect.visible = false;
                        }
                    }
                    onExited: chartToolTipRect.visible = false
                }

                // TOOLTIP KHUNG NỔI
                Rectangle {
                    id: chartToolTipRect
                    visible: false
                    width: chartToolTipText.implicitWidth + 20
                    height: chartToolTipText.implicitHeight + 16
                    color: "#FFFFFF"
                    radius: 6
                    border.color: "#CBD5E1"
                    border.width: 1
                    z: 99

                    // Bóng đổ nhẹ cho Tooltip
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        color: "transparent"
                        border.color: "#000000"
                        opacity: 0.1
                        radius: 6
                        z: -1
                    }

                    Text {
                        id: chartToolTipText
                        anchors.centerIn: parent
                        textFormat: Text.RichText
                        font.pixelSize: 12
                        color: "#334155"
                        horizontalAlignment: Text.AlignLeft
                    }
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
                        id: filterDateField
                        placeholderText: "📅 Ngày (VD: 2026-07-26)"
                        Layout.preferredWidth: 160
                        onTextChanged: Qt.callLater(applyFilters)
                    }

                    TextField {
                        id: searchInput
                        placeholderText: "🔍 Tìm theo ghi chú..."
                        Layout.preferredWidth: 200
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

                        Text { text: "THỜI GIAN"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 160 }
                        Text { text: "LOẠI"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 90 }
                        Text { text: "SỐ TIỀN"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.preferredWidth: 150 }
                        Text { text: "GHI CHÚ / DIỄN GIẢI"; font.bold: true; font.pixelSize: 12; color: "#64748B"; Layout.fillWidth: true }
                    }
                }

                // Danh sách
                ListView {
                    id: historyListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: filteredFinanceModel
                    clip: true
                    spacing: 4

                    delegate: Rectangle {
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

                            Text { text: model.date; Layout.preferredWidth: 160; color: "#334155"; font.pixelSize: 13 }

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
        width: 380; height: 320
        anchors.centerIn: parent
        modal: true

        // Reset dữ liệu mỗi khi mở popup
        onOpened: {
            inputAmount.text = "";
            inputNote.text = "";
            errorMsg.visible = false;
            inputType.currentIndex = 0;
        }

        ColumnLayout {
            anchors.fill: parent; spacing: 12

            ComboBox {
                id: inputType
                Layout.fillWidth: true
                model: ["Thu", "Chi"]
            }

            TextField {
                id: inputAmount
                placeholderText: "Số tiền (VD: 150000)"
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly // Gợi ý bàn phím số trên thiết bị di động

                onTextChanged: errorMsg.visible = false // Ẩn lỗi khi người dùng bắt đầu sửa lại
            }

            TextField {
                id: inputNote
                placeholderText: "Ghi chú giao dịch"
                Layout.fillWidth: true
            }

            Text {
                id: errorMsg
                text: "⚠️ Số tiền không hợp lệ!\n(Phải > 0, không có số 0 ở đầu, chỉ chứa chữ số)"
                color: "#DC2626"
                font.pixelSize: 12
                font.italic: true
                visible: false
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Hủy"
                    Layout.fillWidth: true
                    onClicked: addTransactionDialog.close()
                }
                Button {
                    text: "Tiếp tục"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#0284C7"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        var rawAmount = inputAmount.text.trim();

                        // Kiểm tra định dạng số tiền bằng Regex (không số 0 ở đầu, chỉ chứa số)
                        var isValid = /^[1-9][0-9]*$/.test(rawAmount);

                        if (!isValid) {
                            errorMsg.visible = true;
                            return;
                        }

                        // Nếu hợp lệ, mở popup xác nhận
                        errorMsg.visible = false;
                        confirmAddDialog.open();
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // POPUP XÁC NHẬN LƯU GIAO DỊCH
    // -------------------------------------------------------------------------
    Dialog {
        id: confirmAddDialog
        width: 350
        height: 200
        modal: true
        anchors.centerIn: parent
        title: "Xác nhận"

        background: Rectangle { color: "#FFFFFF"; radius: 12; border.color: "#E2E8F0" }
        header: Item { height: 40; Text { text: "Xác nhận tạo giao dịch"; font.bold: true; font.pixelSize: 16; color: "#1E293B"; anchors.centerIn: parent } }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 15

            Text {
                text: "Bạn có chắc chắn muốn lưu giao dịch này?\nThời gian sẽ được ghi nhận ngay lúc này."
                font.pixelSize: 14
                color: "#475569"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 15
                Button {
                    text: "Quay lại"
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { color: "#F1F5F9"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "#1E293B"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: confirmAddDialog.close()
                }
                Button {
                    text: "Lưu ngay"
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { color: "#16A34A"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        var amt = parseFloat(inputAmount.text.trim());
                        var noteStr = inputNote.text.trim();

                        // Lấy chính xác thời gian ngay lúc bấm nút Lưu ngay (HH cho giờ 24h)
                        var exactCurrentTime = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.addTransactionCSV) {
                            coffeeSystem.addTransactionCSV(exactCurrentTime, inputType.currentText, amt, noteStr);
                            refreshFinance();
                        }

                        confirmAddDialog.close();
                        addTransactionDialog.close();
                    }
                }
            }
        }
    }
}