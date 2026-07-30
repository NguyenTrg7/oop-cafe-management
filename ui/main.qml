import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1180
    height: 760
    minimumWidth: 1024
    minimumHeight: 700
    title: qsTr("Giang's Coffee - Management System")

    property color colorBackground: "#F8FAFC"
    property color colorPrimary: "#FFFFFF"
    property color colorSecondary: "#0284C7"
    property color colorText: "#1E293B"

    background: Rectangle { color: colorBackground }

    // Header hiển thị khi đã vào bên trong các trang con
    header: ToolBar {
        visible: stackView.depth > 1
        implicitHeight: 52
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

            ToolButton {
                text: qsTr("◀ Trở lại")
                font.pixelSize: 14
                font.bold: true
                palette.buttonText: colorSecondary
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    stackView.pop()
                    if (stackView.depth === 1 && typeof accountHandler !== "undefined") {
                        accountHandler.setCurrentUserPhone("")
                    }
                }
            }

            Label {
                text: "☕ GIANG'S COFFEE SYSTEM"
                font.pixelSize: 18
                font.bold: true
                color: "#0369A1"
                anchors.centerIn: parent
            }

            Label {
                text: "📱 SĐT: " + (typeof accountHandler !== "undefined" ? accountHandler.currentUserPhone : "")
                font.pixelSize: 14
                font.bold: true
                color: "#0284C7"
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                visible: typeof accountHandler !== "undefined" && accountHandler.currentUserPhone !== "" && accountHandler.currentUserPhone !== "admin"
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "LoginPage.qml"
    }
}