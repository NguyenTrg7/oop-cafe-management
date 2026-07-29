import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: loyaltyPage
    background: Rectangle { color: "#F4EBD0" }

    property var customer: typeof customerHandler !== "undefined" ? customerHandler : null

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        width: Math.min(parent.width * 0.75, 480)

        Label {
            text: "Tich diem & Voucher"
            font.family: "Georgia"
            font.pixelSize: 26
            font.bold: true
            color: "#4E3629"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            color: "#2C1E16"
            border.color: "#B68D40"
            border.width: 3
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                Label {
                    text: customer ? customer.name : "Chua dang nhap"
                    font.pixelSize: 18
                    color: "white"
                }
                Label {
                    text: (customer ? customer.loyaltyPoints : 0) + " diem"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#B68D40"
                }
                Label {
                    text: "Do uong: S=1 M=2 L=3 | Do an: 2 diem/mon"
                    font.pixelSize: 12
                    color: "#A1887F"
                }
            }
        }

        Label {
            text: "Doi voucher"
            font.bold: true
            font.pixelSize: 16
            color: "#4E3629"
        }

        Repeater {
            model: customer ? customer.voucherTiers() : []

            delegate: Rectangle {
                Layout.fillWidth: true
                height: 52
                color: "#FFF8E7"
                border.color: "#B68D40"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Label {
                        text: modelData.label + "  (" + modelData.points + " diem)"
                        font.pixelSize: 14
                        color: "#4E3629"
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Doi"
                        enabled: customer && customer.loyaltyPoints >= modelData.points
                        onClicked: {
                            var r = customer.redeemVoucher(modelData.points)
                            msgDialog.text = r.message || ""
                            msgDialog.open()
                            if (r.success && typeof accountHandler !== "undefined"
                                    && accountHandler.saveCustomerLoyalty)
                                accountHandler.saveCustomerLoyalty()
                        }
                    }
                }
            }
        }

        Label {
            visible: !customer
            text: "Loi: customerHandler chua duoc dang ky trong main.cpp"
            color: "#C62828"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Dialog {
        id: msgDialog
        property alias text: msgLabel.text
        title: "Thong bao"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        Label {
            id: msgLabel
            wrapMode: Text.WordWrap
            width: 280
        }
    }
}