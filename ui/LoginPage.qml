import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia

Rectangle {
    id: root
    width: parent.width
    height: parent.height
    color: "#000000"

    // Timer giúp ép con trỏ nhấp nháy vào ô Tên đăng nhập sau khi trang render xong
    Timer {
        id: focusTimer
        interval: 150
        repeat: false
        onTriggered: loginUserInput.forceActiveFocus()
    }

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
        focusTimer.restart()
    }

    StackView.onDeactivating: {
        bgPlayer.stop()
    }

    Component.onCompleted: {
        syncNavBar()
        bgPlayer.source = getVideoSource()
        bgPlayer.play()
        focusTimer.restart()
    }

    MediaPlayer {
        id: bgPlayer
        videoOutput: bgVideo
        loops: MediaPlayer.Infinite
        autoPlay: true

        onErrorOccurred: function(error, errorString) {
            console.log("MediaPlayer ERROR:", error, errorString)
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
            loginPassInput.forceActiveFocus()
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
        width: Math.min(380, parent.width * 0.88)
        height: Math.min(370, parent.height * 0.78)
        anchors.centerIn: parent
        color:"#dcfbfbFF"
        radius: 20
        border.color: "#FFFFFF"
        border.width: 2
        z: 10

        Image {
            id: logoImage
                       width: 130
                       height: 130
                       anchors.horizontalCenter: parent.horizontalCenter
                       anchors.top: parent.top
                       anchors.topMargin: -55
                       z: 20

            source: {
                if (typeof savesDir !== "undefined" && savesDir !== "") {
                    var base = savesDir.toString().replace(/[\\\/]+$/, "")
                    base = base.replace(/[\\\/]saves$/i, "")
                    return "file:///" + (base + "/data/logo.png").replace(/\\/g, "/")
                }
                if (typeof applicationDir !== "undefined" && applicationDir !== "") {
                    return "file:///" + applicationDir.toString().replace(/\\/g, "/") + "/data/logo.png"
                }
                return ""
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.85
            spacing: 16
            topPadding: 24

            Text {
                id: titleText
                text: qsTr("GIANG'S COFFEE")
                font.pixelSize: Math.max(18, Math.min(26, glassBox.width * 0.075))
                font.bold: true
                color: "#0369A1"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                id: loginForm
                width: parent.width
                spacing: 12

                Column {
                    width: parent.width
                    spacing: 5
                    Text { text: qsTr("Tên đăng nhập"); font.pixelSize: 14; font.bold: true; color: "#0284C7" }

                    TextField {
                        id: loginUserInput
                        focus: true
                        leftPadding: 40
                        width: parent.width
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle { radius: 12; color: "#FFFFFF"; border.color: "#BAE6FD"; border.width: 1 }

                        Text { text: "👤"; font.pixelSize: 18; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 12; opacity: 0.7 }

                        // Chữ gợi ý mờ luôn hiển thị cho tới khi ĐÃ GÕ chữ
                        Text {
                            text: qsTr("Nhập tài khoản của bạn ...")
                            color: "#94A3B8"
                            font.pixelSize: 15
                            anchors.left: parent.left
                            anchors.leftMargin: 40
                            anchors.verticalCenter: parent.verticalCenter
                            visible: loginUserInput.text === ""
                        }

                        onAccepted: loginPassInput.forceActiveFocus()
                    }
                }

                Column {
                    width: parent.width
                    spacing: 5
                    Text { text: qsTr("Mật khẩu"); font.pixelSize: 14; font.bold: true; color: "#0284C7" }

                    TextField {
                        id: loginPassInput
                        property bool showPassword: false
                        echoMode: showPassword ? TextInput.Normal : TextInput.Password
                        leftPadding: 40
                        rightPadding: 44
                        width: parent.width
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle { radius: 12; color: "#FFFFFF"; border.color: "#BAE6FD"; border.width: 1 }

                        Text { text: "🔒"; font.pixelSize: 18; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 12; opacity: 0.7 }

                        // Chữ gợi ý mờ cho mật khẩu
                        Text {
                            text: qsTr("Nhập mật khẩu...")
                            color: "#94A3B8"
                            font.pixelSize: 15
                            anchors.left: parent.left
                            anchors.leftMargin: 40
                            anchors.verticalCenter: parent.verticalCenter
                            visible: loginPassInput.text === ""
                        }

                        onAccepted: doLogin()

                        Text {
                            text: loginPassInput.showPassword ? "🕶" : "👁"
                            font.pixelSize: 16
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 12
                            opacity: 0.75
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: loginPassInput.showPassword = !loginPassInput.showPassword
                            }
                        }
                    }
                }

                Text {
                    id: loginErrorText
                    text: ""
                    color: "#E53935"
                    font.pixelSize: 14
                    visible: false
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Nút Đăng nhập bo tròn chuẩn không bị viền vuông khi Hover
                Rectangle {
                    id: loginBtn
                    width: parent.width
                    height: 52
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: loginBtnMouseArea.pressed ? "#0284C7" : (loginBtnMouseArea.containsMouse ? "#38BDF8" : "#0284C7")
                        }
                        GradientStop {
                            position: 1.0
                            color: loginBtnMouseArea.pressed ? "#0369A1" : (loginBtnMouseArea.containsMouse ? "#0284C7" : "#0369A1")
                        }
                    }

                    border.width: loginBtnMouseArea.pressed ? 2 : 0
                    border.color: "#FFFFFF"

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("ĐĂNG NHẬP")
                        color: "white"
                        font.bold: true
                        font.pixelSize: 17
                    }

                    MouseArea {
                        id: loginBtnMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: doLogin()
                    }
                }
            }
        }
    }
}