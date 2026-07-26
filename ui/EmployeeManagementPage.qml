import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: empPage
    title: "Quản Lý Nhân Viên"

    // Biến đánh dấu trạng thái đang "Thêm mới" hay "Cập nhật"
    property bool isEditing: false

    ListModel { id: empModel }

    Component.onCompleted: refreshData()

    function refreshData() {
        empModel.clear()
        if (typeof coffeeSystem !== "undefined" && coffeeSystem.loadEmployees) {
            var data = coffeeSystem.loadEmployees()
            for (var i = 0; i < data.length; i++) {
                empModel.append(data[i])
            }
        }
    }

    function clearForm() {
        txtId.text = ""
        txtName.text = ""
        cboPos.currentIndex = 0
        txtSalary.text = ""
        cboShift.currentIndex = 0
        txtId.readOnly = false
        isEditing = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // ---------------------------------------------------------------------
        // 1. TIÊU ĐỀ
        // ---------------------------------------------------------------------
        Text {
            text: "DANH SÁCH NHÂN VIÊN GIANG COFFEE"
            font.bold: true
            font.pixelSize: 20
            color: "#6F4E37"
        }

        // ---------------------------------------------------------------------
        // 2. KHUNG NHẬP LIỆU
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 65
            color: "#F9F6F0"
            radius: 8
            border.color: "#E0E0E0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TextField {
                    id: txtId
                    placeholderText: "Mã NV"
                    Layout.preferredWidth: 90
                }
                TextField {
                    id: txtName
                    placeholderText: "Họ và tên"
                    Layout.fillWidth: true
                }
                ComboBox {
                    id: cboPos
                    model: ["Pha chế", "Thu ngân", "Phục vụ", "Quản lý"]
                    Layout.preferredWidth: 120
                }
                TextField {
                    id: txtSalary
                    placeholderText: "Lương/h"
                    Layout.preferredWidth: 100
                    inputMethodHints: Qt.ImhDigitsOnly
                }
                ComboBox {
                    id: cboShift
                    model: ["Sáng", "Chiều", "Tối"]
                    Layout.preferredWidth: 90
                }

                // Nút Thêm hoặc Lưu cập nhật
                Button {
                    text: isEditing ? "💾 Lưu" : "➕ Thêm"
                    highlighted: true
                    onClicked: {
                        if (txtId.text === "" || txtName.text === "") return;

                        var salaryVal = parseFloat(txtSalary.text) || 0;

                        if (isEditing) {
                            if (coffeeSystem.updateEmployeeCSV) {
                                coffeeSystem.updateEmployeeCSV(txtId.text, txtName.text, cboPos.currentText, salaryVal, cboShift.currentText)
                            }
                        } else {
                            if (coffeeSystem.addEmployeeCSV) {
                                coffeeSystem.addEmployeeCSV(txtId.text, txtName.text, cboPos.currentText, salaryVal, cboShift.currentText)
                            }
                        }

                        refreshData()
                        clearForm()
                    }
                }

                // Nút Hủy/Làm mới form
                Button {
                    text: "🧹"
                    visible: isEditing || txtId.text !== ""
                    onClicked: clearForm()
                }
            }
        }

        // ---------------------------------------------------------------------
        // 3. BẢNG HIỂN THỊ DANH SÁCH
        // ---------------------------------------------------------------------
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: empModel
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: index % 2 === 0 ? "#F9F6F0" : "#FFFFFF"
                border.color: "#E0E0E0"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text { text: model.id; font.bold: true; Layout.preferredWidth: 80 }
                    Text { text: model.name; Layout.fillWidth: true }
                    Text { text: model.position; Layout.preferredWidth: 110 }

                    Text {
                        text: Number(model.salary).toLocaleString(Qt.locale("vi_VN")) + " VNĐ/h"
                        Layout.preferredWidth: 110
                    }

                    Text { text: "Ca: " + model.shift; Layout.preferredWidth: 80 }

                    // Cột Nút bấm Thao tác: Sửa, Cấp Tài Khoản & Xóa
                    RowLayout {
                        Layout.preferredWidth: 130 // Mở rộng chiều rộng để chứa 3 nút
                        spacing: 5

                        // Nút Sửa
                        Button {
                            text: "✏️"
                            implicitWidth: 38
                            onClicked: {
                                txtId.text = model.id
                                txtName.text = model.name

                                var posIdx = cboPos.model.indexOf(model.position)
                                cboPos.currentIndex = posIdx >= 0 ? posIdx : 0

                                txtSalary.text = model.salary

                                var shiftIdx = cboShift.model.indexOf(model.shift)
                                cboShift.currentIndex = shiftIdx >= 0 ? shiftIdx : 0

                                txtId.readOnly = true
                                isEditing = true
                            }
                        }

                        // 🔑 Nút Cấp Tài Khoản Mới
                        Button {
                            text: "🔑"
                            implicitWidth: 38
                            onClicked: {
                                grantAccDialog.targetEmpId = model.id
                                dlgPass.text = ""
                                grantAccDialog.open()
                            }
                        }

                        // Nút Xóa
                        Button {
                            text: "🗑️"
                            implicitWidth: 38
                            onClicked: {
                                if (coffeeSystem.deleteEmployeeCSV) {
                                    coffeeSystem.deleteEmployeeCSV(model.id)
                                }
                                refreshData()
                                if (txtId.text === model.id) clearForm()
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------------
    // 4. DIALOG CẤP TÀI KHOẢN (POPUP)
    // ---------------------------------------------------------------------
    Dialog {
        id: grantAccDialog
        title: "🔑 Cấp Tài Khoản Nhân Viên"
        modal: true
        focus: true
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 320

        property string targetEmpId: ""

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: "Mã NV nhận TK: " + grantAccDialog.targetEmpId
                font.bold: true
                color: "#6F4E37"
            }

            TextField {
                id: dlgPass
                placeholderText: "Mật khẩu cấp cho NV"
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Button {
                    text: "Hủy"
                    onClicked: grantAccDialog.close()
                }

                Button {
                    text: "Cấp Tài Khoản"
                    highlighted: true
                    onClicked: {
                        if (dlgPass.text !== "") {
                            if (typeof accountHandler !== "undefined" && accountHandler.addAccount) {
                                // Mặc định Username = Mã NV, Role = "Nhân viên"
                                accountHandler.addAccount(grantAccDialog.targetEmpId, dlgPass.text, "Nhân viên")
                            }
                            grantAccDialog.close()
                            dlgPass.text = ""
                        }
                    }
                }
            }
        }
    }
}