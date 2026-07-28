import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: parent.width
    height: parent.height

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#BAE6FD" }
        GradientStop { position: 1.0; color: "#F0F9FF" }
    }

    // ==========================================
    // HIỆU ỨNG TUYẾT RƠI PURE QML
    // ==========================================
    Item {
        id: snowContainer
        anchors.fill: parent
        clip: true

        Repeater {
            model: 40 // Số lượng hạt tuyết

            Rectangle {
                id: flake
                property real speed: Math.random() * 5000 + 4000
                property real initialDelay: Math.random() * 7000

                width: Math.random() * 5 + 3
                height: width
                radius: width / 2
                color: "#FFFFFF"
                opacity: Math.random() * 0.6 + 0.3
                x: Math.random() * root.width
                y: -20

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    running: true

                    PauseAnimation { duration: flake.initialDelay }
                    NumberAnimation {
                        from: -20
                        to: root.height + 20
                        duration: flake.speed
                        easing.type: Easing.Linear
                    }
                    ScriptAction {
                        script: {
                            flake.initialDelay = 0;
                            flake.x = Math.random() * root.width;
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // LOGIC XỬ LÝ (ĐÃ CẬP NHẬT CHỜ ROLE)
    // ==========================================
    function doLogin() {
        var user = loginUserInput.text.trim()
        var pass = loginPassInput.text.trim()

        if (user === "" || pass === "") {
            loginErrorText.text = qsTr("Vui lòng nhập đầy đủ thông tin!")
            loginErrorText.color = "#E53935"
            loginErrorText.visible = true
            return
        }

        // 1. Gọi hàm C++ kiểm tra thông tin và lấy chuỗi Vai trò (Role)
        var role = accountHandler.loginAndGetRole(user, pass)

        if (role !== "") {
            loginErrorText.visible = false

            // 2. Lưu vai trò vào biến toàn cục của main.qml
            currentUserRole = role

            // 3. Điều hướng trang khởi đầu theo từng Vai trò
            if (role === "Khách hàng") {
                stackView.push("qrc:/qt/qml/GiangsCoffee/ui/LoyaltyPage.qml")
            } else if (role === "Nhân viên") {
                stackView.push("qrc:/qt/qml/GiangsCoffee/ui/OrderPage.qml")
            } else if (role === "Quản lý") {
                stackView.push("qrc:/qt/qml/GiangsCoffee/ui/FinancePage.qml")
            }
        } else {
            loginErrorText.text = qsTr("Sai tài khoản hoặc mật khẩu!")
            loginErrorText.color = "#E53935"
            loginErrorText.visible = true
            loginPassInput.text = ""
        }
    }

    function doRegister() {
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
            loginUserInput.forceActiveFocus()
        } else {
            registerErrorText.text = qsTr("Tài khoản đã tồn tại!")
            registerErrorText.visible = true
            registerUserInput.text = ""
        }
    }

    // ==========================================
    // KHUNG GIAO DIỆN
    // ==========================================
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

            Text {
                id: titleText
                text: qsTr("☕ GIANG'S COFFEE")
                font.pixelSize: 28
                font.bold: true
                color: "#0369A1"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Form Đăng nhập
            Column {
                id: loginForm
                spacing: 15
                visible: root.state === "login"

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
                        focus: true
                        placeholderText: qsTr("Nhập tên tài khoản...")
                        leftPadding: 40
                        width: 300
                        height: 48
                        font.pixelSize: 15
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter
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
                        onAccepted: loginPassInput.forceActiveFocus()
                    }
                }

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
                        verticalAlignment: TextInput.AlignVCenter
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
                    onClicked: doLogin()
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
                            registerUserInput.forceActiveFocus()
                        }
                    }
                }
            }

            // Form Đăng ký
            Column {
                id: registerForm
                spacing: 15
                visible: root.state === "register"

                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Tên đăng nhập")
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
                        verticalAlignment: TextInput.AlignVCenter
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
                        onAccepted: registerPassInput.forceActiveFocus()
                    }
                }

                Column {
                    spacing: 5
                    Text {
                        text: qsTr("Mật khẩu")
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
                        verticalAlignment: TextInput.AlignVCenter
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
                        onAccepted: registerConfirmInput.forceActiveFocus()
                    }
                }

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
                        verticalAlignment: TextInput.AlignVCenter
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
                        onAccepted: doRegister()
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
                    id: registerBtn
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
                    onClicked: doRegister()
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
                            root.state = "login" // Đã sửa lỗi chuyển trạng thái về login
                            registerErrorText.visible = false
                            loginUserInput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

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