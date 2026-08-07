import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: employeePage
    title: "Trang Nhân Viên"

    property string currentAction: ""

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("EmployeePage.qml", "Ca Làm Nhân Viên")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("EmployeePage.qml", "Ca Làm Nhân Viên")
            if (win.pageTitle !== undefined) win.pageTitle = "Trang Nhân Viên"
        }
    }

    function getLogoSource() {
        if (typeof savesDir !== "undefined" && savesDir !== "") {
            var base = savesDir.toString().replace(/[\\\/]+$/, "")
            base = base.replace(/[\\\/]saves$/i, "")
            return "file:///" + (base + "/data/logo.png").replace(/\\/g, "/")
        }
        if (typeof applicationDir !== "undefined" && applicationDir !== "") {
            return "file:///" + applicationDir.toString().replace(/\\/g, "/") + "/data/logo.png"
        }
        return ""
    }

    // ===== HÀM ĐỌC & ÉP KIỂU THỜI GIAN ĐA NĂNG =====
    function parseTimeString(tStr) {
        if (!tStr) return null
        var str = tStr.toString().trim().toLowerCase()

        // Định dạng "07:00", "7:00", "07:00:00"
        var m1 = str.match(/^(\d{1,2}):(\d{2})/)
        if (m1) {
            var d1 = new Date()
            d1.setHours(parseInt(m1[1], 10), parseInt(m1[2], 10), 0, 0)
            return d1
        }

        // Định dạng "7h", "7h30", "15h00"
        var m2 = str.match(/^(\d{1,2})h(\d{2})?/)
        if (m2) {
            var hrs = parseInt(m2[1], 10)
            var mins = m2[2] ? parseInt(m2[2], 10) : 0
            var d2 = new Date()
            d2.setHours(hrs, mins, 0, 0)
            return d2
        }

        return null
    }

    function parseShiftTime(shiftObj) {
        if (!shiftObj) return { start: null, end: null }

        var startStr = shiftObj.startTime || shiftObj.start || shiftObj.timeStart || shiftObj.shiftStart || ""
        var endStr = shiftObj.endTime || shiftObj.end || shiftObj.timeEnd || shiftObj.shiftEnd || ""

        if ((!startStr || !endStr) && (shiftObj.time || shiftObj.shiftTime || shiftObj.name)) {
            var fullStr = shiftObj.time || shiftObj.shiftTime || shiftObj.name || ""
            var parts = fullStr.split(/[-–—]/)
            if (parts.length >= 2) {
                startStr = parts[0].trim()
                endStr = parts[1].trim()
            }
        }

        var startDate = parseTimeString(startStr)
        var endDate = parseTimeString(endStr)

        if (startDate && endDate && endDate <= startDate) {
            endDate.setDate(endDate.getDate() + 1)
        }

        return { start: startDate, end: endDate, startStr: startStr, endStr: endStr }
    }

    StackView.onActivating: syncNavBar()
    Component.onCompleted: syncNavBar()

    Rectangle {
        anchors.fill: parent
        color: "#F0F9FF"

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(800, parent.width * 0.9)
            spacing: 28

            // ===== LOGO + TÊN QUÁN =====
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Math.max(8, Math.min(16, employeePage.width * 0.015))

                Text {
                    text: "GIANG'S COFFEE"
                    font.pixelSize: Math.max(28, Math.min(52, Math.round(employeePage.width * 0.045)))
                    font.bold: true
                    font.family: "Poppins Bold"
                    color: "#846559"
                    Layout.alignment: Qt.AlignVCenter
                }

                Image {
                    Layout.preferredWidth: Math.max(60, Math.min(110, Math.round(employeePage.width * 0.09)))
                    Layout.preferredHeight: Layout.preferredWidth
                    source: getLogoSource()
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // ===== TIÊU ĐỀ PHỤ =====
            Text {
                text: "CA LÀM VIỆC CỦA BẠN"
                font.pixelSize: 32
                font.bold: true
                color: "#1E293B"
                Layout.alignment: Qt.AlignHCenter
            }

            // ===== 2 NÚT CHECK-IN / CHECK-OUT =====
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 40

                // CHECK-IN
                Rectangle {
                    width: 300
                    height: 150
                    radius: 22
                    color: "#FFFFFF"
                    border.color: "#BBF7D0"
                    border.width: 3

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: "#22C55E"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "☕"
                                font.pixelSize: 22
                                color: "white"
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "CHECK-IN"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#16A34A"
                            }
                            Text {
                                text: "CA LÀM"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#15803D"
                            }
                            Text {
                                text: "Bắt đầu ca làm việc"
                                font.pixelSize: 18
                                color: "#64748B"
                            }
                        }

                        Text {
                            text: "→"
                            font.pixelSize: 24
                            color: "#22C55E"
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            employeePage.currentAction = "CHECK_IN"
                            txtConfirmPhone.text = ""
                            lblDialogError.visible = false
                            statusText.visible = false
                            confirmDialog.open()
                        }
                    }
                }

                // CHECK-OUT
                Rectangle {
                    width: 300
                    height: 150
                    radius: 22
                    color: "#FFFFFF"
                    border.color: "#FECACA"
                    border.width: 3

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: "#EF4444"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "☕"
                                font.pixelSize: 22
                                color: "white"
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "CHECK-OUT"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#DC2626"
                            }
                            Text {
                                text: "CA LÀM"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#B91C1C"
                            }
                            Text {
                                text: "Kết thúc ca làm việc"
                                font.pixelSize: 18
                                color: "#64748B"
                            }
                        }

                        Text {
                            text: "←"
                            font.pixelSize: 24
                            color: "#EF4444"
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            employeePage.currentAction = "CHECK_OUT"
                            txtConfirmPhone.text = ""
                            lblDialogError.visible = false
                            statusText.visible = false
                            confirmDialog.open()
                        }
                    }
                }
            }

            // ===== TRẠNG THÁI =====
            Text {
                id: statusText
                text: ""
                font.bold: true
                font.pixelSize: 15
                visible: false
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 20
            }

            // ===== SLOGAN =====
            Text {
                text: "-Gửi chút bình yên vào tách cà phê ấm-"
                font.pixelSize: 20
                font.italic: true
                color: "#7C6C62"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 12
            }
        }
    }

    // ===== DIALOG XÁC NHẬN VỚI TÍNH NĂNG TỰ ĐỘNG ÉP GIỜ LÊN HỆ THỐNG =====
    Popup {
        id: confirmDialog
        width: Math.min(440, employeePage.width * 0.9)
        height: 320
        modal: true
        focus: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#BAE6FD"
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: employeePage.currentAction === "CHECK_IN" ? "🟢 Xác nhận Check-in" : "🔴 Xác nhận Check-out"
                font.pixelSize: 18
                font.bold: true
                color: "#0369A1"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Nhập SĐT hoặc Mã NV để xác thực:"
                font.pixelSize: 13
                color: "#64748B"
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: txtConfirmPhone
                placeholderText: "Nhập SĐT / Mã nhân viên..."
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                font.pixelSize: 15

                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                topPadding: 0
                bottomPadding: 0
                leftPadding: 12
                rightPadding: 12

                color: "#1E293B"
                background: Rectangle {
                    radius: 8
                    border.color: "#93C5FD"
                    border.width: 1
                    color: "#F8FAFC"
                }
                Keys.onReturnPressed: btnConfirm.clicked()
                Keys.onEnterPressed: btnConfirm.clicked()
            }

            Text {
                id: lblDialogError
                text: ""
                color: "#DC2626"
                font.pixelSize: 13
                font.bold: true
                visible: false
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Layout.topMargin: 5

                Button {
                    text: "Hủy"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: parent.pressed ? "#E2E8F0" : "#F1F5F9"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#475569"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmDialog.close()
                }

                Button {
                    id: btnConfirm
                    text: "Xác nhận"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: parent.pressed ? "#0284C7" : "#0369A1"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        var inputStr = txtConfirmPhone.text.trim()
                        if (inputStr === "") {
                            lblDialogError.text = "Vui lòng nhập số điện thoại hoặc Mã NV!"
                            lblDialogError.visible = true
                            return
                        }

                        // 1. Xác thực nhân viên
                        var isValid = false
                        var employeeName = ""
                        var phoneToRecord = inputStr
                        var empId = ""

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
                            var list = coffeeSystem.loadEmployees()
                            for (var i = 0; i < list.length; i++) {
                                if (list[i].phone === inputStr || list[i].id === inputStr) {
                                    isValid = true
                                    employeeName = list[i].name
                                    phoneToRecord = list[i].phone
                                    empId = list[i].id
                                    break
                                }
                            }
                        }

                        if (!isValid && typeof coffeeSystem !== "undefined" && coffeeSystem.verifyEmployeePhone) {
                            isValid = coffeeSystem.verifyEmployeePhone(inputStr)
                        }

                        if (!isValid) {
                            lblDialogError.text = "⚠️ Nhân viên chưa được đăng ký trong hệ thống!"
                            lblDialogError.visible = true
                            return
                        }

                        // 2. Tìm ca làm hôm nay
                        var now = new Date()
                        var todayStr1 = Qt.formatDateTime(now, "dd/MM/yyyy")
                        var todayStr2 = Qt.formatDateTime(now, "yyyy-MM-dd")
                        var userShift = null

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadShifts) {
                            var todayShifts = coffeeSystem.loadShifts(todayStr1)
                            if (!todayShifts || todayShifts.length === 0) {
                                todayShifts = coffeeSystem.loadShifts(todayStr2)
                            }
                            if (!todayShifts || todayShifts.length === 0) {
                                todayShifts = coffeeSystem.loadShifts()
                            }

                            if (todayShifts && todayShifts.length > 0) {
                                for (var s = 0; s < todayShifts.length; s++) {
                                    var sh = todayShifts[s]
                                    var shPhone = sh.phone || sh.employeePhone || sh.identifier || ""
                                    var shId = sh.id || sh.employeeId || sh.empId || ""

                                    if (shPhone === phoneToRecord || shId === empId || shId === inputStr || shPhone === inputStr) {
                                        userShift = sh
                                        break
                                    }
                                }
                            }
                        }

                        if (!userShift) {
                            lblDialogError.text = "⚠️ Bạn không có ca làm việc đăng ký hôm nay (" + todayStr1 + ")!"
                            lblDialogError.visible = true
                            return
                        }

                        // 3. Parse giờ ca làm
                        var shiftTimes = parseShiftTime(userShift)
                        if (!shiftTimes.start || !shiftTimes.end) {
                            lblDialogError.text = "⚠️ Không thể xác định giờ ca làm!"
                            lblDialogError.visible = true
                            return
                        }

                        // 4. Đọc lượt điểm danh gần nhất trong ngày
                        var lastActionToday = ""
                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadAttendance) {
                            var attendanceList = coffeeSystem.loadAttendance()
                            for (var a = 0; a < attendanceList.length; a++) {
                                var att = attendanceList[a]
                                if (att.identifier === phoneToRecord || att.identifier === empId) {
                                    if (att.timestamp && att.timestamp.indexOf(todayStr1) !== -1) {
                                        lastActionToday = att.type
                                    }
                                }
                            }
                        }

                        // 5. CẤU HÌNH RÀNG BUỘC THỜI GIAN
                        var tenMinsMs = 10 * 60 * 1000
                        var minCheckIn = new Date(shiftTimes.start.getTime() - tenMinsMs)
                        var maxCheckIn = shiftTimes.end

                        var startStr = Qt.formatDateTime(shiftTimes.start, "hh:mm")
                        var endStr = Qt.formatDateTime(shiftTimes.end, "hh:mm")
                        var minCheckInStr = Qt.formatDateTime(minCheckIn, "hh:mm")

                        // Giới hạn Check-out sớm tối đa 5 phút
                        var minCheckOut = new Date(shiftTimes.end.getTime() - (5 * 60 * 1000))
                        var minCheckOutStr = Qt.formatDateTime(minCheckOut, "hh:mm")

                        // Ngưỡng Tự động Check-Out: Giờ kết thúc ca + 30 phút
                        var autoCheckoutThreshold = new Date(shiftTimes.end.getTime() + (30 * 60 * 1000))

                        // ===== XỬ LÝ TỰ ĐỘNG CHECK-OUT KHI QUÁ CA 30 PHÚT =====
                        var autoCheckedOutTriggered = false
                        if (lastActionToday === "CHECK_IN" && now > autoCheckoutThreshold) {
                            var autoTimeStr = Qt.formatDateTime(shiftTimes.end, "hh:mm dd/MM/yyyy")
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_OUT", autoTimeStr)
                            }
                            lastActionToday = "CHECK_OUT"
                            autoCheckedOutTriggered = true
                        }

                        var displayName = employeeName !== "" ? employeeName : ("SĐT " + phoneToRecord)

                        // 6. XỬ LÝ CHECK-IN
                        if (employeePage.currentAction === "CHECK_IN") {
                            if (lastActionToday === "CHECK_IN") {
                                lblDialogError.text = "⚠️ Bạn đã Check-In cho ca hôm nay rồi!"
                                lblDialogError.visible = true
                                return
                            }
                            if (now < minCheckIn) {
                                lblDialogError.text = "⚠️ Ca làm từ " + startStr + " - " + endStr + ".\nChỉ được Check-In từ " + minCheckInStr + " (sớm tối đa 10 phút)!"
                                lblDialogError.visible = true
                                return
                            }
                            if (now > maxCheckIn) {
                                lblDialogError.text = "⚠️ Ca làm việc (" + startStr + " - " + endStr + ") đã kết thúc, không thể Check-In!"
                                lblDialogError.visible = true
                                return
                            }
                        }
                        // 7. XỬ LÝ CHECK-OUT
                        else if (employeePage.currentAction === "CHECK_OUT") {
                            // Nếu đã được tự động Check-Out do quá 30 phút
                            if (autoCheckedOutTriggered) {
                                confirmDialog.close()
                                statusText.text = "🔴 Ca làm kết thúc lúc " + endStr + ". Hệ thống đã TỰ ĐỘNG Check-Out chuẩn " + endStr + " cho " + displayName + "!"
                                statusText.color = "#DC2626"
                                statusText.visible = true
                                return
                            }

                            if (lastActionToday !== "CHECK_IN") {
                                lblDialogError.text = "⚠️ Bạn chưa Check-In hôm nay, không thể Check-Out!"
                                lblDialogError.visible = true
                                return
                            }
                            if (now < minCheckOut) {
                                lblDialogError.text = "⚠️ Ca làm kết thúc lúc " + endStr + ".\nBạn chỉ được Check-Out từ " + minCheckOutStr + " (sớm tối đa 5 phút)!"
                                lblDialogError.visible = true
                                return
                            }
                        }

                        // 8. GHI NHẬN LƯỢT ĐIỂM DANH
                        // Nếu Check-Out vượt quá giờ hết ca (VD: quẹt lúc 22:12 cho ca hết lúc 22:00), tự động ép về đúng 22:00
                        var recordTime = now
                        if (employeePage.currentAction === "CHECK_OUT" && now > shiftTimes.end) {
                            recordTime = shiftTimes.end
                        }

                        var formattedRecordTime = Qt.formatDateTime(recordTime, "hh:mm dd/MM/yyyy")

                        confirmDialog.close()

                        if (employeePage.currentAction === "CHECK_IN") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV)
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_IN", formattedRecordTime)
                            statusText.text = "🟢 Nhân viên " + displayName + " đã Check-In thành công lúc " + formattedRecordTime
                            statusText.color = "#15803D"
                        } else {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV)
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_OUT", formattedRecordTime)
                            statusText.text = "🔴 Nhân viên " + displayName + " đã Check-Out thành công lúc " + formattedRecordTime + (now > shiftTimes.end ? " (Đã chốt giờ ca chuẩn " + endStr + ")" : "")
                            statusText.color = "#B91C1C"
                        }
                        statusText.visible = true
                    }
                }
            }
        }
    }
}