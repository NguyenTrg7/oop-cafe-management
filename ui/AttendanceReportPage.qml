import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: attendancePage
    title: "Báo Cáo Điểm Danh"
    background: Rectangle { color: "#F8FAFC" }

    property var rawAttendance: []

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

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("AttendanceReportPage.qml", "Báo Cáo Điểm Danh")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("AttendanceReportPage.qml", "Báo Cáo Điểm Danh")
            if (win.pageTitle !== undefined) win.pageTitle = "Báo Cáo Điểm Danh"
        }
    }

    StackView.onActivating: syncNavBar()

    ListModel { id: attendanceModel }

    Component.onCompleted: {
        syncNavBar()
        loadAttendanceData()
    }

    function timeToMins(timeStr) {
        if (!timeStr) return 0;
        var p = timeStr.split(":");
        return parseInt(p[0]) * 60 + parseInt(p[1]);
    }

    function loadAttendanceData() {
        rawAttendance = [];
        if (typeof coffeeSystem !== "undefined") {
            var employees = []
            if (coffeeSystem.loadEmployees) {
                employees = coffeeSystem.loadEmployees()
            }

            var getEmployeeName = function(identifier) {
                for (var j = 0; j < employees.length; j++) {
                    if (employees[j].id === identifier || employees[j].phone === identifier) {
                        return employees[j].name
                    }
                }
                return "Không xác định"
            }

            if (coffeeSystem.loadAttendance) {
                var data = coffeeSystem.loadAttendance()
                for (var i = 0; i < data.length; i++) {
                    var record = data[i]
                    record.employeeName = getEmployeeName(record.identifier)
                    rawAttendance.push(record)
                }
            }
        }
        applyFilters();
    }

    function applyFilters() {
        attendanceModel.clear();

        var selDay = cbDay.currentIndex > 0 ? parseInt(cbDay.currentText) : -1;
        var selMonth = cbMonth.currentIndex > 0 ? parseInt(cbMonth.currentText) : -1;
        var selYear = cbYear.currentIndex > 0 ? parseInt(cbYear.currentText) : -1;
        var startMins = cbStartTime.currentIndex > 0 ? timeToMins(cbStartTime.currentText) : -1;
        var endMins = cbEndTime.currentIndex > 0 ? timeToMins(cbEndTime.currentText) : -1;

        for (var i = 0; i < rawAttendance.length; i++) {
            var record = rawAttendance[i];

            var parts = record.timestamp.split(" ");
            if (parts.length < 2) continue;

            var tTime = parts[0];
            var tDate = parts[1];

            var dParts = tDate.split("/");
            var dDay = parseInt(dParts[0]);
            var dMonth = parseInt(dParts[1]);
            var dYear = parseInt(dParts[2]);

            var itemMins = timeToMins(tTime);

            if (selDay !== -1 && dDay !== selDay) continue;
            if (selMonth !== -1 && dMonth !== selMonth) continue;
            if (selYear !== -1 && dYear !== selYear) continue;
            if (startMins !== -1 && itemMins < startMins) continue;
            if (endMins !== -1 && itemMins > endMins) continue;

            attendanceModel.append(record);
        }
    }

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
                text: "📋 LỊCH SỬ ĐIỂM DANH"
                font.bold: true
                font.pixelSize: 20
                color: "#0369A1"
                Layout.fillWidth: true
            }

            Button {
                text: "🔄 Làm mới"
                onClicked: loadAttendanceData()
            }
        }

        // Bộ lọc thời gian
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
            id: attendanceListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: attendanceModel
            clip: true
            spacing: 4

            delegate: Rectangle {
                width: attendanceListView.width
                height: 60
                color: index % 2 === 0 ? "#F1F5F9" : "#FFFFFF"
                border.color: "#E2E8F0"
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    ColumnLayout {
                        Layout.preferredWidth: 200
                        spacing: 2
                        Text { text: model.employeeName; font.bold: true; font.pixelSize: 15; color: "#1E293B" }
                        Text { text: "Mã/SĐT: " + model.identifier; font.pixelSize: 13; color: "#64748B" }
                    }
                    Text {
                        text: model.type === "CHECK_IN" ? "🟢 Check-in" : "🔴 Check-out"
                        Layout.preferredWidth: 150
                        font.bold: true
                        color: model.type === "CHECK_IN" ? "#16A34A" : "#DC2626"
                    }
                    Text {
                        text: "Thời gian: " + model.timestamp
                        Layout.fillWidth: true
                        color: "#475569"
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: attendanceListView.count === 0
                text: "Không có dữ liệu điểm danh khớp với tìm kiếm"
                font.pixelSize: 16
                color: "#94A3B8"
            }
        }
    }
}