import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1 as Platform

Page {
    id: empPage
    title: "Quản Lý Lịch & Ca Làm"

    function getImageSource() {
        if (typeof savesDir !== "undefined" && savesDir !== "") {
            var base = savesDir.toString().replace(/[\\\/]+$/, "")
            base = base.replace(/[\\\/]saves$/i, "")
            var path = base + "/data/themeManager.png"
            path = path.replace(/\\/g, "/")
            return "file:///" + path
        }
        if (typeof applicationDir !== "undefined" && applicationDir !== "") {
            var p = applicationDir.toString().replace(/\\/g, "/") + "/data/themeManager.png"
            return "file:///" + p
        }
        return ""
    }

    background: Image {
        source: getImageSource()
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
    }

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("EmployeeManagementPage.qml", "Quản Lý Lịch & Ca Làm")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("EmployeeManagementPage.qml", "Quản Lý Lịch & Ca Làm")
            if (win.pageTitle !== undefined) win.pageTitle = "Quản Lý Lịch & Ca Làm"
        }
    }

    StackView.onActivating: {
        syncNavBar()
        refreshData()
    }

    property var currentDate: new Date()
    property string selectedDateStr: Qt.formatDateTime(currentDate, "dd/MM/yyyy")
    property string todayStr: Qt.formatDateTime(new Date(), "dd/MM/yyyy")

    readonly property var fullTimeSuggestions: ["07:00-15:00", "14:00-22:00"]
    readonly property var partTimeSuggestions: ["08:00-12:00", "13:00-17:00", "18:00-22:00"]

    readonly property string selectedEmpRole: {
        if (cbEmployee.currentIndex >= 0 && cbEmployee.currentIndex < allEmployeesModel.count) {
            return allEmployeesModel.get(cbEmployee.currentIndex).empRole || ""
        }
        return ""
    }

    readonly property var activeSuggestions: {
        if (selectedEmpRole.indexOf("Full-time") !== -1 || selectedEmpRole.indexOf("Bảo vệ") !== -1) {
            return fullTimeSuggestions
        }
        return partTimeSuggestions
    }

    ListModel { id: calendarModel }
    ListModel { id: shiftModel }
    ListModel { id: allEmployeesModel }

    Component.onCompleted: {
        syncNavBar()
        generateCalendar(currentDate.getMonth(), currentDate.getFullYear())
        refreshData()
    }

    function generateCalendar(month, year) {
        calendarModel.clear()
        var firstDay = new Date(year, month, 1, 12, 0, 0)
        var lastDay = new Date(year, month + 1, 0, 12, 0, 0)
        var startOffset = (firstDay.getDay() === 0 ? 6 : firstDay.getDay() - 1)

        for (var i = 0; i < startOffset; i++) {
            calendarModel.append({ "dayNumber": "", "dateStr": "", "isCurrentMonth": false })
        }

        for (var d = 1; d <= lastDay.getDate(); d++) {
            var tempDate = new Date(year, month, d, 12, 0, 0)
            var dd = d < 10 ? "0" + d : d.toString()
            var mm = (month + 1) < 10 ? "0" + (month + 1) : (month + 1).toString()
            var dStr = dd + "/" + mm + "/" + year
            calendarModel.append({ "dayNumber": d.toString(), "dateStr": dStr, "isCurrentMonth": true })
        }
    }

    function changeMonth(offset) {
        var tempDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + offset, 1, 12, 0, 0)
        currentDate = tempDate
        generateCalendar(currentDate.getMonth(), currentDate.getFullYear())
        refreshData()
    }

    function refreshData() {
        if (typeof cbEmployee !== "undefined" && cbEmployee !== null) {
            cbEmployee.model = null
        }
        allEmployeesModel.clear()
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
            var data = coffeeSystem.loadEmployees()
            if (data) {
                for (var i = 0; i < data.length; i++) {
                    allEmployeesModel.append({
                        "text": data[i].id + " - " + data[i].name + " (" + (data[i].jobRole ? data[i].jobRole : "Part-time") + ")",
                        "empId": data[i].id,
                        "empName": data[i].name,
                        "empPhone": data[i].phone,
                        "empSalary": data[i].salary,
                        "empGender": data[i].gender ? data[i].gender : "Nam",
                        "empRole": data[i].jobRole ? data[i].jobRole : "Part-time",
                        "empDob": data[i].dob ? data[i].dob : "",
                        "empCccd": data[i].cccd ? data[i].cccd : "",
                        "empShiftDate": data[i].shiftDate ? data[i].shiftDate : "",
                        "empShiftTime": data[i].shiftTime ? data[i].shiftTime : "",
                        "empAvatar": data[i].avatar ? data[i].avatar : "",
                        "empCccdFront": data[i].cccdFront ? data[i].cccdFront : "",
                        "empCccdBack": data[i].cccdBack ? data[i].cccdBack : ""
                    })
                }
            }
        }

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
        return /^0\d{9}$/.test(phone.trim())
    }

    function validateDob(dob) {
        if (!dob || dob.trim() === "") return true
        return /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$/.test(dob.trim())
    }

    function validateCccd(cccd) {
        if (!cccd || cccd.trim() === "") return true
        return /^\d{12}$/.test(cccd.trim())
    }

    function validateShiftTime(timeStr) {
        return /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]-([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/.test(timeStr.trim())
    }

    function checkDuplicate(id, phone, ignoreId) {
        for (var i = 0; i < allEmployeesModel.count; i++) {
            var emp = allEmployeesModel.get(i)
            if (emp.empId !== ignoreId) {
                if (emp.empId === id) return "Mã nhân viên (ID) đã tồn tại!"
                if (emp.empPhone === phone) return "Số điện thoại đã tồn tại!"
            }
        }
        return ""
    }

    function getShiftColor(timeStr) {
        if (!timeStr) return { bg: "#ECFDF5", border: "#6EE7B7", text: "#047857" }
        var hour = parseInt(timeStr.split(":")[0])
        if (hour < 12) {
            return { bg: "#ECFDF5", border: "#6EE7B7", text: "#047857" }
        } else if (hour < 17) {
            return { bg: "#FFFBEB", border: "#FDE047", text: "#B45309" }
        } else {
            return { bg: "#EFF6FF", border: "#93C5FD", text: "#1D4ED8" }
        }
    }

    Platform.FileDialog {
        id: pickAvatarDialog
        title: "Chọn ảnh đại diện"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif)", "All files (*)"]
        onAccepted: { editAvatar.text = pickAvatarDialog.file ? pickAvatarDialog.file : "" }
    }

    Platform.FileDialog {
        id: pickCccdFrontDialog
        title: "Chọn ảnh CCCD mặt trước"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif)", "All files (*)"]
        onAccepted: { editCccdFront.text = pickCccdFrontDialog.file ? pickCccdFrontDialog.file : "" }
    }

    Platform.FileDialog {
        id: pickCccdBackDialog
        title: "Chọn ảnh CCCD mặt sau"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif)", "All files (*)"]
        onAccepted: { editCccdBack.text = pickCccdBackDialog.file ? pickCccdBackDialog.file : "" }
    }

    Platform.FileDialog {
        id: importCsvDialog
        title: "Chọn file CSV"
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            if (typeof coffeeSystem !== "undefined" && coffeeSystem.importEmployeesNoDuplicate) {
                var filePath = importCsvDialog.file ? importCsvDialog.file : ""
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
                var filePath = exportCsvDialog.file ? exportCsvDialog.file : ""
                coffeeSystem.exportEmployeesCSV(filePath)
            }
        }
    }

    Dialog {
        id: imagePreviewDialog
        width: Math.min(empPage.width > 0 ? empPage.width * 0.85 : 700, 700)
        height: Math.min(empPage.height > 0 ? empPage.height * 0.85 : 550, 550)
        modal: true
        padding: 16
        x: Math.max(0, (empPage.width - width) / 2)
        y: Math.max(0, (empPage.height - height) / 2)
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }

        property alias imageSource: fullImg.source

        background: Rectangle {
            color: Qt.rgba(0.06, 0.09, 0.16, 0.95)
            radius: 16
            border.color: "#334155"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 12

            Image {
                id: fullImg
                Layout.fillWidth: true
                Layout.fillHeight: true
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 130
                Layout.preferredHeight: 38

                background: Rectangle {
                    color: parent.pressed ? "#475569" : "#334155"
                    radius: 8
                }

                contentItem: Text {
                    text: "❌ Đóng"
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: imagePreviewDialog.close()
            }
        }
    }

    Dialog {
        id: shiftErrorDialog
        width: Math.min(420, empPage.width > 0 ? empPage.width - 24 : 420)
        modal: true
        padding: 20
        x: Math.max(0, (empPage.width - width) / 2)
        y: Math.max(0, (empPage.height - height) / 2)
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }

        property alias message: lblShiftError.text

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#FECDD3"
            border.width: 2
        }

        contentItem: ColumnLayout {
            spacing: 14

            RowLayout {
                spacing: 12
                Rectangle {
                    width: 38; height: 38; radius: 19
                    color: "#FFE4E6"
                    Text { text: "⚠️"; anchors.centerIn: parent; font.pixelSize: 20 }
                }
                Text {
                    text: "Thông Báo Hệ Thống"
                    font.bold: true
                    font.pixelSize: 17
                    color: "#E11D48"
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#FFE4E6"
            }

            Text {
                id: lblShiftError
                font.pixelSize: 14
                color: "#334155"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                lineHeight: 1.3
            }

            Button {
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 110
                Layout.preferredHeight: 38

                background: Rectangle {
                    color: parent.pressed ? "#BE123C" : "#E11D48"
                    radius: 8
                }

                contentItem: Text {
                    text: "Đã hiểu"
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: shiftErrorDialog.close()
            }
        }
    }

    Dialog {
        id: confirmDeleteDialog
        width: Math.min(400, empPage.width > 0 ? empPage.width - 24 : 400)
        modal: true
        padding: 20
        x: Math.max(0, (empPage.width - width) / 2)
        y: Math.max(0, (empPage.height - height) / 2)
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#CBD5E1"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 14

            RowLayout {
                spacing: 12
                Rectangle {
                    width: 38; height: 38; radius: 19
                    color: "#FEE2E2"
                    Text { text: "🗑️"; anchors.centerIn: parent; font.pixelSize: 18 }
                }
                Text {
                    text: "Xác Nhận Xóa Hồ Sơ"
                    font.bold: true
                    font.pixelSize: 17
                    color: "#BE123C"
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }

            Text {
                text: "Bạn có chắc chắn muốn xóa hồ sơ nhân viên này không?"
                font.pixelSize: 14
                color: "#334155"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                text: editName.text + " (Mã NV: " + editId.text + ")"
                font.bold: true
                font.pixelSize: 15
                color: "#E11D48"
            }

            Text {
                text: "⚠️ Lịch ca làm liên quan cũng sẽ bị xóa khỏi hệ thống."
                font.pixelSize: 12
                font.italic: true
                color: "#64748B"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Layout.topMargin: 5

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: parent.pressed ? "#CBD5E1" : "#F1F5F9"
                        radius: 8
                    }
                    contentItem: Text {
                        text: "Hủy bỏ"
                        color: "#475569"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmDeleteDialog.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: parent.pressed ? "#991B1B" : "#BE123C"
                        radius: 8
                    }
                    contentItem: Text {
                        text: "Xóa vĩnh viễn"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.deleteEmployeeCSV) {
                            coffeeSystem.deleteEmployeeCSV(editId.text.trim())
                            confirmDeleteDialog.close()
                            editEmpDialog.close()
                            refreshData()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: monthYearDialog
        width: Math.min(320, empPage.width > 0 ? empPage.width - 24 : 320)
        height: Math.min(300, empPage.height > 0 ? empPage.height - 40 : 300)
        modal: true
        padding: 16
        x: Math.max(0, (empPage.width - width) / 2)
        y: Math.max(0, (empPage.height - height) / 2)
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#CBD5E1"
        }

        contentItem: ColumnLayout {
            spacing: 10

            Text {
                text: "📅 Chọn Tháng & Năm"
                font.bold: true
                font.pixelSize: 16
                color: "#0F766E"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                Tumbler {
                    id: monthTumbler
                    Layout.fillWidth: true
                    model: 12
                    visibleItemCount: 5

                    delegate: Text {
                        text: "Tháng " + (modelData + 1)
                        font.pixelSize: Tumbler.displacement === 0 ? 18 : 14
                        font.bold: Tumbler.displacement === 0
                        color: Tumbler.displacement === 0 ? "#0F766E" : "#94A3B8"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: (Tumbler.tumbler && Tumbler.tumbler.visibleItemCount > 0) ? (1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)) : 1.0
                    }
                }

                Tumbler {
                    id: yearTumbler
                    Layout.fillWidth: true
                    model: 100
                    visibleItemCount: 5

                    delegate: Text {
                        text: (2000 + modelData).toString()
                        font.pixelSize: Tumbler.displacement === 0 ? 18 : 14
                        font.bold: Tumbler.displacement === 0
                        color: Tumbler.displacement === 0 ? "#0F766E" : "#94A3B8"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: (Tumbler.tumbler && Tumbler.tumbler.visibleItemCount > 0) ? (1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)) : 1.0
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    background: Rectangle { color: "#F1F5F9"; radius: 8 }
                    contentItem: Text { text: "Hủy"; color: "#475569"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: monthYearDialog.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    background: Rectangle { color: "#0F766E"; radius: 8 }
                    contentItem: Text { text: "Đồng ý"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        var temp = new Date(yearTumbler.currentIndex + 2000, monthTumbler.currentIndex, 1, 12, 0, 0)
                        currentDate = temp
                        generateCalendar(currentDate.getMonth(), currentDate.getFullYear())
                        refreshData()
                        monthYearDialog.close()
                    }
                }
            }
        }

        onAboutToShow: {
            monthTumbler.currentIndex = currentDate.getMonth()
            yearTumbler.currentIndex = currentDate.getFullYear() - 2000
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 46

            background: Rectangle {
                color: Qt.rgba(1, 1, 1, 0.7)
                border.color: "#E2E8F0"
                border.width: 1
                radius: 10
            }

            onCurrentIndexChanged: {
                if (typeof appWindow !== "undefined") {
                    appWindow.title = "Giang's Coffee - " + (currentIndex === 0 ? "Quản Lý Lịch && Ca Làm" : "Hồ Sơ Nhân Viên")
                }
            }

            TabButton {
                id: tab1
                text: "📅 Quản Lý Lịch & Ca Làm"
                width: tabBar.width / 2
                implicitHeight: 46

                background: Rectangle {
                    color: tabBar.currentIndex === 0 ? "#FFFFFF" : (tab1.hovered ? "#E2E8F0" : "transparent")
                    radius: 8
                    anchors.margins: 4
                    border.color: tabBar.currentIndex === 0 ? "#CBD5E1" : "transparent"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font.bold: true
                    font.pixelSize: 14
                    color: tabBar.currentIndex === 0 ? "#0F766E" : (tab1.hovered ? "#0F766E" : "#64748B")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            TabButton {
                id: tab2
                text: "📁 Hồ Sơ Nhân Viên"
                width: tabBar.width / 2
                implicitHeight: 46

                background: Rectangle {
                    color: tabBar.currentIndex === 1 ? "#FFFFFF" : (tab2.hovered ? "#E2E8F0" : "transparent")
                    radius: 8
                    anchors.margins: 4
                    border.color: tabBar.currentIndex === 1 ? "#CBD5E1" : "transparent"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font.bold: true
                    font.pixelSize: 14
                    color: tabBar.currentIndex === 1 ? "#0F766E" : (tab2.hovered ? "#0F766E" : "#64748B")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        StackLayout {
            currentIndex: tabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.fillHeight: true
                    color: Qt.rgba(1, 1, 1, 0.5)
                    radius: 12
                    border.color: "#E2E8F0"

                    ScrollView {
                        anchors.fill: parent
                        contentWidth: availableWidth
                        clip: true
                        padding: 14

                        ColumnLayout {
                            width: parent.width - 28
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true

                                Button {
                                    text: "◀"
                                    background: Rectangle { color: "transparent" }
                                    onClicked: changeMonth(-1)
                                }

                                Button {
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: parent.hovered ? "#F1F5F9" : "transparent"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: "Tháng " + Qt.formatDateTime(currentDate, "MM - yyyy")
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: "#0F766E"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    onClicked: monthYearDialog.open()
                                }

                                Button {
                                    text: "▶"
                                    background: Rectangle { color: "transparent" }
                                    onClicked: changeMonth(1)
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Repeater {
                                    model: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
                                    Text {
                                        text: modelData
                                        font.bold: true
                                        font.pixelSize: 11
                                        color: "#475569"
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            GridLayout {
                                columns: 7
                                Layout.fillWidth: true
                                rowSpacing: 5
                                columnSpacing: 5

                                Repeater {
                                    model: calendarModel

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 38
                                        text: model.dayNumber
                                        opacity: model.isCurrentMonth ? 1.0 : 0.0
                                        enabled: model.isCurrentMonth

                                        property bool isSelected: model.dateStr === selectedDateStr
                                        property bool isToday: model.dateStr === todayStr

                                        background: Rectangle {
                                            color: isSelected ? "#0D9488" : (parent.hovered ? "#CCFBF1" : (isToday ? "#F0FDFA" : "#F8FAFC"))
                                            radius: 8
                                            border.color: isSelected ? "#0F766E" : (isToday ? "#0D9488" : "#E2E8F0")
                                            border.width: (isSelected || isToday) ? 2 : 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            font.bold: isSelected || isToday
                                            color: isSelected ? "#FFFFFF" : (isToday ? "#0D9488" : "#1E293B")
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            selectedDateStr = model.dateStr
                                            refreshShifts()
                                        }
                                    }
                                }
                            }

                            Item { Layout.preferredHeight: 6 }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42

                                background: Rectangle {
                                    color: parent.pressed ? "#E2E8F0" : "#F8FAFC"
                                    radius: 8
                                    border.color: "#CBD5E1"
                                }

                                contentItem: Text {
                                    text: "➕ Tạo Hồ Sơ NV Mới"
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: "#0F766E"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    newEmpError.text = ""
                                    newId.text = ""
                                    newName.text = ""
                                    newPhone.text = ""
                                    newSalary.text = ""
                                    newGender.currentIndex = 0
                                    newRole.currentIndex = 0
                                    newEmpDialog.open()
                                    newId.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                // KHU VỰC BẢNG PHÂN CA LÀM
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(1, 1, 1, 0.85)
                    radius: 12
                    border.color: "#E2E8F0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        Text {
                            text: "☕ Ca làm việc: " + selectedDateStr
                            font.bold: true
                            font.pixelSize: 20
                            color: "#0F766E"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#E2E8F0"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            // DÒNG NHẬP LIỆU PHÂN CA
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                ComboBox {
                                    id: cbEmployee
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 120
                                    Layout.preferredHeight: 38
                                    textRole: "text"
                                    font.pixelSize: 13
                                    displayText: currentIndex === -1 ? "--- Chọn nhân sự (*) ---" : currentText

                                    // Ô CHỌN CHÍNH
                                    contentItem: Text {
                                        leftPadding: 8
                                        rightPadding: 24
                                        text: cbEmployee.displayText
                                        font: cbEmployee.font
                                        color: "#1E293B"
                                        verticalAlignment: Text.AlignVCenter
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 8
                                    }

                                    // BẢNG XỔ XUỐNG HIỆN ĐẠI (Tự động cuộn & mở rộng đều 2 bên)
                                    popup: Popup {
                                        id: employeePopup
                                        y: cbEmployee.height + 6

                                        // 1. Rộng ra 2 bên: Căn giữa bảng so với ô chọn chính
                                        width: Math.max(cbEmployee.width + 120, 360)
                                        x: -(width - cbEmployee.width) / 2  // Dịch x sang trái để bảng mở rộng đều sang cả 2 bên

                                        padding: 6

                                        contentItem: ListView {
                                            id: listView
                                            clip: true
                                            implicitHeight: Math.min(contentHeight, 280)
                                            model: cbEmployee.popup.visible ? cbEmployee.delegateModel : null

                                            // 🔴 2. SỬA LỖI ĐỨNG IM: Bắt ListView tự cuộn theo phím mũi tên khi di chuyển
                                            currentIndex: cbEmployee.highlightedIndex

                                            ScrollIndicator.vertical: ScrollIndicator { }
                                        }

                                        background: Rectangle {
                                            color: "#FFFFFF"
                                            border.color: "#CBD5E1"
                                            border.width: 1
                                            radius: 12 // Góc bo tròn hiện đại hơn
                                        }
                                    }

                                    // ITEM TRONG DANH SÁCH
                                    delegate: ItemDelegate {
                                        width: ListView.view ? ListView.view.width : cbEmployee.width
                                        height: 36

                                        background: Rectangle {
                                            color: cbEmployee.highlightedIndex === index ? "#E0F2FE" : "transparent" // Màu hover xanh nhẹ hiện đại
                                            radius: 6
                                        }

                                        contentItem: Text {
                                            text: model.text
                                            font.pixelSize: 13
                                            font.bold: cbEmployee.highlightedIndex === index
                                            color: cbEmployee.highlightedIndex === index ? "#0284C7" : "#1E293B"
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 8
                                            elide: Text.ElideRight
                                        }
                                    }

                                    onCurrentIndexChanged: {
                                        txtShiftTime.text = ""
                                    }
                                }
                                TextField {
                                    id: txtShiftTime
                                    placeholderText: "08:00-12:00 (*)"
                                    Layout.preferredWidth: 135
                                    Layout.preferredHeight: 38
                                    verticalAlignment: TextInput.AlignVCenter
                                    leftPadding: 8
                                    rightPadding: 8
                                    font.pixelSize: 12

                                    background: Rectangle {
                                        radius: 8
                                        border.color: txtShiftTime.activeFocus ? "#0F766E" : "#CBD5E1"
                                        color: "#F8FAFC"
                                    }

                                    onAccepted: repeatMonths.forceActiveFocus()
                                    Keys.onReturnPressed: repeatMonths.forceActiveFocus()
                                    Keys.onEnterPressed: repeatMonths.forceActiveFocus()
                                }

                                Text {
                                    text: "Lặp (tháng):"
                                    font.pixelSize: 12
                                    color: "#1E293B"
                                }

                                SpinBox {
                                    id: repeatMonths
                                    from: 0
                                    to: 12
                                    value: 0
                                    editable: true
                                    Layout.preferredWidth: 85
                                    Layout.preferredHeight: 38

                                    Keys.onReturnPressed: btnAddShift.clicked()
                                    Keys.onEnterPressed: btnAddShift.clicked()
                                }

                                Button {
                                    id: btnAddShift
                                    text: "➕ Phân ca"
                                    highlighted: true
                                    font.bold: true
                                    Layout.preferredHeight: 38
                                    Layout.preferredWidth: 105

                                    onClicked: {
                                        if (cbEmployee.currentIndex < 0) {
                                            shiftErrorDialog.message = "⚠️ Vui lòng chọn nhân sự trước khi phân ca!"
                                            shiftErrorDialog.open()
                                            return
                                        }
                                        if (txtShiftTime.text.trim() === "") {
                                            shiftErrorDialog.message = "⚠️ Vui lòng nhập hoặc chọn khung giờ làm việc!"
                                            shiftErrorDialog.open()
                                            return
                                        }
                                        if (!validateShiftTime(txtShiftTime.text)) {
                                            shiftErrorDialog.message = "⚠️ Giờ làm không đúng định dạng!\n\nVí dụ chuẩn: 08:00-12:00 hoặc 14:00-22:00"
                                            shiftErrorDialog.open()
                                            return
                                        }

                                        var emp = allEmployeesModel.get(cbEmployee.currentIndex)
                                        var role = emp.empRole
                                        var tStr = txtShiftTime.text.trim()

                                        var parts = tStr.split("-")
                                        var startT = parts[0].split(":")
                                        var endT = parts[1].split(":")
                                        var startHour = parseInt(startT[0], 10) + parseInt(startT[1], 10) / 60.0
                                        var endHour = parseInt(endT[0], 10) + parseInt(endT[1], 10) / 60.0

                                        if (endHour <= startHour) {
                                            shiftErrorDialog.message = "⚠️ Giờ kết thúc ca làm phải lớn hơn giờ bắt đầu!"
                                            shiftErrorDialog.open()
                                            return
                                        }

                                        if (startHour < 7 || endHour > 22) {
                                            shiftErrorDialog.message = "⚠️ Khung giờ làm việc phải nằm trong khoảng từ 07:00 đến 22:00!"
                                            shiftErrorDialog.open()
                                            return
                                        }

                                        if (role.indexOf("Full-time") !== -1 || role.indexOf("Bảo vệ") !== -1) {
                                            if (tStr !== "07:00-15:00" && tStr !== "14:00-22:00") {
                                                shiftErrorDialog.message = "⚠️ Nhân viên Full-time/Bảo vệ chỉ được phép phân ca:\n• 07:00-15:00\n• 14:00-22:00"
                                                shiftErrorDialog.open()
                                                return
                                            }
                                        } else {
                                            var duration = endHour - startHour
                                            if (duration < 3 || duration > 5) {
                                                shiftErrorDialog.message = "⚠️ Nhân viên Part-time chỉ được làm ca từ 3 đến 5 tiếng!"
                                                shiftErrorDialog.open()
                                                return
                                            }
                                        }

                                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.addShift) {
                                            if (coffeeSystem.addShift(emp.empId, emp.empName, emp.empPhone, selectedDateStr, tStr, repeatMonths.value)) {
                                                refreshShifts()
                                                txtShiftTime.text = ""
                                                repeatMonths.value = 0
                                            } else {
                                                shiftErrorDialog.message = "⚠️ Đăng ký ca làm không hợp lệ!\n\nLý do có thể do:\n• Ca làm bị trùng/chồng giờ với ca đã có của nhân viên."
                                                shiftErrorDialog.open()
                                            }
                                        }
                                    }
                                }
                            }

                            // DÒNG GỢI Ý
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: selectedEmpRole !== ""
                                          ? "Gợi ý (" + selectedEmpRole + "):"
                                          : "Gợi ý nhanh:"
                                    font.pixelSize: 12
                                    color: "#0F766E"
                                    font.bold: true
                                    Layout.alignment: Qt.AlignTop
                                    Layout.topMargin: 4
                                }

                                Flow {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Repeater {
                                        model: activeSuggestions

                                        Button {
                                            implicitHeight: 26
                                            background: Rectangle {
                                                color: parent.hovered ? "#CCFBF1" : "#F1F5F9"
                                                radius: 13
                                                border.color: parent.hovered ? "#0D9488" : "#99F6E4"
                                                border.width: 1
                                            }
                                            contentItem: Text {
                                                text: modelData
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#0F766E"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                leftPadding: 8
                                                rightPadding: 8
                                            }
                                            onClicked: {
                                                txtShiftTime.text = modelData
                                                repeatMonths.forceActiveFocus()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: shiftModel
                            clip: true
                            spacing: 10
                            Layout.topMargin: 5

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 62
                                color: "#F8FAFC"
                                radius: 10
                                border.color: "#CBD5E1"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

                                    Rectangle {
                                        width: 40; height: 40; radius: 20
                                        color: "#E2E8F0"
                                        Text { text: "👔"; anchors.centerIn: parent; font.pixelSize: 18 }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: model.id + " - " + model.name
                                            font.bold: true
                                            font.pixelSize: 14
                                            color: "#1E293B"
                                        }
                                        Text {
                                            text: "📞 " + model.phone
                                            font.pixelSize: 12
                                            color: "#64748B"
                                        }
                                    }

                                    Rectangle {
                                        property var shiftColors: getShiftColor(model.shiftTime)
                                        Layout.preferredWidth: 130
                                        Layout.preferredHeight: 30
                                        radius: 15
                                        color: shiftColors.bg
                                        border.color: shiftColors.border
                                        border.width: 1
                                        Text {
                                            text: "🕒 " + model.shiftTime
                                            anchors.centerIn: parent
                                            font.bold: true
                                            color: shiftColors.text
                                            font.pixelSize: 12
                                        }
                                    }

                                    Button {
                                        implicitHeight: 32
                                        implicitWidth: 70
                                        background: Rectangle {
                                            color: parent.pressed ? "#FEE2E2" : "#FFF1F2"
                                            radius: 6
                                            border.color: "#FDA4AF"
                                        }
                                        contentItem: Text {
                                            text: "❌ Xóa"
                                            color: "#BE123C"
                                            font.bold: true
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
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

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(1, 1, 1, 0.85)
                radius: 12
                border.color: "#E2E8F0"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "📋 Danh Sách Hồ Sơ Nhân Viên"
                            font.bold: true
                            font.pixelSize: 20
                            color: "#0F766E"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "📥 Import CSV"
                            font.bold: true
                            palette.buttonText: "#0369A1"
                            background: Rectangle {
                                color: parent.pressed ? "#E0F2FE" : "#F0F9FF"
                                radius: 8
                                border.color: "#7DD3FC"
                            }
                            onClicked: importCsvDialog.open()
                        }

                        Button {
                            text: "📤 Export CSV"
                            font.bold: true
                            palette.buttonText: "#047857"
                            background: Rectangle {
                                color: parent.pressed ? "#D1FAE5" : "#ECFDF5"
                                radius: 8
                                border.color: "#6EE7B7"
                            }
                            onClicked: exportCsvDialog.open()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#E2E8F0"
                    }

                    GridView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: allEmployeesModel
                        cellWidth: Math.max(300, (width - 20) / Math.floor(width / 300))
                        cellHeight: 125
                        clip: true

                        delegate: Rectangle {
                            width: GridView.view.cellWidth - 10
                            height: 115
                            color: mouseArea.containsMouse ? "#F1F5F9" : "#F8FAFC"
                            radius: 12
                            border.color: mouseArea.containsMouse ? "#0F766E" : "#CBD5E1"
                            border.width: mouseArea.containsMouse ? 2 : 1

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    editEmpError.text = ""
                                    editId.text = model.empId
                                    editId.readOnly = true
                                    editName.text = model.empName
                                    editPhone.text = model.empPhone
                                    editSalary.text = model.empSalary.toString()
                                    editGender.currentIndex = editGender.find(model.empGender) !== -1 ? editGender.find(model.empGender) : 0
                                    editRole.currentIndex = editRole.find(model.empRole) !== -1 ? editRole.find(model.empRole) : 0
                                    editDob.text = model.empDob || ""
                                    editCccd.text = model.empCccd || ""
                                    editAvatar.text = model.empAvatar || ""
                                    editCccdFront.text = model.empCccdFront || ""
                                    editCccdBack.text = model.empCccdBack || ""
                                    editEmpDialog.open()
                                    editName.forceActiveFocus()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                Rectangle {
                                    width: 52; height: 52; radius: 26
                                    color: "#E2E8F0"
                                    border.color: "#CBD5E1"
                                    clip: true

                                    Image {
                                        id: empAvatarImg
                                        anchors.fill: parent
                                        source: model.empAvatar ? model.empAvatar : ""
                                        fillMode: Image.PreserveAspectCrop
                                        mipmap: true
                                        smooth: true
                                        visible: source.toString() !== ""
                                    }

                                    Text {
                                        text: model.empGender === "Nữ" ? "👩" : "👤"
                                        anchors.centerIn: parent
                                        font.pixelSize: 24
                                        visible: !empAvatarImg.visible
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        text: model.empName
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#1E293B"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "ID: " + model.empId + " • " + model.empGender
                                        font.pixelSize: 12
                                        color: "#64748B"
                                    }

                                    RowLayout {
                                        spacing: 6
                                        Rectangle {
                                            color: "#EEF2FF"; radius: 4
                                            implicitWidth: roleTxt.implicitWidth + 8; implicitHeight: 20
                                            Text { id: roleTxt; text: model.empRole; font.pixelSize: 10; color: "#4F46E5"; font.bold: true; anchors.centerIn: parent }
                                        }
                                        Rectangle {
                                            color: "#ECFDF5"; radius: 4
                                            implicitWidth: salTxt.implicitWidth + 8; implicitHeight: 20
                                            Text { id: salTxt; text: model.empSalary + "đ/h"; font.pixelSize: 10; color: "#059669"; font.bold: true; anchors.centerIn: parent }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // FORM TẠO HỒ SƠ NHÂN SỰ MỚI
    Dialog {
        id: newEmpDialog
        width: Math.min(500, empPage.width > 0 ? empPage.width - 24 : 500)
        height: Math.min(570, empPage.height > 0 ? empPage.height - 24 : 570)
        modal: true
        padding: 20
        x: Math.max(0, (empPage.width - width) / 2)
        y: Math.max(0, (empPage.height - height) / 2)
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#CBD5E1"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text { text: "✨"; font.pixelSize: 20 }
                Text {
                    text: "Tạo Hồ Sơ Nhân Sự Mới"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#0F766E"
                    Layout.fillWidth: true
                }
                Text {
                    text: "(<font color='#E11D48'>*</font>) Bắt buộc"
                    textFormat: Text.StyledText
                    font.pixelSize: 11
                    color: "#64748B"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }

            ScrollView {
                id: newEmpScrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: newEmpScrollView.availableWidth
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Mã nhân viên (ID) <font color='#E11D48'>*</font>:"
                            textFormat: Text.StyledText
                            font.bold: true; color: "#334155"; font.pixelSize: 12
                        }
                        TextField {
                            id: newId
                            placeholderText: "VD: NV01"
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: TextInput.AlignVCenter

                            background: Rectangle {
                                implicitHeight: 40
                                radius: 8
                                border.color: newId.activeFocus ? "#0F766E" : (newId.text.trim() === "" ? "#CBD5E1" : "#0D9488")
                                border.width: newId.activeFocus ? 2 : 1
                                color: "#F8FAFC"
                            }
                            onAccepted: newName.forceActiveFocus()
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Họ và tên nhân viên <font color='#E11D48'>*</font>:"
                            textFormat: Text.StyledText
                            font.bold: true; color: "#334155"; font.pixelSize: 12
                        }
                        TextField {
                            id: newName
                            placeholderText: "Nhập đầy đủ họ tên..."
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: TextInput.AlignVCenter

                            background: Rectangle {
                                implicitHeight: 40
                                radius: 8
                                border.color: newName.activeFocus ? "#0F766E" : (newName.text.trim() === "" ? "#CBD5E1" : "#0D9488")
                                border.width: newName.activeFocus ? 2 : 1
                                color: "#F8FAFC"
                            }
                            onAccepted: newPhone.forceActiveFocus()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Số điện thoại <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            TextField {
                                id: newPhone
                                placeholderText: "09xxxxxxxx (10 số)"
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                inputMethodHints: Qt.ImhDialableCharactersOnly
                                leftPadding: 12
                                verticalAlignment: TextInput.AlignVCenter

                                background: Rectangle {
                                    implicitHeight: 40
                                    radius: 8
                                    border.color: newPhone.activeFocus ? "#0F766E" : (newPhone.text.trim() === "" ? "#CBD5E1" : "#0D9488")
                                    border.width: newPhone.activeFocus ? 2 : 1
                                    color: "#F8FAFC"
                                }
                                onAccepted: newSalary.forceActiveFocus()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Mức lương/giờ (VNĐ) <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            TextField {
                                id: newSalary
                                placeholderText: "VD: 25000"
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                inputMethodHints: Qt.ImhDigitsOnly
                                leftPadding: 12
                                verticalAlignment: TextInput.AlignVCenter

                                background: Rectangle {
                                    implicitHeight: 40
                                    radius: 8
                                    border.color: newSalary.activeFocus ? "#0F766E" : (newSalary.text.trim() === "" ? "#CBD5E1" : "#0D9488")
                                    border.width: newSalary.activeFocus ? 2 : 1
                                    color: "#F8FAFC"
                                }
                                onAccepted: newGender.forceActiveFocus()
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Giới tính <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            ComboBox {
                                id: newGender
                                Layout.fillWidth: true
                                model: ["Nam", "Nữ", "Khác"]
                                font.pixelSize: 13

                                background: Rectangle {
                                    implicitHeight: 40
                                    radius: 8
                                    border.color: newGender.activeFocus ? "#0F766E" : "#CBD5E1"
                                    color: "#F8FAFC"
                                }
                                Keys.onReturnPressed: newRole.forceActiveFocus()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Loại hợp đồng <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            ComboBox {
                                id: newRole
                                Layout.fillWidth: true
                                model: ["Part-time", "Full-time", "Bảo vệ (Full-time)"]
                                font.pixelSize: 13

                                background: Rectangle {
                                    implicitHeight: 40
                                    radius: 8
                                    border.color: newRole.activeFocus ? "#0F766E" : "#CBD5E1"
                                    color: "#F8FAFC"
                                }
                                Keys.onReturnPressed: if (btnSaveForm.enabled) btnSaveForm.clicked()
                            }
                        }
                    }
                }
            }

            Text {
                id: newEmpError
                color: "#E11D48"
                visible: text !== ""
                font.pixelSize: 12
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    background: Rectangle {
                        color: parent.pressed ? "#E2E8F0" : "#F1F5F9"
                        radius: 8
                    }
                    contentItem: Text {
                        text: "Hủy bỏ"
                        color: "#475569"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        newEmpError.text = ""
                        newEmpDialog.close()
                    }
                }

                Button {
                    id: btnSaveForm
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    property bool isValidForm: newId.text.trim() !== "" && newName.text.trim() !== "" && newPhone.text.trim() !== "" && newSalary.text.trim() !== ""
                    enabled: isValidForm

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#0D9488" : "#0F766E") : "#CBD5E1"
                        radius: 8
                    }
                    contentItem: Text {
                        text: "💾 Lưu hồ sơ"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (!validatePhone(newPhone.text)) {
                            newEmpError.text = "⚠️ SĐT không hợp lệ (bắt đầu bằng 0 và đủ 10 chữ số)!"
                            return
                        }
                        var salaryVal = parseFloat(newSalary.text)
                        if (isNaN(salaryVal) || salaryVal < 0) {
                            newEmpError.text = "⚠️ Mức lương không hợp lệ!"
                            return
                        }
                        var dupError = checkDuplicate(newId.text.trim(), newPhone.text.trim(), "")
                        if (dupError !== "") {
                            newEmpError.text = "⚠️ " + dupError
                            return
                        }

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.addEmployeeCSV) {
                            if (coffeeSystem.addEmployeeCSV(newId.text.trim(), newName.text.trim(), newPhone.text.trim(), salaryVal, newGender.currentText, newRole.currentText, "", "", "", "", "", "", "")) {
                                newEmpError.text = ""
                                newEmpDialog.close()
                                refreshData()
                            } else {
                                newEmpError.text = "⚠️ Lỗi: Không thể ghi file. Vui lòng thử lại!"
                            }
                        }
                    }
                }
            }
        }
    }

    // FORM CHỈNH SỬA HỒ SƠ CHI TIẾT
    Dialog {
        id: editEmpDialog
        width: Math.min(600, empPage.width > 0 ? empPage.width - 24 : 600)
        height: Math.min(660, empPage.height > 0 ? empPage.height - 24 : 660)
        modal: true
        padding: 20
        x: Math.max(0, (empPage.width - width) / 2)
        y: Math.max(0, (empPage.height - height) / 2)
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#CBD5E1"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text { text: "✏️"; font.pixelSize: 20 }
                Text {
                    text: "Chỉnh Sửa Hồ Sơ Chi Tiết"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#0F766E"
                    Layout.fillWidth: true
                }
                Text {
                    text: "(<font color='#E11D48'>*</font>) Bắt buộc"
                    textFormat: Text.StyledText
                    font.pixelSize: 11
                    color: "#64748B"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }

            ScrollView {
                id: editEmpScrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: editEmpScrollView.availableWidth
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text { text: "Mã nhân viên (ID - Không đổi):"; font.bold: true; color: "#64748B"; font.pixelSize: 12 }
                        TextField {
                            id: editId
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: TextInput.AlignVCenter
                            background: Rectangle {
                                implicitHeight: 38; radius: 8; border.color: "#CBD5E1"; color: "#E2E8F0"
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Họ và tên <font color='#E11D48'>*</font>:"
                            textFormat: Text.StyledText
                            font.bold: true; color: "#334155"; font.pixelSize: 12
                        }
                        TextField {
                            id: editName
                            placeholderText: "Họ và tên nhân viên..."
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: TextInput.AlignVCenter
                            background: Rectangle {
                                implicitHeight: 38; radius: 8; border.color: editName.activeFocus ? "#0F766E" : "#CBD5E1"; color: "#F8FAFC"
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Số điện thoại <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            TextField {
                                id: editPhone
                                placeholderText: "SĐT 10 số..."
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                inputMethodHints: Qt.ImhDialableCharactersOnly
                                leftPadding: 12
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    implicitHeight: 38; radius: 8; border.color: editPhone.activeFocus ? "#0F766E" : "#CBD5E1"; color: "#F8FAFC"
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Lương/giờ (VNĐ) <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            TextField {
                                id: editSalary
                                placeholderText: "Mức lương..."
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                inputMethodHints: Qt.ImhDigitsOnly
                                leftPadding: 12
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    implicitHeight: 38; radius: 8; border.color: editSalary.activeFocus ? "#0F766E" : "#CBD5E1"; color: "#F8FAFC"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Giới tính <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            ComboBox {
                                id: editGender
                                Layout.fillWidth: true
                                model: ["Nam", "Nữ", "Khác"]
                                font.pixelSize: 13
                                background: Rectangle {
                                    implicitHeight: 38; radius: 8; border.color: "#CBD5E1"; color: "#F8FAFC"
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Vị trí / Ca <font color='#E11D48'>*</font>:"
                                textFormat: Text.StyledText
                                font.bold: true; color: "#334155"; font.pixelSize: 12
                            }
                            ComboBox {
                                id: editRole
                                Layout.fillWidth: true
                                model: ["Part-time", "Full-time", "Bảo vệ (Full-time)"]
                                font.pixelSize: 13
                                background: Rectangle {
                                    implicitHeight: 38; radius: 8; border.color: "#CBD5E1"; color: "#F8FAFC"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Ngày sinh (DD/MM/YYYY):"; font.bold: true; color: "#334155"; font.pixelSize: 12 }
                            TextField {
                                id: editDob
                                placeholderText: "VD: 15/08/2000"
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                leftPadding: 12
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    implicitHeight: 38; radius: 8; border.color: editDob.activeFocus ? "#0F766E" : "#CBD5E1"; color: "#F8FAFC"
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Số CCCD/CMND:"; font.bold: true; color: "#334155"; font.pixelSize: 12 }
                            TextField {
                                id: editCccd
                                placeholderText: "12 số CCCD..."
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                leftPadding: 12
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    implicitHeight: 38; radius: 8; border.color: editCccd.activeFocus ? "#0F766E" : "#CBD5E1"; color: "#F8FAFC"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Ảnh Đại Diện (URL/Path):"; font.bold: true; color: "#334155"; font.pixelSize: 12 }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                TextField {
                                    id: editAvatar
                                    placeholderText: "Đường dẫn file ảnh..."
                                    Layout.fillWidth: true
                                    font.pixelSize: 12
                                    leftPadding: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    background: Rectangle {
                                        implicitHeight: 38; radius: 8; border.color: "#CBD5E1"; color: "#F8FAFC"
                                    }
                                }
                                Button {
                                    text: "📁"
                                    implicitWidth: 38; implicitHeight: 38
                                    onClicked: pickAvatarDialog.open()
                                }
                            }
                        }

                        Image {
                            source: editAvatar.text !== "" ? editAvatar.text : ""
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            fillMode: Image.PreserveAspectCrop
                            clip: true; mipmap: true; smooth: true
                            visible: source.toString() !== ""
                            Rectangle {
                                anchors.fill: parent; color: "transparent"
                                border.color: "#CBD5E1"; border.width: 1; radius: 8
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (parent.source.toString() !== "") {
                                        imagePreviewDialog.imageSource = parent.source; imagePreviewDialog.open()
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Ảnh CCCD (Mặt Trước):"; font.bold: true; color: "#334155"; font.pixelSize: 12 }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                TextField {
                                    id: editCccdFront
                                    placeholderText: "Đường dẫn file ảnh..."
                                    Layout.fillWidth: true
                                    font.pixelSize: 12
                                    leftPadding: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    background: Rectangle {
                                        implicitHeight: 38; radius: 8; border.color: "#CBD5E1"; color: "#F8FAFC"
                                    }
                                }
                                Button {
                                    text: "📁"
                                    implicitWidth: 38; implicitHeight: 38
                                    onClicked: pickCccdFrontDialog.open()
                                }
                            }
                        }

                        Image {
                            source: editCccdFront.text !== "" ? editCccdFront.text : ""
                            Layout.preferredWidth: 80; Layout.preferredHeight: 55
                            fillMode: Image.PreserveAspectCrop
                            clip: true; mipmap: true; smooth: true
                            visible: source.toString() !== ""
                            Rectangle {
                                anchors.fill: parent; color: "transparent"
                                border.color: "#CBD5E1"; border.width: 1; radius: 8
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (parent.source.toString() !== "") {
                                        imagePreviewDialog.imageSource = parent.source; imagePreviewDialog.open()
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Ảnh CCCD (Mặt Sau):"; font.bold: true; color: "#334155"; font.pixelSize: 12 }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                TextField {
                                    id: editCccdBack
                                    placeholderText: "Đường dẫn file ảnh..."
                                    Layout.fillWidth: true
                                    font.pixelSize: 12
                                    leftPadding: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    background: Rectangle {
                                        implicitHeight: 38; radius: 8; border.color: "#CBD5E1"; color: "#F8FAFC"
                                    }
                                }
                                Button {
                                    text: "📁"
                                    implicitWidth: 38; implicitHeight: 38
                                    onClicked: pickCccdBackDialog.open()
                                }
                            }
                        }

                        Image {
                            source: editCccdBack.text !== "" ? editCccdBack.text : ""
                            Layout.preferredWidth: 80; Layout.preferredHeight: 55
                            fillMode: Image.PreserveAspectCrop
                            clip: true; mipmap: true; smooth: true
                            visible: source.toString() !== ""
                            Rectangle {
                                anchors.fill: parent; color: "transparent"
                                border.color: "#CBD5E1"; border.width: 1; radius: 8
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (parent.source.toString() !== "") {
                                        imagePreviewDialog.imageSource = parent.source; imagePreviewDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                id: editEmpError
                color: "#E11D48"
                visible: text !== ""
                font.pixelSize: 12
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 42
                    background: Rectangle {
                        color: parent.pressed ? "#FEE2E2" : "#FFF1F2"
                        radius: 8
                        border.color: "#FDA4AF"
                    }
                    contentItem: Text {
                        text: "🗑️ Xoá hồ sơ"
                        color: "#BE123C"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmDeleteDialog.open()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    background: Rectangle {
                        color: parent.pressed ? "#CBD5E1" : "#F1F5F9"
                        radius: 8
                    }
                    contentItem: Text {
                        text: "Đóng"
                        color: "#475569"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: editEmpDialog.close()
                }

                Button {
                    id: btnUpdateEmp
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    property bool isValidForm: editName.text.trim() !== "" && editPhone.text.trim() !== "" && editSalary.text.trim() !== ""
                    enabled: isValidForm

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#0D9488" : "#0F766E") : "#CBD5E1"
                        radius: 8
                    }
                    contentItem: Text {
                        text: "🔄 Cập nhật"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (!validatePhone(editPhone.text)) { editEmpError.text = "⚠️ Số điện thoại không hợp lệ!"; return }
                        if (!validateDob(editDob.text)) { editEmpError.text = "⚠️ Ngày sinh phải đúng dạng DD/MM/YYYY!"; return }
                        if (!validateCccd(editCccd.text)) { editEmpError.text = "⚠️ Số CCCD phải đủ 12 chữ số!"; return }
                        var salaryVal = parseFloat(editSalary.text)
                        if (isNaN(salaryVal) || salaryVal < 0) { editEmpError.text = "⚠️ Mức lương không hợp lệ!"; return }

                        var dupError = checkDuplicate(editId.text.trim(), editPhone.text.trim(), editId.text.trim())
                        if (dupError !== "") { editEmpError.text = "⚠️ " + dupError; return }

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.updateEmployeeCSV) {
                            if (coffeeSystem.updateEmployeeCSV(
                                    editId.text.trim(),
                                    editName.text.trim(),
                                    editPhone.text.trim(),
                                    salaryVal,
                                    editGender.currentText,
                                    editRole.currentText,
                                    editDob.text.trim(),
                                    editCccd.text.trim(),
                                    editEmpDialog.currentShiftDate, // Thay cho "": Giữ lại ngày ca làm
                                    editEmpDialog.currentShiftTime, // Thay cho "": Giữ lại giờ ca làm
                                    editAvatar.text.trim(),
                                    editCccdFront.text.trim(),
                                    editCccdBack.text.trim()
                            )) {
                                editEmpError.text = ""
                                editEmpDialog.close()
                                refreshData()
                            } else {
                                editEmpError.text = "⚠️ Lỗi: Không thể cập nhật file!"
                            }
                        }
                    }
                }
            }
        }
    }
}