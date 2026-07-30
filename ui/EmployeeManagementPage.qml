import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: empPage
    title: "Quản Lý Nhân Viên"

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
        txtPhone.text = ""
        txtSalary.text = ""
        cboShift.currentIndex = 0
        txtId.readOnly = false
        isEditing = false
        lblError.text = ""
    }

    // Hàm xác thực số điện thoại
    function validatePhone(phone) {
        var phoneRegex = /^0\d{9}$/;
        return phoneRegex.test(phone.trim());
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
        // 2. KHUNG NHẬP LIỆU (Có thêm ô nhập SĐT)
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 75
            color: "#F9F6F0"
            radius: 8
            border.color: "#E0E0E0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    TextField {
                        id: txtId
                        placeholderText: "Mã NV"
                        Layout.preferredWidth: 80
                    }
                    TextField {
                        id: txtName
                        placeholderText: "Họ và tên"
                        Layout.fillWidth: true
                    }
                    TextField {
                        id: txtPhone
                        placeholderText: "Số điện thoại"
                        Layout.preferredWidth: 120
                        inputMethodHints: Qt.ImhDialableCharactersOnly
                    }
                    TextField {
                        id: txtSalary
                        placeholderText: "Lương/h"
                        Layout.preferredWidth: 90
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                    ComboBox {
                        id: cboShift
                        model: ["Sáng", "Chiều", "Tối"]
                        Layout.preferredWidth: 80
                    }

                    // Nút Thêm hoặc Lưu cập nhật
                    Button {
                        text: isEditing ? "💾 Lưu" : "➕ Thêm"
                        highlighted: true
                        onClicked: {
                            if (txtId.text.trim() === "" || txtName.text.trim() === "") {
                                lblError.text = "⚠️ Mã NV và Họ tên không được để trống!";
                                return;
                            }

                            // Xác thực số điện thoại
                            if (!validatePhone(txtPhone.text)) {
                                lblError.text = "⚠️ Số điện thoại không hợp lệ! (Phải đủ 10 số, bắt đầu bằng 0)";
                                return;
                            }

                            lblError.text = "";
                            var salaryVal = parseFloat(txtSalary.text) || 0;

                            if (isEditing) {
                                if (coffeeSystem.updateEmployeeCSV) {
                                    coffeeSystem.updateEmployeeCSV(txtId.text, txtName.text, txtPhone.text.trim(), salaryVal, cboShift.currentText)
                                }
                            } else {
                                if (coffeeSystem.addEmployeeCSV) {
                                    coffeeSystem.addEmployeeCSV(txtId.text, txtName.text, txtPhone.text.trim(), salaryVal, cboShift.currentText)
                                }
                            }

                            refreshData()
                            clearForm()
                        }
                    }

                    // Nút Làm mới form
                    Button {
                        text: "🧹"
                        visible: isEditing || txtId.text !== ""
                        onClicked: clearForm()
                    }
                }

                // Dòng hiển thị thông báo lỗi xác thực
                Text {
                    id: lblError
                    text: ""
                    color: "#D32F2F"
                    font.pixelSize: 12
                    font.bold: true
                    visible: text !== ""
                }
            }
        }

        // ---------------------------------------------------------------------
        // 3. BẢNG HIỂN THỊ DANH SÁCH (Có thêm cột SĐT)
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

                    Text { text: model.id; font.bold: true; Layout.preferredWidth: 70 }
                    Text { text: model.name; Layout.fillWidth: true }
                    Text { text: model.phone ? model.phone : "Chưa có"; Layout.preferredWidth: 110; color: "#2E7D32" }

                    Text {
                        text: Number(model.salary).toLocaleString(Qt.locale("vi_VN")) + " VNĐ/h"
                        Layout.preferredWidth: 100
                    }

                    Text { text: "Ca: " + model.shift; Layout.preferredWidth: 70 }

                    // Cột Nút bấm Thao tác: Chỉ còn Sửa & Xóa
                    RowLayout {
                        Layout.preferredWidth: 80
                        spacing: 5

                        // Nút Sửa
                        Button {
                            text: "✏️"
                            implicitWidth: 36
                            onClicked: {
                                txtId.text = model.id
                                txtName.text = model.name
                                txtPhone.text = model.phone || ""
                                txtSalary.text = model.salary

                                var shiftIdx = cboShift.model.indexOf(model.shift)
                                cboShift.currentIndex = shiftIdx >= 0 ? shiftIdx : 0

                                txtId.readOnly = true
                                isEditing = true
                                lblError.text = ""
                            }
                        }

                        // Nút Xóa
                        Button {
                            text: "🗑️"
                            implicitWidth: 36
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
}