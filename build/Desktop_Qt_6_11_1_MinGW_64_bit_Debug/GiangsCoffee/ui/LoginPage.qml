import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Particles 2.15

Rectangle {
    id: root
    width: parent.width
    height: parent.height

    // 1. Phông nền Bầu Trời Sáng (Light Sky)
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#BAE6FD" }
        GradientStop { position: 1.0; color: "#F0F9FF" }
    }

    // 2. Hệ thống hạt: Tuyết rơi
    ParticleSystem {
        id: snowSystem
        anchors.fill: parent
    }

    ItemParticle {
        system: snowSystem
        delegate: Rectangle {
            width: Math.random() * 6 + 4
            height: width
            radius: width / 2
            color: "#FFFFFF"
            opacity: Math.random() * 0.6 + 0.4
        }
    }

    Emitter {
        system: snowSystem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        emitRate: 35
        lifeSpan: 10000
        lifeSpanVariation: 2000
        velocity: PointDirection {
            y: 50
            yVariation: 15
            xVariation: 20
        }
    }

    // 3. Khung Giao diện Kính trong suốt
    Rectangle {
        id: glassBox
        width: 380
        height: root.state === "login" ? 480 : 620
        anchors.centerIn: parent
        color: "#80FFFFFF"
        radius: 20
        border.color: "#FFFFFF"
        border.width: 2

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 25

            // ==========================================
            // TIÊU ĐỀ
            // ==========================================
            Text {
                id: titleText
                text: qsTr("☕ GIANG'S COFFEE")
                font.pixelSize: 28
                font.bold: true
                color: "#0369A1"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // ==========================================
            // FORM ĐĂNG NHẬP
            // ==========================================
            Column {
                id: loginForm
                spacing: 15
                visible: root.state === "login"

                // Cụm Tên đăng nhập
                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Tên đăng nhập")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0284C7"
                    }
                    TextField {
                        id: loginUserInput
                        placeholderText: qsTr("Nhập tên tài khoản...")
                        leftPadding: 40
                        width: 300
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter // Căn giữa con trỏ dọc
                        background: Rectangle {
                            radius: 12
                            color: "#FFFFFF"
                            border.color: "#BAE6FD"
                            border.width: 1
                        }
                        Text {
                            text: "👤"
                            font.pixelSize: 18
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            opacity: 0.7
                        }
                    }
                }

                // Cụm Mật khẩu
                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Mật khẩu")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0284C7"
                    }
                    TextField {
                        id: loginPassInput
                        placeholderText: qsTr("Nhập mật khẩu...")
                        echoMode: TextInput.Password
                        leftPadding: 40
                        width: 300
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter // Căn giữa con trỏ dọc
                        background: Rectangle {
                            radius: 12
                            color: "#FFFFFF"
                            border.color: "#BAE6FD"
                            border.width: 1
                        }
                        Text {
                            text: "🔒"
                            font.pixelSize: 18
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            opacity: 0.7
                        }
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
                    text: qsTr("ĐĂNG NHẬP")
                    width: 300
                    height: 52
                    anchors.horizontalCenter: parent.horizontalCenter
                    background: Rectangle {
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#38BDF8" }
                            GradientStop { position: 1.0; color: "#0284C7" }
                        }
                        border.width: parent.pressed ? 2 : 0
                        border.color: "#FFFFFF"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        font.pixelSize: 17
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        var user = loginUserInput.text
                        var pass = loginPassInput.text
                        var isSuccess = accountHandler.authenticate(user, pass)

                        if (isSuccess) {
                            loginErrorText.visible = false
                            stackView.push("qrc:/qt/qml/GiangsCoffee/ui/OrderPage.qml")
                        } else {
                            loginErrorText.text = qsTr("Sai tài khoản hoặc mật khẩu!")
                            loginErrorText.color = "#E53935"
                            loginErrorText.visible = true
                            loginPassInput.text = ""
                        }
                    }
                }

                Text {
                    text: qsTr("Chưa có tài khoản? Đăng ký ngay.")
                    color: "#0369A1"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.state = "register"
                            loginErrorText.visible = false
                        }
                    }
                }
            } // Hết form Login

            // ==========================================
            // FORM ĐĂNG KÝ
            // ==========================================
            Column {
                id: registerForm
                spacing: 15
                visible: root.state === "register"

                // Cụm Tên đăng nhập mới
                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Tên đăng nhập ")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0284C7"
                    }
                    TextField {
                        id: registerUserInput
                        placeholderText: qsTr("Tạo tên tài khoản...")
                        leftPadding: 40
                        width: 300
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter // Căn giữa con trỏ dọc
                        background: Rectangle {
                            radius: 12
                            color: "#FFFFFF"
                            border.color: "#BAE6FD"
                            border.width: 1
                        }
                        Text {
                            text: "👤"
                            font.pixelSize: 18
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            opacity: 0.7
                        }
                    }
                }

                // Cụm Mật khẩu mới
                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Mật khẩu ")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0284C7"
                    }
                    TextField {
                        id: registerPassInput
                        placeholderText: qsTr("Tạo mật khẩu...")
                        echoMode: TextInput.Password
                        leftPadding: 40
                        width: 300
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter // Căn giữa con trỏ dọc
                        background: Rectangle {
                            radius: 12
                            color: "#FFFFFF"
                            border.color: "#BAE6FD"
                            border.width: 1
                        }
                        Text {
                            text: "🔒"
                            font.pixelSize: 18
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            opacity: 0.7
                        }
                    }
                }

                // Cụm Nhập lại mật khẩu
                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Xác nhận mật khẩu")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0284C7"
                    }
                    TextField {
                        id: registerConfirmInput
                        placeholderText: qsTr("Nhập lại mật khẩu...")
                        echoMode: TextInput.Password
                        leftPadding: 40
                        width: 300
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter // Căn giữa con trỏ dọc
                        background: Rectangle {
                            radius: 12
                            color: "#FFFFFF"
                            border.color: "#BAE6FD"
                            border.width: 1
                        }
                        Text {
                            text: "🔐"
                            font.pixelSize: 18
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            opacity: 0.7
                        }
                    }
                }

                Text {
                    id: registerErrorText
                    text: ""
                    color: "#E53935"
                    font.pixelSize: 14
                    visible: false
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: qsTr("ĐĂNG KÝ")
                    width: 300
                    height: 52
                    anchors.horizontalCenter: parent.horizontalCenter
                    background: Rectangle {
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#38BDF8" }
                            GradientStop { position: 1.0; color: "#0284C7" }
                        }
                        border.width: parent.pressed ? 2 : 0
                        border.color: "#FFFFFF"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        font.pixelSize: 17
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        var pass = registerPassInput.text
                        var confirmPass = registerConfirmInput.text
                        var user = registerUserInput.text

                        if (user === "" || pass === "") {
                            registerErrorText.text = qsTr("Vui lòng nhập đủ thông tin!")
                            registerErrorText.visible = true
                            return
                        }

                        if (pass !== confirmPass) {
                            registerErrorText.text = qsTr("Mật khẩu không khớp!")
                            registerErrorText.visible = true
                            registerPassInput.text = ""
                            registerConfirmInput.text = ""
                            return
                        }

                        var isSuccess = accountHandler.registerAccount(user, pass)

                        if (isSuccess) {
                            registerErrorText.visible = false
                            registerUserInput.text = ""
                            registerPassInput.text = ""
                            registerConfirmInput.text = ""

                            root.state = "login"
                            loginErrorText.text = qsTr("Đăng ký thành công! Hãy đăng nhập.")
                            loginErrorText.color = "#43A047"
                            loginErrorText.visible = true
                        } else {
                            registerErrorText.text = qsTr("Tài khoản đã tồn tại!")
                            registerErrorText.visible = true
                            registerUserInput.text = ""
                        }
                    }
                }

                Text {
                    text: qsTr("Đã có tài khoản? Đăng nhập ngay.")
                    color: "#0369A1"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.state = "login"
                            registerErrorText.visible = false
                        }
                    }
                }
            } // Hết form Register
        }
    }

    // ==========================================
    // QUẢN LÝ TRẠNG THÁI (STATES)
    // ==========================================
    state: "login"
    states: [
        State {
            name: "login"
            PropertyChanges { target: titleText; text: qsTr("☕ GIANG'S COFFEE") }
        },
        State {
            name: "register"
            PropertyChanges { target: titleText; text: qsTr("❄ ĐĂNG KÝ") }
        }
    ]
}