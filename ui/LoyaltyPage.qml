import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: loyaltyPage
    background: Rectangle { color: "#F4EBD0" }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30
        width: parent.width * 0.7

        Label {
            text: "Quyền Lợi Khách Hàng"
            font.family: "Georgia"
            font.pixelSize: 28
            font.bold: true
            color: "#4E3629"
            Layout.alignment: Qt.AlignHCenter
        }

        // Thẻ Thành Viên (Member Card)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: "#2C1E16"
            border.color: "#B68D40"
            border.width: 4
            radius: 15

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Giang's Coffee"
                        font.family: "Georgia"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#B68D40"
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: "Hạng: " + customerHandler.rank
                        font.family: "Times New Roman"
                        font.pixelSize: 18
                        color: "#E0E0E0"
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Label {
                            text: "Khách hàng"
                            font.family: "Times New Roman"
                            font.pixelSize: 14
                            color: "#A1887F"
                        }
                        Label {
                            text: customerHandler.name
                            font.family: "Georgia"
                            font.pixelSize: 22
                            color: "white"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ColumnLayout {
                        Label {
                            text: "Điểm Tích Lũy"
                            font.family: "Times New Roman"
                            font.pixelSize: 14
                            color: "#A1887F"
                            Layout.alignment: Qt.AlignRight
                        }
                        Label {
                            text: customerHandler.loyaltyPoints + " Pts"
                            font.family: "Georgia"
                            font.pixelSize: 26
                            font.bold: true
                            color: "#B68D40"
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }

        // Thanh tiến trình thăng hạng
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Hiện tại: " + customerHandler.loyaltyPoints + " Pts"; font.family: "Times New Roman"; color: "#4E3629"}
                Item { Layout.fillWidth: true }
                Label { text: "Mục tiêu: 500 Pts (Kim Cương)"; font.family: "Times New Roman"; color: "#4E3629" }
            }

            ProgressBar {
                Layout.fillWidth: true
                value: Math.min(customerHandler.loyaltyPoints / 500.0, 1.0)
                background: Rectangle {
                    color: "#D4C49A"
                    radius: 4
                }
                contentItem: Item {
                    Rectangle {
                        width: parent.width * parent.parent.value
                        height: parent.height
                        color: "#B68D40"
                        radius: 4
                    }
                }
            }
        }

        // Nút quy đổi điểm
        Button {
            text: "Quy đổi 50 Pts lấy Voucher"
            font.family: "Georgia"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 260
            Layout.preferredHeight: 45
            background: Rectangle {
                color: customerHandler.loyaltyPoints >= 50 ? "#4E3629" : "#8D6E63"
                radius: 5
                border.color: "#B68D40"
                border.width: 1
            }
            palette.buttonText: "#F4EBD0"

            onClicked: {
                if (customerHandler.redeemPoints(50)) {
                    msgDialog.text = "Đổi Voucher 20.000đ thành công!"
                } else {
                    msgDialog.text = "Bạn không đủ điểm để quy đổi!"
                }
                msgDialog.open()
            }
        }
    }

    Dialog {
        id: msgDialog
        property alias text: msgText.text
        title: "Thông báo"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        Label { id: msgText; font.pixelSize: 15 }
    }
}