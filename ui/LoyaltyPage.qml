import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: loyaltyPage
    background: Rectangle { color: "#F4EBD0" }

    property var customer: typeof customerHandler !== "undefined" ? customerHandler : null

    ScrollView {
        id: scroll
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: Math.min(scroll.availableWidth, 520)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 18

            Label {
                text: "Tích điểm & Voucher"
                font.family: "Georgia"
                font.pixelSize: 26
                font.bold: true
                color: "#4E3629"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#2C1E16"
                border.color: "#B68D40"
                border.width: 3
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 4

                    Label {
                        text: customer ? customer.name : "Chưa đăng nhập"
                        font.pixelSize: 17
                        color: "white"
                    }
                    Label {
                        text: (customer ? customer.loyaltyPoints : 0) + " điểm"
                        font.pixelSize: 26
                        font.bold: true
                        color: "#B68D40"
                    }
                    Label {
                        text: "Đồ uống: S=1 M=2 L=3 | Đồ ăn: 2 điểm/món"
                        font.pixelSize: 11
                        color: "#A1887F"
                    }
                }
            }

            Label {
                text: "Đổi điểm lấy voucher"
                font.bold: true
                font.pixelSize: 15
                color: "#4E3629"
            }

            Repeater {
                model: customer ? customer.voucherTiers() : []

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: "#FFF8E7"
                    border.color: "#B68D40"
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8

                        Label {
                            text: modelData.label + " (" + modelData.points + " điểm)"
                            font.pixelSize: 13
                            color: "#4E3629"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Đổi"
                            enabled: customer && customer.loyaltyPoints >= modelData.points
                            onClicked: {
                                var r = customer.redeemVoucher(modelData.points)
                                msgDialog.text = r.message || ""
                                msgDialog.open()
                                if (r.success && typeof accountHandler !== "undefined")
                                    accountHandler.saveCustomerLoyalty()
                            }
                        }
                    }
                }
            }

            Label {
                text: "Voucher đang có"
                font.bold: true
                font.pixelSize: 15
                color: "#4E3629"
                Layout.topMargin: 8
            }

            Repeater {
                model: customer ? customer.activeVouchers : []

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    color: "#E8F5E9"
                    border.color: "#2E7D32"
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        Label {
                            text: modelData.code + "  —  " + modelData.label
                            font.pixelSize: 13
                            font.bold: true
                            color: "#1B5E20"
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "Chưa dùng"
                            font.pixelSize: 11
                            color: "#558B2F"
                        }
                    }
                }
            }

            Label {
                visible: customer && customer.activeVouchers.length === 0
                text: "Chưa có voucher nào. Hãy đổi điểm ở trên."
                font.pixelSize: 12
                color: "#8D6E63"
            }

            // Khoang trong cuoi de cuon thoai mai
            Item { Layout.preferredHeight: 24 }
        }
    }

    Dialog {
        id: msgDialog
        property alias text: msgLabel.text
        title: "Thông báo"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        Label {
            id: msgLabel
            wrapMode: Text.WordWrap
            width: 300
        }
    }
}