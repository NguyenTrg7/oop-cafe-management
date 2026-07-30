import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: employeePage
    title: "Trang Nhân Viên"

    property string currentAction: "" // Trạng thái: "CHECK_IN" hoặc "CHECK_OUT"

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
                        confirmDialog.open()
                    }
                }
            }

            // Dòng hiển thị trạng thái điểm danh
            Text {
                id: statusText
                text: ""
                font.bold: true
                font.pixelSize: 14
                visible: text !== ""
                Layout.alignment: Qt.AlignHCenter
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
                        var phone = txtConfirmPhone.text.trim()

                        // 1. Truy xuất hàm verifyEmployeePhone từ C++
                        var isValid = false;
                        if (typeof coffeeSystem !== "undefined" && coffeeSystem.verifyEmployeePhone) {
                            isValid = coffeeSystem.verifyEmployeePhone(phone)
                        } else if (typeof cppEmployeeModel !== "undefined" && cppEmployeeModel.verifyEmployeePhone) {
                            isValid = cppEmployeeModel.verifyEmployeePhone(phone)
                        } else if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
                            var list = coffeeSystem.loadEmployees()
                            for (var i = 0; i < list.length; i++) {
                                if (list[i].phone === phone) {
                                    isValid = true;
                                    break;
                                }
                            }
                        }

                        // 2. Báo lỗi nếu SĐT không đúng trong file employees.csv
                        if (!isValid) {
                            lblDialogError.text = "SĐT chưa được gán thông tin Nhân viên bởi Manager!"
                            lblDialogError.visible = true
                            return
                        }

                        // 3. Đúng SĐT -> Ghi nhận thời gian và điều hướng
                        var currentTime = Qt.formatDateTime(new Date(), "hh:mm dd/MM/yyyy")
                        confirmDialog.close()

                        // Lấy con trỏ StackView điều hướng
                        var navStack = StackView.view || (typeof stackView !== "undefined" ? stackView : null)

                        if (employeePage.currentAction === "CHECK_IN") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phone, "CHECK_IN", currentTime)
                            }

                            statusText.text = "SĐT " + phone + " đã Check-In thành công lúc " + currentTime
                            statusText.color = "#15803D"
                            statusText.visible = true

                            // Chuyển sang OrderPage.qml và truyền kèm SĐT nhân viên
                            if (navStack) {
                                navStack.push("OrderPage.qml", { "employeePhone": phone })
                            } else {
                                console.log("Lỗi: Không tìm thấy StackView để điều hướng!")
                            }
                        }
                        else if (employeePage.currentAction === "CHECK_OUT") {
                            if (typeof coffeeSystem !== "undefined" && coffeeSystem.recordAttendanceCSV) {
                                coffeeSystem.recordAttendanceCSV(phone, "CHECK_OUT", currentTime)
                            }

                            statusText.text = "SĐT " + phone + " đã Check-Out thành công lúc " + currentTime
                            statusText.color = "#B91C1C"
                            statusText.visible = true

                            // Chuyển về màn hình Đăng nhập
                            if (navStack) {
                                navStack.replace("LoginPage.qml")
                            } else {
                                console.log("Lỗi: Không tìm thấy StackView để điều hướng!")
                            }
                        }
                    }
                }
            }
        }
    }
}