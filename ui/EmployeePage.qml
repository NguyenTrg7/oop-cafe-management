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

    StackView.onActivating: syncNavBar()
    Component.onCompleted: syncNavBar()

    Rectangle {
        anchors.fill: parent
        color: "#F0F9FF"

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.9 // Responsive width
            spacing: 20

            Text {
                text: "☕ CA LÀM VIỆC NHÂN VIÊN"
                font.pixelSize: Math.max(18, Math.min(26, parent.width * 0.05))
                font.bold: true
                color: "#0369A1"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Tài khoản hệ thống: " + (typeof accountHandler !== "undefined" ? accountHandler.currentUserPhone : "nhanvien")
                font.pixelSize: 15
                color: "#475569"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.maximumWidth: 450 // Không dãn quá to trên màn hình lớn

                Button {
                    id: btnCheckIn
                    Layout.fillWidth: true // Tự động co giãn theo RowLayout
                    Layout.preferredHeight: 48

                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    background: Rectangle {
                        color: btnCheckIn.pressed ? "#F1F5F9" : "#FFFFFF"
                        border.color: "#CBD5E1"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Item {
                        anchors.fill: parent
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Rectangle { width: 10; height: 10; radius: 5; color: "#22C55E"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "CHECK-IN CA LÀM"; font.bold: true; font.pixelSize: 13; color: "#1E293B"; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }

                    onClicked: {
                        employeePage.currentAction = "CHECK_IN"
                        txtConfirmPhone.text = ""
                        lblDialogError.visible = false
                        statusText.visible = false
                        confirmDialog.open()
                    }
                }

                Button {
                    id: btnCheckOut
                    Layout.fillWidth: true // Tự động co giãn theo RowLayout
                    Layout.preferredHeight: 48

                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    background: Rectangle {
                        color: btnCheckOut.pressed ? "#F1F5F9" : "#FFFFFF"
                        border.color: "#CBD5E1"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Item {
                        anchors.fill: parent
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Rectangle { width: 10; height: 10; radius: 5; color: "#EF4444"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "CHECK-OUT CA LÀM"; font.bold: true; font.pixelSize: 13; color: "#1E293B"; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }

                    onClicked: {
                        employeePage.currentAction = "CHECK_OUT"
                        txtConfirmPhone.text = ""
                        lblDialogError.visible = false
                        statusText.visible = false
                        confirmDialog.open()
                    }
                }
            }

            Text {
                id: statusText
                text: ""
                font.bold: true
                font.pixelSize: 16
                visible: false
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
            }
        }
    }

    Popup {
        id: confirmDialog
        width: Math.min(380, employeePage.width * 0.9)
        height: 290
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
                leftPadding: 10
                rightPadding: 10
                topPadding: 0
                bottomPadding: 0
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
                text: "SĐT chưa được gán thông tin Nhân viên bởi Manager!"
                color: "#DC2626"
                font.pixelSize: 12
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
                    id: btnCancel
                    text: "Hủy"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    background: Rectangle {
                        color: btnCancel.pressed ? "#E2E8F0" : "#F1F5F9"
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

                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    background: Rectangle {
                        color: btnConfirm.pressed ? "#0284C7" : "#0369A1"
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

                        var isValid = false;
                        var employeeName = "";
                        var phoneToRecord = inputStr;
                        var empId = "";

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
                            var list = coffeeSystem.loadEmployees()
                            for (var i = 0; i < list.length; i++) {
                                if (list[i].phone === inputStr || list[i].id === inputStr) {
                                    isValid = true;
                                    employeeName = list[i].name;
                                    phoneToRecord = list[i].phone;
                                    empId = list[i].id;
                                    break;
                                }
                            }
                        }

                        if (!isValid) {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.verifyEmployeePhone) {
                                isValid = coffeeSystem.verifyEmployeePhone(inputStr)
                            }
                        }

                        if (!isValid) {
                            lblDialogError.text = "Thông tin chưa được gán bởi Quản lý!"
                            lblDialogError.visible = true
                            return
                        }

                        var todayStr = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                        var hasShiftToday = false

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadShifts) {
                            var todayShifts = coffeeSystem.loadShifts(todayStr)
                            for (var s = 0; s < todayShifts.length; s++) {
                                if (todayShifts[s].phone === phoneToRecord || todayShifts[s].id === empId || todayShifts[s].id === inputStr) {
                                    hasShiftToday = true
                                    break
                                }
                            }
                        } else {
                            hasShiftToday = true
                        }

                        if (!hasShiftToday) {
                            lblDialogError.text = "⚠️ Bạn không có ca làm việc đăng ký hôm nay (" + todayStr + ")!"
                            lblDialogError.visible = true
                            return
                        }

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadAttendance) {
                            var attendanceList = coffeeSystem.loadAttendance()
                            var lastAction = ""

                            for (var a = 0; a < attendanceList.length; a++) {
                                if (attendanceList[a].identifier === phoneToRecord || attendanceList[a].identifier === empId) {
                                    lastAction = attendanceList[a].type
                                }
                            }

                            if (employeePage.currentAction === "CHECK_OUT" && lastAction !== "CHECK_IN") {
                                lblDialogError.text = "⚠️ Bạn chưa Check-In ca làm, không thể Check-Out!"
                                lblDialogError.visible = true
                                return
                            }

                            if (employeePage.currentAction === "CHECK_IN" && lastAction === "CHECK_IN") {
                                lblDialogError.text = "⚠️ Bạn đã Check-In ca làm trước đó rồi!"
                                lblDialogError.visible = true
                                return
                            }
                        }

                        var currentTime = Qt.formatDateTime(new Date(), "hh:mm dd/MM/yyyy")
                        var displayName = employeeName !== "" ? employeeName : ("SĐT " + phoneToRecord)

                        confirmDialog.close()

                        if (employeePage.currentAction === "CHECK_IN") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_IN", currentTime)
                            }
                            statusText.text = "🟢 Nhân viên " + displayName + " đã Check-In thành công lúc " + currentTime
                            statusText.color = "#15803D"
                        }
                        else if (employeePage.currentAction === "CHECK_OUT") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_OUT", currentTime)
                            }
                            statusText.text = "🔴 Nhân viên " + displayName + " đã Check-Out thành công lúc " + currentTime
                            statusText.color = "#B91C1C"
                        }

                        statusText.visible = true
                    }
                }
            }
        }
    }
}