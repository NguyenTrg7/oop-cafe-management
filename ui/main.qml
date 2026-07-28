import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1150
    height: 750
    title: qsTr("Giang's Coffee - Management System")

    property color colorBackground: "#F8FAFC"
    property color colorPrimary: "#FFFFFF"
    property color colorSecondary: "#0284C7"
    property color colorText: "#1E293B"

    background: Rectangle { color: colorBackground }

    // Header hiển thị khi depth > 1 (đã vào bên trong app)
    header: ToolBar {
        visible: stackView.depth > 1
        implicitHeight: 50
        background: Rectangle {
            color: colorPrimary
            Rectangle {
                width: parent.width
                height: 1
                color: "#E2E8F0"
                anchors.bottom: parent.bottom
            }
        }

        Item {
            anchors.fill: parent

            // Nút Trở lại nằm bên trái
            ToolButton {
                text: qsTr("◀ Trở lại")
                font.family: "Segoe UI"
                font.pixelSize: 15
                font.bold: true
                palette.buttonText: colorSecondary
                visible: stackView.depth > 1
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    stackView.pop()
                    if (stackView.depth === 1) {
                        accountHandler.setCurrentUserPhone("")
                    }
                }
            }

            // Tiêu đề chính giữa Header
            Label {
                text: "Giang's Coffee"
                font.family: "Segoe UI"
                font.pixelSize: 20
                font.bold: true
                color: colorSecondary
                anchors.centerIn: parent
            }

            // Hiển thị SĐT bên phải
            Label {
                text: "📱 SĐT: " + accountHandler.currentUserPhone
                font.family: "Segoe UI"
                font.pixelSize: 14
                font.bold: true
                color: "#0369A1"
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                visible: accountHandler.currentUserPhone !== "" && accountHandler.currentUserPhone !== "admin" && stackView.depth > 1
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "LoginPage.qml"
    }
}