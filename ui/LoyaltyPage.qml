import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: loyaltyPage
    background: Rectangle { color: "#F8FAFC" }

    property var customer: typeof customerHandler !== "undefined" ? customerHandler : null
    property string currentPhone: ""

    ListModel {
        id: activeVoucherModel
    }

    function loadCustomerByPhone() {
        var phone = searchPhone.text.trim()
        if (!/^0\d{9}$/.test(phone)) {
            currentPhone = ""
            activeVoucherModel.clear()
            return
        }

        currentPhone = phone

        if (customer) {
            customer.loadByPhone(phone)
            refreshActiveVouchers()
        }
    }

    function refreshActiveVouchers() {
        activeVoucherModel.clear()

        if (!customer) {
            console.log("refreshActiveVouchers: customer is null")
            return
        }

        var list = customer.activeVouchers
        console.log("Số lượng voucher đang có:", list.length)

        for (var i = 0; i < list.length; i++) {
            var v = list[i]
            console.log("Voucher", i, ":", v.code, v.label)

            activeVoucherModel.append({
                "code": v.code || "",
                "label": v.label || ("Giảm " + (v.percent || 0) + "%"),
                "percent": v.percent || 0,
                "pointsSpent": v.pointsSpent || 0
            })
        }

        console.log("activeVoucherModel.count =", activeVoucherModel.count)
    }

    ScrollView {
        id: scroll
        anchors.fill: parent
        anchors.margins: 24
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        // FIX: ColumnLayout is now the direct child of ScrollView instead of being
        // wrapped in an Item with a manually-bound height. That manual
        // "height: contentColumn.implicitHeight" binding on the wrapper Item
        // wasn't reliably recomputing when the Repeater's item count changed,
        // so the scrollable area never grew enough to show the voucher list.
        ColumnLayout {
            id: contentColumn
            width: Math.min(scroll.availableWidth, 560)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            // ===== HEADER =====
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: "🎁 Tích Điểm & Voucher"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#0369A1"
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: "Nhập số điện thoại để xem điểm và đổi voucher"
                    font.pixelSize: 14
                    color: "#64748B"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // ===== Ô NHẬP SỐ ĐIỆN THOẠI =====
            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 12
                color: "#FFFFFF"
                border.color: "#E2E8F0"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    TextField {
                        id: searchPhone
                        Layout.fillWidth: true
                        placeholderText: "Nhập số điện thoại khách hàng..."
                        inputMethodHints: Qt.ImhDigitsOnly
                        font.pixelSize: 15
                        background: Rectangle {
                            radius: 8
                            color: "#F8FAFC"
                            border.color: searchPhone.activeFocus ? "#0D9488" : "#CBD5E1"
                        }
                        onAccepted: loadCustomerByPhone()
                    }

                    Button {
                        text: "Xem điểm"
                        implicitWidth: 110
                        implicitHeight: 40
                        background: Rectangle {
                            color: parent.pressed ? "#0F766E" : "#0D9488"
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: loadCustomerByPhone()
                    }
                }
            }

            // ===== THẺ ĐIỂM =====
            Rectangle {
                visible: currentPhone !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: 130
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0F766E" }
                    GradientStop { position: 1.0; color: "#0D9488" }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 6

                    Label {
                        text: "SĐT: " + currentPhone
                        font.pixelSize: 16
                        color: "#CCFBF1"
                    }
                    Label {
                        text: (customer ? customer.loyaltyPoints : 0) + " điểm"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#FFFFFF"
                    }
                    Label {
                        text: "Đồ uống: S=1 • M=2 • L=3  |  Đồ ăn: 2 điểm/món"
                        font.pixelSize: 12
                        color: "#99F6E4"
                    }
                }
            }

            // ===== ĐỔI ĐIỂM LẤY VOUCHER =====
            Label {
                visible: currentPhone !== ""
                text: "Đổi điểm lấy voucher"
                font.bold: true
                font.pixelSize: 16
                color: "#1E293B"
            }

            Repeater {
                model: (currentPhone !== "" && customer) ? customer.voucherTiers() : []

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 64
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E2E8F0"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 10
                            color: "#ECFDF5"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.percent + "%"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#059669"
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Label {
                                text: modelData.label
                                font.pixelSize: 15
                                font.bold: true
                                color: "#1E293B"
                            }
                            Label {
                                text: modelData.points + " điểm"
                                font.pixelSize: 12
                                color: "#64748B"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "Đổi ngay"
                            enabled: customer && customer.loyaltyPoints >= modelData.points
                            implicitHeight: 36
                            implicitWidth: 100
                            Layout.alignment: Qt.AlignVCenter

                            background: Rectangle {
                                color: parent.enabled
                                       ? (parent.pressed ? "#0F766E" : "#0D9488")
                                       : "#CBD5E1"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (!customer) return

                                var r = customer.redeemVoucher(modelData.points)
                                msgDialog.text = r.message || ""
                                msgDialog.open()

                                if (r.success) {
                                    customer.save()
                                    refreshActiveVouchers()
                                }
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

            // Bound to activeVoucherModel (kept in sync by refreshActiveVouchers())
            // instead of the raw customer.activeVouchers property.
            Repeater {
                model: activeVoucherModel

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
                            text: model.code + "  —  " + model.label
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
                visible: currentPhone !== "" && activeVoucherModel.count === 0
                text: "Chưa có voucher nào. Hãy đổi điểm ở phía trên."
                font.pixelSize: 13
                color: "#94A3B8"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                visible: currentPhone === ""
                text: "Vui lòng nhập số điện thoại để xem thông tin tích điểm"
                font.pixelSize: 14
                color: "#94A3B8"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 40
            }

            Item { Layout.preferredHeight: 30 }
        }
    }

    Dialog {
        id: msgDialog
        property alias text: msgLabel.text
        title: "Thông báo"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok

        background: Rectangle {
            color: "#FFFFFF"
            radius: 12
            border.color: "#E2E8F0"
        }

        Label {
            id: msgLabel
            wrapMode: Text.WordWrap
            width: 300
            color: "#1E293B"
        }
    }
}