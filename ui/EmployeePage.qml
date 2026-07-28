import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: employeePage
    title: "Trang Nhân Viên"

    Rectangle {
        anchors.fill: parent
        color: "#F0F9FF"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "☕ CA LÀM VIỆC NHÂN VIÊN"
                font.pixelSize: 24
                font.bold: true
                color: "#0369A1"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Xin chào tài khoản SĐT: " + accountHandler.currentUserPhone
                font.pixelSize: 16
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "🟢 CHECK-IN CA LÀM"
                    implicitWidth: 160
                    implicitHeight: 50
                    onClicked: {
                        var currentTime = Qt.formatDateTime(new Date(), "hh:mm dd/MM")
                        var status = "Đã Check-In (" + currentTime + ")"
                        var ok = cppEmployeeModel.checkInCheckOut(accountHandler.currentUserPhone, status)
                        if (ok) {
                            statusText.text = "Bạn đã Check-In thành công lúc " + currentTime
                            statusText.color = "#15803D"
                        } else {
                            statusText.text = "SĐT chưa được gán thông tin Nhân viên bởi Manager!"
                            statusText.color = "#B91C1C"
                        }
                        statusText.visible = true
                    }
                }

                Button {
                    text: "🔴 CHECK-OUT CA LÀM"
                    implicitWidth: 160
                    implicitHeight: 50
                    onClicked: {
                        var currentTime = Qt.formatDateTime(new Date(), "hh:mm dd/MM")
                        var status = "Đã Check-Out (" + currentTime + ")"
                        var ok = cppEmployeeModel.checkInCheckOut(accountHandler.currentUserPhone, status)
                        if (ok) {
                            statusText.text = "Bạn đã Check-Out thành công lúc " + currentTime
                            statusText.color = "#B91C1C"
                        } else {
                            statusText.text = "SĐT chưa được gán thông tin Nhân viên bởi Manager!"
                            statusText.color = "#B91C1C"
                        }
                        statusText.visible = true
                    }
                }
            }

            Text {
                id: statusText
                text: ""
                font.bold: true
                font.pixelSize: 15
                visible: false
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}