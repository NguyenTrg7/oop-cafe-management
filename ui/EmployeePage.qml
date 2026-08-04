import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: employeePage
    title: "Trang Nhân Viên"

    property string currentAction: "" // Trạng thái: "CHECK_IN" hoặc "CHECK_OUT"
    property string pendingPhone: ""  // Biến tạm để lưu SĐT khi chờ chuyển trang

    // ==========================================
    // TIMER TRÌ HOÃN ĐIỀU HƯỚNG
    // ==========================================
    Timer {
        id: delayNavigationTimer
        interval: 1500 // Độ trễ 1.5 giây để đọc thông báo
        repeat: false
        onTriggered: {
            // Lấy con trỏ StackView điều hướng
            var navStack = StackView.view || (typeof stackView !== "undefined" ? stackView : null)

            if (!navStack) {
                console.log("Lỗi: Không tìm thấy StackView để điều hướng!")
                return
            }

            if (employeePage.currentAction === "CHECK_IN") {
                // Chuyển sang OrderPage.qml và truyền kèm SĐT
                navStack.push("OrderPage.qml", { "employeePhone": employeePage.pendingPhone })
            }
            else if (employeePage.currentAction === "CHECK_OUT") {
                // Chuyển về màn hình Đăng nhập
                // Ưu tiên dùng hàm switchPage tối ưu nếu có ở file main, ngược lại dùng replace
                if (typeof appWindow !== "undefined" && typeof appWindow.switchPage === "function") {
                    appWindow.switchPage("LoginPage.qml")
                } else {
                    navStack.replace("LoginPage.qml")
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#F0F9FF"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "☕ CA LÀM VIỆC NHÂN VIÊN"
                font.pixelSize: 26
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

            // HÀNG NÚT BẤM CHECK-IN / CHECK-OUT
            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                // Nút Check-in
                Button {
                    id: btnCheckIn
                    implicitWidth: 185
                    implicitHeight: 48

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

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
                        statusText.visible = false // Ẩn thông báo cũ khi mở lại
                        confirmDialog.open()
                    }
                }

                // Nút Check-out
                Button {
                    id: btnCheckOut
                    implicitWidth: 185
                    implicitHeight: 48

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

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
                        statusText.visible = false // Ẩn thông báo cũ khi mở lại
                        confirmDialog.open()
                    }
                }
            }

            // Dòng hiển thị trạng thái điểm danh
            Text {
                id: statusText
                text: ""
                font.bold: true
                font.pixelSize: 16
                visible: false // Ẩn mặc định
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
            }
        }
    }

    // ==========================================
    // BẢNG XÁC NHẬN SỐ ĐIỆN THOẠI (POPUP MODAL)
    // ==========================================
    Popup {
        id: confirmDialog
        width: 360
        height: 270
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
                text: "Nhập SĐT cá nhân để xác thực danh tính:"
                font.pixelSize: 13
                color: "#64748B"
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: txtConfirmPhone
                placeholderText: "Nhập số điện thoại nhân viên..."
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                font.pixelSize: 15
                horizontalAlignment: TextInput.AlignHCenter
                color: "#1E293B"
                background: Rectangle {
                    radius: 8
                    border.color: "#93C5FD"
                    border.width: 1
                    color: "#F8FAFC"
                }

                // Hỗ trợ bấm Enter để nộp
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

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

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

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

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
                            lblDialogError.text = "Vui lòng nhập số điện thoại!"
                            lblDialogError.visible = true
                            return
                        }

                        // 1. Truy xuất danh sách để xác minh và lấy Tên nhân viên
                        var isValid = false;
                        var employeeName = "";
                        var phoneToRecord = inputStr;

                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
                            var list = coffeeSystem.loadEmployees()
                            for (var i = 0; i < list.length; i++) {
                                // Kiểm tra trùng khớp theo SĐT hoặc Mã ID đều được
                                if (list[i].phone === inputStr || list[i].id === inputStr) {
                                    isValid = true;
                                    employeeName = list[i].name;
                                    phoneToRecord = list[i].phone; // Đảm bảo ghi nhận bằng SĐT chuẩn
                                    break;
                                }
                            }
                        }

                        // Fallback kiểm tra qua hàm C++ nếu cần
                        if (!isValid) {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.verifyEmployeePhone) {
                                isValid = coffeeSystem.verifyEmployeePhone(inputStr)
                            } else if (typeof cppEmployeeModel !== "undefined" && cppEmployeeModel.verifyEmployeePhone) {
                                isValid = cppEmployeeModel.verifyEmployeePhone(inputStr)
                            }
                        }

                        // 2. Báo lỗi nếu SĐT/Mã không đúng trong file employees.csv
                        if (!isValid) {
                            lblDialogError.text = "Thông tin chưa được gán bởi Quản lý!"
                            lblDialogError.visible = true
                            return
                        }

                        // 3. Đúng thông tin -> Ghi nhận thời gian và hiển thị thông báo
                        var currentTime = Qt.formatDateTime(new Date(), "hh:mm dd/MM/yyyy")
                        var displayName = employeeName !== "" ? employeeName : ("SĐT " + phoneToRecord)

                        confirmDialog.close()

                        if (employeePage.currentAction === "CHECK_IN") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_IN", currentTime)
                            }
                            statusText.text = "🟢 Nhân viên " + displayName + " đã Check-In lúc " + currentTime
                            statusText.color = "#15803D"
                        }
                        else if (employeePage.currentAction === "CHECK_OUT") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phoneToRecord, "CHECK_OUT", currentTime)
                            }
                            statusText.text = "🔴 Nhân viên " + displayName + " đã Check-Out lúc " + currentTime
                            statusText.color = "#B91C1C"
                        }

                        statusText.visible = true

                        // 4. Bật bộ đếm Timer để chờ người dùng đọc thông báo rồi mới điều hướng
                        employeePage.pendingPhone = phoneToRecord
                        delayNavigationTimer.start()
                    }
                }
            }
        }
    }
}