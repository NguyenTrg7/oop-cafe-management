import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    modal: true
    width: 620
    height: 680
    anchors.centerIn: parent
    padding: 0

    property string invoiceNumber: ""
    property string invoiceDate: ""
    property string invoiceTime: ""
    property string customerName: "Khách vãng lai"
    property double totalAmount: 0
    property double discount: 0
    property string voucherCode: ""
    property var items: []

    property bool showFinishButton: true

    signal finished()
    signal closed()

    function formatVND(value) {
        value = Math.round(Number(value) || 0)
        return Qt.locale("vi_VN").toString(value) + " VNĐ"
    }

    function getImagePath(itemName, category) {
            if (!itemName)
                return "";

            var fileName = itemName.toLowerCase()
                                   .normalize("NFD")
                                   .replace(/[\u0300-\u036f]/g, "")
                                   .replace(/[đĐ]/g, "d")
                                   .replace(/\s+/g, "_")
                                   .replace(/[^a-z0-9_]/g, "");

            var folder = category === "Food" ? "Food" : "Drink";

            // Ưu tiên dùng đường dẫn từ main.cpp
            if (typeof savesDirUrl !== "undefined" && savesDirUrl) {
                return savesDirUrl + folder + "/" + fileName + ".png";
            }

            // Fallback (nếu chưa sửa main)
            var appDir = (typeof applicationDir !== "undefined" && applicationDir) ? applicationDir : "";
            appDir = appDir.replace(/\\/g, "/");
            if (appDir.length > 0 && !appDir.endsWith("/"))
                appDir += "/";

            return "file:///" + appDir + "saves/" + folder + "/" + fileName + ".png";
        }

    function openWith(data) {
        invoiceNumber = data.invoiceNumber || ""
        invoiceDate   = data.date || data.invoiceDate || ""
        invoiceTime   = data.time || data.invoiceTime || ""
        customerName  = data.customerName || "Khách vãng lai"
        totalAmount   = data.totalAmount || 0
        discount      = data.discount || 0
        voucherCode   = data.voucherCode || ""
        items         = data.items || []
        open()
    }

    background: Rectangle {
        color: "#FFFDF9"
        radius: 18
        border.color: "#D8C4B6"
        border.width: 1
    }

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        ColumnLayout {
            width: scroll.availableWidth - 10
            spacing: 15

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 20
                spacing: 4

                Text {
                    text: "☕ GIANG'S COFFEE"
                    font.pixelSize: 26
                    font.bold: true
                    color: "#6F4E37"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: showFinishButton ? "Thank you for your order ❤️" : "Hóa đơn đã thanh toán"
                    color: "#888888"
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                implicitHeight: showFinishButton ? 80 : 100
                radius: 10
                color: "#F9F5EF"
                border.color: "#E6D8C8"

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: "🧾  Mã hóa đơn:  " + root.invoiceNumber
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: "📅  Ngày: " + root.invoiceDate
                        font.pixelSize: 12
                    }
                    Text {
                        text: "🕒  Giờ: " + root.invoiceTime
                        font.pixelSize: 12
                    }
                    Text {
                        visible: !showFinishButton
                        text: "👤  Khách hàng: " + root.customerName
                        font.pixelSize: 12
                    }
                }
            }

            Text {
                text: "CHI TIẾT ĐƠN HÀNG"
                font.bold: true
                font.pixelSize: 15
                color: "#6F4E37"
                Layout.alignment: Qt.AlignHCenter
            }

            ListView {
                id: itemList
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                implicitHeight: contentHeight
                interactive: false
                spacing: 8
                model: root.items

                delegate: Rectangle {
                    width: itemList.width
                    implicitHeight: columnItem.implicitHeight + 20
                    radius: 10
                    color: "#FCFAF6"
                    border.color: "#E7DBCF"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Image {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectCrop
                            clip: true
                            source: getImagePath(modelData.name, modelData.category || "Drink")

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#E0E0E0"
                                radius: 6
                            }
                        }

                        ColumnLayout {
                            id: columnItem
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: (modelData.name || "") + (modelData.size ? " (" + modelData.size + ")" : "")
                                font.bold: true
                                font.pixelSize: 13
                                color: "#2C1D11"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "SL: " + (modelData.quantity || 1)
                                font.pixelSize: 11
                                color: "#666666"
                            }

                            Text {
                                visible: modelData.ice && modelData.ice !== "" && modelData.ice !== "Bình thường"
                                text: "🧊 " + modelData.ice
                                font.pixelSize: 11
                                color: "#0277BD"
                            }
                            Text {
                                visible: modelData.toppings && modelData.toppings !== "" && modelData.toppings !== "undefined"
                                text: "🍒 " + modelData.toppings
                                font.pixelSize: 11
                                color: "#6A1B9A"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: modelData.note && modelData.note !== ""
                                text: "📝 " + modelData.note
                                color: "#888888"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: formatVND(modelData.totalPrice)
                            font.bold: true
                            font.pixelSize: 13
                            color: "#8B5A2B"
                            Layout.alignment: Qt.AlignTop
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                visible: root.discount > 0
                text: "Voucher " + root.voucherCode + ":  -" + formatVND(root.discount)
                font.pixelSize: 13
                font.bold: true
                color: "#2E7D32"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                radius: 12
                color: "#FFF7ED"
                border.color: "#F2D9B6"
                implicitHeight: 55

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    Text {
                        text: "💰 Tổng thanh toán"
                        font.bold: true
                        font.pixelSize: 15
                        color: "#6F4E37"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: formatVND(root.totalAmount)
                        font.bold: true
                        font.pixelSize: 20
                        color: "#B45309"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                implicitHeight: 140
                radius: 14
                color: "#FAF8F4"
                border.color: "#E6D8C8"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 15

                    Image {
                        Layout.preferredWidth: 115
                        Layout.preferredHeight: 115
                        fillMode: Image.PreserveAspectFit
                        source: "file:///" + applicationDir + "/saves/ma_qr.jpg"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 6

                        Text {
                            text: "Quét mã QR để thanh toán"
                            font.pixelSize: 15
                            font.bold: true
                            color: "#6F4E37"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Sử dụng app ngân hàng hoặc ví điện tử để quét mã."
                            font.pixelSize: 12
                            color: "#666666"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Cảm ơn Quý khách! ❤️"
                            font.pixelSize: 12
                            font.italic: true
                            color: "#8B5A2B"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.bottomMargin: 20
                spacing: 12

                Item { Layout.fillWidth: true }

                Button {
                    text: "Đóng"
                    implicitWidth: 110
                    implicitHeight: 40
                    onClicked: {
                        root.close()
                        root.closed()
                    }
                }

                Button {
                    visible: root.showFinishButton
                    text: "In Hóa Đơn"
                    implicitWidth: 170
                    implicitHeight: 40
                    highlighted: true
                    onClicked: {
                        root.finished()
                        root.close()
                    }
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
        NumberAnimation { property: "scale"; from: 0.92; to: 1.0; duration: 180 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
        NumberAnimation { property: "scale"; from: 1; to: 0.92; duration: 150 }
    }

    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.92
}