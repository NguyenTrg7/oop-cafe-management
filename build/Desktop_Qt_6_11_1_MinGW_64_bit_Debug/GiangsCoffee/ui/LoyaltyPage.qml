import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: loyaltyPage
    background: Rectangle { color: "#F4EBD0" } // Tông kem nền

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

        // Thiết kế Thẻ Thành Viên (Member Card)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: "#2C1E16" // Màu nâu đen sang trọng
            border.color: "#B68D40" // Viền thẻ vàng đồng
            border.width: 4
            radius: 15

            // Họa tiết mờ trên thẻ (có thể dùng Image nếu có ảnh hoa văn)

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
                        color: "#B68D40" // Chữ vàng đồng
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: "Hạng: BẠC (SILVER)" // Kết nối: customer.rank
                        font.family: "Times New Roman"
                        font.pixelSize: 18
                        color: "#E0E0E0"
                    }
                }

                Item { Layout.fillHeight: true } // Spacer

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
                            text: "Doãn Lê Thành" // Kết nối: customer.name
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
                            text: "150 Pts" // Kết nối: customer.loyaltyPoints
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
                Label { text: "Bạc"; font.family: "Times New Roman"; color: "#4E3629"}
                Item { Layout.fillWidth: true }
                Label { text: "Vàng (Cần thêm 50 Pts)"; font.family: "Times New Roman"; color: "#4E3629" }
            }

            ProgressBar {
                Layout.fillWidth: true
                value: 0.75 // 150/200 điểm
                background: Rectangle {
                    color: "#D4C49A"
                    radius: 4
                }
                contentItem: Item {
                    Rectangle {
                        width: parent.width * 0.75
                        height: parent.height
                        color: "#B68D40"
                        radius: 4
                    }
                }
            }
        }

        // Nút quy đổi điểm (Redeem)
        Button {
            text: "Quy đổi điểm lấy Voucher"
            font.family: "Georgia"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 250
            Layout.preferredHeight: 45
            background: Rectangle {
                color: "#4E3629"
                radius: 5
                border.color: "#B68D40"
                border.width: 1
            }
            palette.buttonText: "#F4EBD0"

            // Logic C++: Sẽ gọi hàm customer->redeemPoints(pointsToRedeem)[cite: 2]
        }
    }
}