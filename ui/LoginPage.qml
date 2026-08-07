import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia


Rectangle {
    id: root
    width: parent.width
    height: parent.height
    color: "#000000"

    function syncNavBar() {
        var win = typeof appWindow !== "undefined" ? appWindow : (typeof ApplicationWindow !== "undefined" ? ApplicationWindow.window : null)
        if (win) {
            if (typeof win.setCurrentPage === "function") win.setCurrentPage("LoginPage.qml", "Đăng Nhập")
            else if (typeof win.updateNavigation === "function") win.updateNavigation("LoginPage.qml", "Đăng Nhập")
            if (win.pageTitle !== undefined) win.pageTitle = "Đăng Nhập"
        }
    }

    function getVideoSource() {
        if (typeof savesDir !== "undefined" && savesDir !== "") {
            var base = savesDir.toString().replace(/[\\\/]+$/, "")
            base = base.replace(/[\\\/]saves$/i, "")
            var path = base + "/data/background.mp4"
            path = path.replace(/\\/g, "/")
            console.log("Video path:", "file:///" + path)
            return "file:///" + path
        }
        if (typeof applicationDir !== "undefined" && applicationDir !== "") {
            var p = applicationDir.toString().replace(/\\/g, "/") + "/data/background.mp4"
            return "file:///" + p
        }
        return ""
    }

    StackView.onActivating: {
        syncNavBar()
        clearFields()
        if (typeof accountHandler !== "undefined") {
            accountHandler.setCurrentUserPhone("")
        }
        bgPlayer.source = getVideoSource()
        bgPlayer.play()
    }

    StackView.onDeactivating: {
        bgPlayer.stop()
    }

    Component.onCompleted: {
        syncNavBar()
        bgPlayer.source = getVideoSource()
        bgPlayer.play()
    }
    // Item {
    //     id: snowContainer
    //     anchors.fill: parent
    //     clip: true

    //     Repeater {
    //         model: 40

    //         Rectangle {
    //             id: flake
    //             property real speed: Math.random() * 5000 + 4000
    //             property real initialDelay: Math.random() * 7000

    //             width: Math.random() * 5 + 3
    //             height: width
    //             radius: width / 2
    //             color: "#FFFFFF"
    //             opacity: Math.random() * 0.6 + 0.3
    //             x: Math.random() * root.width
    //             y: -20

    //             SequentialAnimation on y {
    //                 loops: Animation.Infinite
    //                 running: true

    //                 PauseAnimation { duration: flake.initialDelay }

    //                 NumberAnimation {
    //                     from: -20
    //                     to: root.height + 20
    //                     duration: flake.speed
    //                     easing.type: Easing.Linear
    //                 }

    //                 ScriptAction {
    //                     script: {
    //                         flake.initialDelay = 0;
    //                         flake.x = Math.random() * root.width;
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }

    MediaPlayer {
        id: bgPlayer
        videoOutput: bgVideo
        loops: MediaPlayer.Infinite
        autoPlay: true

        onErrorOccurred: function(error, errorString) {
            console.log("MediaPlayer ERROR:", error, errorString)
            console.log("Source was:", source)
        }
    }

    VideoOutput {
        id: bgVideo
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        z: 0
    }

    function clearFields() {
        loginUserInput.text = ""
        loginPassInput.text = ""
        loginErrorText.text = ""
        loginErrorText.visible = false
    }

    function doLogin() {
        var user = loginUserInput.text.trim()
        var pass = loginPassInput.text

        if (user === "" || pass === "") {
            loginErrorText.text = qsTr("Vui lòng nhập đủ tên đăng nhập và mật khẩu!")
            loginErrorText.visible = true
            return
        }

        var result = accountHandler.authenticate(user, pass)
        var role = String(result).toLowerCase()

        if (result === "NOT_REGISTERED") {
            loginErrorText.text = qsTr("Tài khoản không tồn tại!")
            loginErrorText.color = "#E53935"
            loginErrorText.visible = true
        } else if (result === "WRONG_PASSWORD") {
            loginErrorText.text = qsTr("Sai mật khẩu!")
            loginErrorText.color = "#E53935"
            loginErrorText.visible = true
            loginPassInput.text = ""
        } else if (role === "manager" || role === "staff") {
            loginErrorText.visible = false
            bgPlayer.stop()

            var targetPage = (role === "manager") ? "ManagerPage.qml" : "EmployeePage.qml"

            if (StackView.view) {
                StackView.view.push(targetPage)
            } else {
                loginErrorText.text = qsTr("Lỗi: Không tìm thấy hệ thống điều hướng!")
                loginErrorText.color = "#E53935"
                loginErrorText.visible = true
            }
        } else {
            loginErrorText.text = qsTr("Lỗi hệ thống hoặc kết nối!")
            loginErrorText.color = "#E53935"
            loginErrorText.visible = true
            loginPassInput.text = ""
        }
    }

    Rectangle {
        id: glassBox
        width: 380
        height: 400
        anchors.centerIn: parent
        color: "#80FFFFFF"
        radius: 20
        border.color: "#FFFFFF"
        border.width: 2
        z: 10
        Column {
            anchors.centerIn: parent
            spacing: 25

            Text {
                id: titleText
                text: qsTr("☕ GIANG'S COFFEE")
                font.pixelSize: 28
                font.bold: true
                color: "#0369A1"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                id: loginForm
                spacing: 15

                Column {
                    spacing: 5
                    Text { text: qsTr("Tên đăng nhập"); font.pixelSize: 14; font.bold: true; color: "#0284C7" }
                    TextField {
                        id: loginUserInput
                        focus: true
                        placeholderText: qsTr("Nhập tài khoản của bạn ...")
                        leftPadding: 40; width: 300; height: 48; font.pixelSize: 15; color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle { radius: 12; color: "#FFFFFF"; border.color: "#BAE6FD"; border.width: 1 }
                        Text { text: "👤"; font.pixelSize: 18; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 12; opacity: 0.7 }
                        onAccepted: loginPassInput.forceActiveFocus()
                    }
                }

                Column {
                    spacing: 5
                    Text { text: qsTr("Mật khẩu"); font.pixelSize: 14; font.bold: true; color: "#0284C7" }
                    TextField {
                        id: loginPassInput
                        placeholderText: qsTr("Nhập mật khẩu...")
                        echoMode: TextInput.Password
                        leftPadding: 40; width: 300; height: 48; font.pixelSize: 15; color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle { radius: 12; color: "#FFFFFF"; border.color: "#BAE6FD"; border.width: 1 }
                        Text { text: "🔒"; font.pixelSize: 18; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 12; opacity: 0.7 }
                        onAccepted: doLogin()
                    }
                }

                Text {
                    id: loginErrorText
                    text: ""
                    color: "#E53935"
                    font.pixelSize: 14
                    visible: false
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    id: loginBtn
                    text: qsTr("ĐĂNG NHẬP")
                    width: 300; height: 52; anchors.horizontalCenter: parent.horizontalCenter
                    background: Rectangle {
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#38BDF8" }
                            GradientStop { position: 1.0; color: "#0284C7" }
                        }
                        border.width: parent.pressed ? 2 : 0; border.color: "#FFFFFF"
                    }
                    contentItem: Text {
                        text: parent.text; color: "white"; font.bold: true; font.pixelSize: 17
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: doLogin()
                }
            }
        }
    }
}