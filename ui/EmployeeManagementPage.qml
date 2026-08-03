import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1 as Platform

Page {
    id: empPage
    title: "Lịch Phân Ca & Quản Lý Nhân Sự"
    background: Rectangle { color: "#F8FAFC" }

    property var currentDate: new Date()
    property string selectedDateStr: Qt.formatDateTime(currentDate, "dd/MM/yyyy")

    ListModel { id: calendarModel }
    ListModel { id: shiftModel }
    ListModel { id: allEmployeesModel }

    Component.onCompleted: {
        generateCalendar(currentDate.getMonth(), currentDate.getFullYear())
        refreshData()
    }

    function generateCalendar(month, year) {
        calendarModel.clear()
        var firstDay = new Date(year, month, 1)
        var lastDay = new Date(year, month + 1, 0)
        var startOffset = (firstDay.getDay() === 0 ? 6 : firstDay.getDay() - 1)

        for (var i = 0; i < startOffset; i++) {
            calendarModel.append({ "dayNumber": "", "dateStr": "", "isCurrentMonth": false })
        }

        for (var d = 1; d <= lastDay.getDate(); d++) {
            var tempDate = new Date(year, month, d)
            var dStr = Qt.formatDateTime(tempDate, "dd/MM/yyyy")
            calendarModel.append({ "dayNumber": d.toString(), "dateStr": dStr, "isCurrentMonth": true })
        }
    }

    function changeMonth(offset) {
        var tempDate = new Date(currentDate.getTime())
        tempDate.setMonth(tempDate.getMonth() + offset)
        currentDate = tempDate
        generateCalendar(currentDate.getMonth(), currentDate.getFullYear())
        refreshData()
    }

    function refreshData() {
        // CÁCH SỬA LỖI ĐƠ UI: Tạm thời ngắt model khỏi ComboBox để UI không phải re-render liên tục
        if (typeof cbEmployee !== "undefined" && cbEmployee !== null) {
            cbEmployee.model = null
        }

        allEmployeesModel.clear()

        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
            var data = coffeeSystem.loadEmployees()
            if (data) {
                for (var i = 0; i < data.length; i++) {
                    allEmployeesModel.append({
                        "text": data[i].id + " - " + data[i].name,
                        "empId": data[i].id,
                        "empName": data[i].name,
                        "empPhone": data[i].phone,
                        "empSalary": data[i].salary
                    })
                }
            }
        }

        // Gắn model lại sau khi đã nạp xong dữ liệu
        if (typeof cbEmployee !== "undefined" && cbEmployee !== null) {
            cbEmployee.model = allEmployeesModel
            cbEmployee.currentIndex = -1
        }

        refreshShifts()
    }

    function refreshShifts() {
        shiftModel.clear()
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadShifts) {
            var shifts = coffeeSystem.loadShifts(selectedDateStr)
            if (shifts) {
                for (var i = 0; i < shifts.length; i++) {
                    shiftModel.append(shifts[i])
                }
            }
        }
    }

    function validatePhone(phone) {
        var phoneRegex = /^0\d{9}$/;
        return phoneRegex.test(phone.trim());
    }

    function checkDuplicate(id, phone, ignoreId) {
        for (var i = 0; i < allEmployeesModel.count; i++) {
            var emp = allEmployeesModel.get(i);
            if (emp.empId !== ignoreId) {
                if (emp.empId === id) return "Mã nhân viên (ID) đã tồn tại!";
                if (emp.empPhone === phone) return "Số điện thoại đã tồn tại!";
            }
        }
        return "";
    }

    function getShiftColor(timeStr) {
        if (!timeStr) return { bg: "#ECFDF5", border: "#6EE7B7", text: "#047857" };
        var hour = parseInt(timeStr.split(":")[0]);
        if (hour < 12) {
            return { bg: "#ECFDF5", border: "#6EE7B7", text: "#047857" };
        } else if (hour < 17) {
            return { bg: "#FFFBEB", border: "#FDE047", text: "#B45309" };
        } else {
            return { bg: "#EFF6FF", border: "#93C5FD", text: "#1D4ED8" };
        }
    }

    Dialog {
        id: monthYearDialog
        title: "Chọn Tháng & Năm"
        width: 320; height: 280
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20
            Tumbler {
                id: monthTumbler
                Layout.fillWidth: true
                model: 12
                visibleItemCount: 5
                delegate: Text {
                    text: "Tháng " + (modelData + 1)
                    font.pixelSize: Tumbler.displacement === 0 ? 22 : 16
                    font.bold: Tumbler.displacement === 0
                    color: Tumbler.displacement === 0 ? "#0F766E" : "#94A3B8"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                }
            }
            Tumbler {
                id: yearTumbler
                Layout.fillWidth: true
                model: 100
                visibleItemCount: 5
                delegate: Text {
                    text: (2000 + modelData).toString()
                    font.pixelSize: Tumbler.displacement === 0 ? 22 : 16
                    font.bold: Tumbler.displacement === 0
                    color: Tumbler.displacement === 0 ? "#0F766E" : "#94A3B8"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                }
            }
        }
        onAboutToShow: {
            monthTumbler.currentIndex = currentDate.getMonth()
            yearTumbler.currentIndex = currentDate.getFullYear() - 2000
        }
        onAccepted: {
            var temp = new Date(yearTumbler.currentIndex + 2000, monthTumbler.currentIndex, 1)
            currentDate = temp
            generateCalendar(currentDate.getMonth(), currentDate.getFullYear())
            refreshData()
        }
    }

    Platform.FileDialog {
        id: importCsvDialog
        title: "Chọn file CSV"
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            if (typeof coffeeSystem !== "undefined" && coffeeSystem.importEmployeesNoDuplicate) {
                var filePath = importCsvDialog.fileUrl ? importCsvDialog.fileUrl : importCsvDialog.file;
                coffeeSystem.importEmployeesNoDuplicate(filePath)
                refreshData()
            }
        }
    }

    Platform.FileDialog {
        id: exportCsvDialog
        title: "Lưu file CSV nhân viên"
        fileMode: Platform.FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            if (typeof coffeeSystem !== "undefined" && coffeeSystem.exportEmployeesCSV) {
                var filePath = exportCsvDialog.fileUrl ? exportCsvDialog.fileUrl : exportCsvDialog.file;
                coffeeSystem.exportEmployeesCSV(filePath)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            background: Rectangle { color: "#E2E8F0"; radius: 8 }

            TabButton {
                text: "📅 Quản Lý Lịch & Ca Làm"; font.bold: true; font.pixelSize: 15
                background: Rectangle { color: tabBar.currentIndex === 0 ? "#FFFFFF" : "transparent"; radius: 8; anchors.margins: 4 }
            }
            TabButton {
                text: "📁 Hồ Sơ Nhân Viên"; font.bold: true; font.pixelSize: 15
                background: Rectangle { color: tabBar.currentIndex === 1 ? "#FFFFFF" : "transparent"; radius: 8; anchors.margins: 4 }
            }
        }

        StackLayout {
            currentIndex: tabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            // TAB 1: LỊCH VÀ QUẢN LÝ CA
            RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 20
                Rectangle {
                    Layout.preferredWidth: 380; Layout.fillHeight: true
                    color: "#FFFFFF"; radius: 12; border.color: "#E2E8F0"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 15; spacing: 15
                        RowLayout {
                            Layout.fillWidth: true
                            Button { text: "◀"; onClicked: changeMonth(-1); background: Rectangle { color: "transparent" } }
                            Button {
                                Layout.fillWidth: true
                                background: Rectangle { color: parent.hovered ? "#F1F5F9" : "transparent"; radius: 5 }
                                contentItem: Text { text: "Tháng " + Qt.formatDateTime(currentDate, "MM - yyyy"); font.bold: true; font.pixelSize: 18; color: "#0F766E"; horizontalAlignment: Text.AlignHCenter }
                                onClicked: monthYearDialog.open()
                            }
                            Button { text: "▶"; onClicked: changeMonth(1); background: Rectangle { color: "transparent" } }
                        }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            Repeater {
                                model: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
                                Text { text: modelData; font.bold: true; color: "#64748B"; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                            }
                        }
                        GridLayout {
                            columns: 7; Layout.fillWidth: true; rowSpacing: 5; columnSpacing: 5
                            Repeater {
                                model: calendarModel
                                Button {
                                    Layout.fillWidth: true; Layout.preferredHeight: 45
                                    text: model.dayNumber; visible: model.isCurrentMonth
                                    background: Rectangle {
                                        color: (model.dateStr === selectedDateStr) ? "#0D9488" : (parent.hovered ? "#CCFBF1" : "#F8FAFC")
                                        radius: 8; border.color: (model.dateStr === selectedDateStr) ? "#0F766E" : "#E2E8F0"
                                    }
                                    contentItem: Text {
                                        text: parent.text; font.bold: model.dateStr === selectedDateStr
                                        color: (model.dateStr === selectedDateStr) ? "#FFFFFF" : "#1E293B"
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: { selectedDateStr = model.dateStr; refreshShifts() }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Button {
                            Layout.fillWidth: true; Layout.preferredHeight: 48
                            background: Rectangle { color: parent.pressed ? "#F1F5F9" : "#FFFFFF"; radius: 8; border.color: "#94A3B8" }
                            contentItem: RowLayout {
                                Item { Layout.fillWidth: true }
                                Text { text: "📝 Tạo Hồ Sơ NV Mới"; font.bold: true; font.pixelSize: 15; color: "#334155" }
                                Item { Layout.fillWidth: true }
                            }
                            onClicked: { newEmpError.text = ""; newEmpDialog.open() }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    color: "#FFFFFF"; radius: 12; border.color: "#E2E8F0"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 20; spacing: 15
                        Text { text: "☕ Ca làm việc: " + selectedDateStr; font.bold: true; font.pixelSize: 22; color: "#0F766E" }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#E2E8F0" }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 10
                            ComboBox {
                                id: cbEmployee
                                Layout.preferredWidth: 200; textRole: "text"; font.pixelSize: 14
                                displayText: currentIndex === -1 ? "--- Chọn nhân sự ---" : currentText
                            }
                            TextField {
                                id: txtShiftTime
                                placeholderText: "VD: 08:00-12:00"
                                Layout.preferredWidth: 140; Layout.preferredHeight: 40; verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle { radius: 6; border.color: "#CBD5E1"; color: "#F8FAFC" }
                                leftPadding: 10
                            }
                            Text { text: "Lặp lại (tháng):" }
                            SpinBox { id: repeatMonths; from: 0; to: 12; value: 0; editable: true; Layout.preferredWidth: 100 }
                            Button {
                                text: "➕ Phân ca"; highlighted: true; font.bold: true
                                onClicked: {
                                    if (cbEmployee.currentIndex >= 0 && txtShiftTime.text.trim() !== "") {
                                        var emp = allEmployeesModel.get(cbEmployee.currentIndex)
                                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.addShift) {
                                            coffeeSystem.addShift(emp.empId, emp.empName, emp.empPhone, selectedDateStr, txtShiftTime.text.trim(), repeatMonths.value)
                                            refreshShifts(); txtShiftTime.text = ""; repeatMonths.value = 0
                                        }
                                    }
                                }
                            }
                        }
                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: shiftModel; clip: true; spacing: 12; Layout.topMargin: 10
                            delegate: Rectangle {
                                width: ListView.view.width; height: 70
                                color: "#F8FAFC"; radius: 10; border.color: "#CBD5E1"
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 12; spacing: 15
                                    Rectangle { width: 46; height: 46; radius: 23; color: "#E2E8F0"; border.color: "#CBD5E1"; Text { text: "👔"; anchors.centerIn: parent; font.pixelSize: 22 } }
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 4
                                        Text { text: model.id + " - " + model.name; font.bold: true; font.pixelSize: 16; color: "#1E293B" }
                                        Text { text: "📞 " + model.phone; font.pixelSize: 13; color: "#64748B" }
                                    }
                                    Rectangle {
                                        property var shiftColors: getShiftColor(model.shiftTime)
                                        Layout.preferredWidth: 140; Layout.preferredHeight: 34
                                        radius: 17; color: shiftColors.bg; border.color: shiftColors.border; border.width: 1
                                        Text { text: "🕒 " + model.shiftTime; anchors.centerIn: parent; font.bold: true; color: shiftColors.text; font.pixelSize: 14 }
                                    }
                                    Button {
                                        background: Rectangle { color: parent.pressed ? "#FEE2E2" : "#FFF1F2"; radius: 8; border.color: "#FDA4AF" }
                                        implicitHeight: 36; implicitWidth: 80
                                        contentItem: Text { text: "❌ Xóa"; color: "#BE123C"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: {
                                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.removeShift) {
                                                coffeeSystem.removeShift(model.id, selectedDateStr, model.shiftTime)
                                                refreshShifts()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // TAB 2: HỒ SƠ NHÂN VIÊN
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#FFFFFF"; radius: 12; border.color: "#E2E8F0"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 15
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "📋 Danh Sách Hồ Sơ Nhân Viên"; font.bold: true; font.pixelSize: 22; color: "#0F766E"; Layout.fillWidth: true }
                        Button {
                            text: "📥 Import CSV"; font.bold: true; palette.buttonText: "#0369A1"
                            background: Rectangle { color: parent.pressed ? "#E0F2FE" : "#F0F9FF"; radius: 8; border.color: "#7DD3FC" }
                            onClicked: importCsvDialog.open()
                        }
                        Button {
                            text: "📤 Export CSV"; font.bold: true; palette.buttonText: "#047857"
                            background: Rectangle { color: parent.pressed ? "#D1FAE5" : "#ECFDF5"; radius: 8; border.color: "#6EE7B7" }
                            onClicked: exportCsvDialog.open()
                        }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#E2E8F0" }
                    GridView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: allEmployeesModel; cellWidth: 320; cellHeight: 120; clip: true
                        delegate: Rectangle {
                            width: 300; height: 100
                            color: mouseArea.containsMouse ? "#F1F5F9" : "#F8FAFC"
                            radius: 10; border.color: mouseArea.containsMouse ? "#94A3B8" : "#CBD5E1"

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    editEmpError.text = "";
                                    editId.text = model.empId;
                                    editId.readOnly = true;
                                    editName.text = model.empName;
                                    editPhone.text = model.empPhone;
                                    editSalary.text = model.empSalary.toString();
                                    editEmpDialog.open();
                                }
                            }

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 15
                                Rectangle { width: 50; height: 50; radius: 25; color: "#E2E8F0"; Text { text: "👤"; anchors.centerIn: parent; font.pixelSize: 24 } }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 4
                                    Text { text: model.empName; font.bold: true; font.pixelSize: 16; color: "#1E293B" }
                                    Text { text: "ID: " + model.empId; font.pixelSize: 13; color: "#64748B" }
                                    Text { text: "📞 " + model.empPhone; font.pixelSize: 13; color: "#64748B" }
                                    Text { text: "💰 Lương: " + model.empSalary + "đ/h"; font.pixelSize: 13; color: "#059669"; font.bold: true }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // DIALOG TẠO NHÂN VIÊN MỚI
    Dialog {
        id: newEmpDialog
        width: 440; modal: true; anchors.centerIn: parent
        background: Rectangle { color: "#FFFFFF"; radius: 16; border.color: "#CBD5E1"; border.width: 1 }
        contentItem: ColumnLayout {
            spacing: 15; anchors.margins: 15
            RowLayout {
                Layout.fillWidth: true
                Text { text: "✨"; font.pixelSize: 22 }
                Text { text: "Hồ Sơ Nhân Sự Mới"; font.pixelSize: 18; font.bold: true; color: "#0F766E"; Layout.fillWidth: true }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#E2E8F0"; Layout.bottomMargin: 5 }
            TextField { id: newId; placeholderText: "Mã NV (VD: NV01)"; Layout.fillWidth: true; font.pixelSize: 14; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: newId.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: newId.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            TextField { id: newName; placeholderText: "Họ và tên nhân viên"; Layout.fillWidth: true; font.pixelSize: 14; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: newName.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: newName.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            TextField { id: newPhone; placeholderText: "Số điện thoại"; Layout.fillWidth: true; font.pixelSize: 14; inputMethodHints: Qt.ImhDialableCharactersOnly; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: newPhone.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: newPhone.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            TextField { id: newSalary; placeholderText: "Mức lương/giờ (VNĐ)"; Layout.fillWidth: true; font.pixelSize: 14; inputMethodHints: Qt.ImhDigitsOnly; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: newSalary.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: newSalary.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            Text { id: newEmpError; color: "#E11D48"; visible: text !== ""; font.pixelSize: 13; font.italic: true; Layout.alignment: Qt.AlignHCenter }
            RowLayout {
                Layout.fillWidth: true; spacing: 15; Layout.topMargin: 10
                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 48
                    background: Rectangle { color: parent.pressed ? "#E2E8F0" : "#F1F5F9"; radius: 8 }
                    contentItem: Text { text: "Hủy bỏ"; color: "#475569"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: { newEmpError.text = ""; newEmpDialog.close() }
                }
                Button {
                    id: btnSaveForm; Layout.fillWidth: true; Layout.preferredHeight: 48
                    property bool isValidForm: newId.text.trim() !== "" && newName.text.trim() !== "" && newPhone.text.trim() !== "" && newSalary.text.trim() !== ""
                    enabled: isValidForm
                    background: Rectangle { color: parent.enabled ? (parent.pressed ? "#0D9488" : "#0F766E") : "#CBD5E1"; radius: 8 }
                    contentItem: Text { text: "💾 Lưu hồ sơ"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (!validatePhone(newPhone.text)) { newEmpError.text = "⚠️ Số điện thoại không hợp lệ!"; return; }
                        var dupError = checkDuplicate(newId.text.trim(), newPhone.text.trim(), "");
                        if (dupError !== "") { newEmpError.text = "⚠️ " + dupError; return; }
                        var salaryVal = parseFloat(newSalary.text) || 0;
                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.addEmployeeCSV) {
                            if (coffeeSystem.addEmployeeCSV(newId.text.trim(), newName.text.trim(), newPhone.text.trim(), salaryVal, "", "")) {
                                newId.text = ""; newName.text = ""; newPhone.text = ""; newSalary.text = "";
                                newEmpError.text = ""; newEmpDialog.close(); refreshData();
                            } else { newEmpError.text = "⚠️ Lỗi: Không thể ghi file. Vui lòng thử lại!"; }
                        }
                    }
                }
            }
        }
    }

    // DIALOG CHỈNH SỬA / XOÁ NHÂN VIÊN
    Dialog {
        id: editEmpDialog
        width: 440; modal: true; anchors.centerIn: parent
        background: Rectangle { color: "#FFFFFF"; radius: 16; border.color: "#CBD5E1"; border.width: 1 }
        contentItem: ColumnLayout {
            spacing: 15; anchors.margins: 15
            RowLayout {
                Layout.fillWidth: true
                Text { text: "✏️"; font.pixelSize: 22 }
                Text { text: "Chỉnh Sửa Hồ Sơ"; font.pixelSize: 18; font.bold: true; color: "#0F766E"; Layout.fillWidth: true }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#E2E8F0"; Layout.bottomMargin: 5 }
            TextField { id: editId; Layout.fillWidth: true; font.pixelSize: 14; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: "#CBD5E1"; border.width: 1; color: "#E2E8F0" } }
            TextField { id: editName; placeholderText: "Họ và tên nhân viên"; Layout.fillWidth: true; font.pixelSize: 14; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: editName.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: editName.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            TextField { id: editPhone; placeholderText: "Số điện thoại"; Layout.fillWidth: true; font.pixelSize: 14; inputMethodHints: Qt.ImhDialableCharactersOnly; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: editPhone.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: editPhone.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            TextField { id: editSalary; placeholderText: "Mức lương/giờ (VNĐ)"; Layout.fillWidth: true; font.pixelSize: 14; inputMethodHints: Qt.ImhDigitsOnly; leftPadding: 12; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { implicitHeight: 45; radius: 8; border.color: editSalary.activeFocus ? "#0F766E" : "#CBD5E1"; border.width: editSalary.activeFocus ? 2 : 1; color: "#F8FAFC" } }
            Text { id: editEmpError; color: "#E11D48"; visible: text !== ""; font.pixelSize: 13; font.italic: true; Layout.alignment: Qt.AlignHCenter }

            RowLayout {
                Layout.fillWidth: true; spacing: 10; Layout.topMargin: 10

                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 48
                    background: Rectangle { color: parent.pressed ? "#FEE2E2" : "#FFF1F2"; radius: 8; border.color: "#FDA4AF" }
                    contentItem: Text { text: "🗑️ Xoá hồ sơ"; color: "#BE123C"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.deleteEmployeeCSV) {
                            coffeeSystem.deleteEmployeeCSV(editId.text.trim());
                            editEmpDialog.close();
                            refreshData();
                        }
                    }
                }
                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 48
                    property bool isValidForm: editName.text.trim() !== "" && editPhone.text.trim() !== "" && editSalary.text.trim() !== ""
                    enabled: isValidForm
                    background: Rectangle { color: parent.enabled ? (parent.pressed ? "#0D9488" : "#0F766E") : "#CBD5E1"; radius: 8 }
                    contentItem: Text { text: "🔄 Cập nhật"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (!validatePhone(editPhone.text)) { editEmpError.text = "⚠️ Số điện thoại không hợp lệ!"; return; }
                        var dupError = checkDuplicate(editId.text.trim(), editPhone.text.trim(), editId.text.trim());
                        if (dupError !== "") { editEmpError.text = "⚠️ " + dupError; return; }

                        var salaryVal = parseFloat(editSalary.text) || 0;
                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.updateEmployeeCSV) {
                            if (coffeeSystem.updateEmployeeCSV(editId.text.trim(), editName.text.trim(), editPhone.text.trim(), salaryVal, "", "")) {
                                editEmpError.text = ""; editEmpDialog.close(); refreshData();
                            } else { editEmpError.text = "⚠️ Lỗi: Không thể cập nhật file!"; }
                        }
                    }
                }
            }
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 40
                background: Rectangle { color: "transparent" }
                contentItem: Text { text: "Đóng"; color: "#64748B"; font.underline: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: editEmpDialog.close()
            }
        }
    }
}