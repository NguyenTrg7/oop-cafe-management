import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 1024
    height: 768
    title: qsTr("Giang's Coffee - Management System")

    // Bảng màu Cổ điển (Vintage Palette)
    property color colorBackground: "#F4EBD0" // Màu kem giấy cũ
    property color colorPrimary: "#4E3629"   // Nâu hạt cà phê
    property color colorSecondary: "#B68D40" // Vàng đồng cổ
    property color colorText: "#3E2723"      // Nâu đen chữ

    background: Rectangle {
        color: colorBackground
    }

    // Header chung của ứng dụng
    header: ToolBar {
        background: Rectangle {
            color: colorPrimary
        }
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("◀ Trở lại")
                font.family: "Times New Roman"
                font.pixelSize: 16
                palette.buttonText: colorBackground
                visible: stackView.depth > 1
                onClicked: stackView.pop()
            }
            Label {
                text: "Giang's Coffee"
                font.family: "Georgia" // Font có chân cổ điển
                font.pixelSize: 24
                font.bold: true
                color: colorSecondary
                horizontalAlignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }

    // Trình quản lý luồng các trang (7-8 pages sẽ được nạp vào đây)
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePage // Khởi tạo với Trang chủ
    }

    // Định nghĩa tạm Trang chủ (Customer Home) để test
    Component {
        id: homePage
        Page {
            background: Rectangle { color: colorBackground }
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Label {
                    text: "Chào mừng đến với không gian hoài niệm"
                    font.family: "Georgia"
                    font.pixelSize: 28
                    color: colorText
                }

                Button {
                    text: "Vào Trang Đơn Hàng"
                    font.family: "Times New Roman"
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle {
                        color: colorSecondary
                        radius: 5
                    }
                    // TODO: Thêm logic on clicked push trang đơn hàng vào StackView
                }
            }
        }
    }
}