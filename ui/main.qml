import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 1024
    height: 768
    title: qsTr("Giang's Coffee - Management System")

    // Bảng màu Băng giá Sáng (Bright Ice Theme)
    property color colorBackground: "#F0F9FF" // Trắng pha xanh nhạt
    property color colorPrimary: "#FFFFFF"    // Trắng tinh (Cho Header)
    property color colorSecondary: "#0369A1"  // Xanh dương đậm (Cho chữ tiêu đề)
    property color colorText: "#333333"       // Xám đậm cho chữ thường

    background: Rectangle {
        color: colorBackground
    }

    // Header chung của ứng dụng
    header: ToolBar {
        background: Rectangle {
            color: colorPrimary
            // Viền mỏng màu xanh nhạt phân cách header với nội dung
            Rectangle {
                width: parent.width
                height: 1
                color: "#E0F2FE"
                anchors.bottom: parent.bottom
            }
        }
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("◀ Trở lại")
                font.family: "Segoe UI"
                font.pixelSize: 16
                font.bold: true
                palette.buttonText: colorSecondary
                visible: stackView.depth > 1
                onClicked: stackView.pop()
            }
            Label {
                text: "Giang's Coffee"
                font.family: "Segoe UI"
                font.pixelSize: 24
                font.bold: true
                color: colorSecondary // Chữ tiêu đề màu xanh dương cho nổi bật trên nền trắng
                horizontalAlignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }

    // Trình quản lý luồng các trang
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "qrc:/qt/qml/GiangsCoffee/ui/LoginPage.qml"
    }

    // Component Trang chủ tạm thời
    Component {
        id: homePage
        Page {
            background: Rectangle { color: colorBackground }
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Label {
                    text: "Chào mừng đến với không gian sáng sủa!"
                    font.family: "Segoe UI"
                    font.pixelSize: 28
                    color: colorText
                }
            }
        }
    }
}