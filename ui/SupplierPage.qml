import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Page {
    id: supplierPage
    title: "Nhà Cung Cấp"

    property string filterText: ""
    property bool isAdminUser: typeof appWindow !== "undefined" ? appWindow.isAdmin : true

    function refreshData() {
        if (typeof supplierManager !== "undefined") {
            supplierManager.loadFromCSV()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#F8FAFC"

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(1200, parent.width * 0.94)
            anchors.margins: 16
            spacing: 16

            // HEADER BAR
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                ColumnLayout {
                    spacing: 4
                    Text {
                        text: "🚚 QUẢN LÝ NHÀ CUNG CẤP"
                        font.pixelSize: Math.max(20, Math.min(28, supplierPage.width * 0.025))
                        font.bold: true
                        color: "#0369A1"
                    }
                    Text {
                        text: isAdminUser ? "Quản lý danh sách đối tác cung ứng nguyên liệu & vật tư" : "Danh sách nhà cung cấp nguyên liệu cửa hàng"
                        font.pixelSize: Math.max(12, Math.min(14, supplierPage.width * 0.012))
                        color: "#64748B"
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 160
                    implicitHeight: 50
                    radius: 12
                    color: "#E0F2FE"
                    border.color: "#BAE6FD"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "🏢"; font.pixelSize: 20 }
                        Column {
                            Text { text: "Tổng NCC"; font.pixelSize: 11; color: "#0369A1" }
                            Text {
                                text: typeof supplierManager !== "undefined" ? supplierManager.rowCount() : "0"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#0C4A6E"
                            }
                        }
                    }
                }
            }

            // TOOLBAR
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 60
                radius: 12
                color: "#FFFFFF"
                border.color: "#E2E8F0"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    TextField {
                        id: searchBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        placeholderText: "🔍 Tìm theo mã, tên NCC, người liên hệ, SĐT hoặc nguyên liệu..."
                        font.pixelSize: 14
                        color: "#1E293B"
                        leftPadding: 12
                        rightPadding: 12
                        background: Rectangle {
                            radius: 8
                            color: "#F1F5F9"
                            border.color: searchBox.activeFocus ? "#0284C7" : "#CBD5E1"
                            border.width: searchBox.activeFocus ? 2 : 1
                        }
                        onTextChanged: supplierPage.filterText = text.trim().toLowerCase()
                    }

                    Button {
                        visible: isAdminUser
                        text: "➕ Thêm NCC"
                        Layout.preferredHeight: 40
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle { color: parent.pressed ? "#0284C7" : "#0369A1"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: {
                            supplierDialog.isEditMode = false
                            supplierDialog.clearForm()
                            supplierDialog.open()
                        }
                    }

                    Button {
                        visible: isAdminUser
                        text: "📥 Nhập CSV"
                        Layout.preferredHeight: 40
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle { color: parent.pressed ? "#15803D" : "#16A34A"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: importFileDialog.open()
                    }

                    Button {
                        visible: isAdminUser
                        text: "📤 Xuất CSV"
                        Layout.preferredHeight: 40
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle { color: parent.pressed ? "#0D9488" : "#0F766E"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: exportFileDialog.open()
                    }
                }
            }

            // LISTVIEW
            ListView {
                id: supplierListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 12
                topMargin: 8
                bottomMargin: 16
                model: typeof supplierManager !== "undefined" ? supplierManager : null

                delegate: Item {
                    id: delegateItem
                    width: supplierListView.width

                    property bool matchesFilter: {
                        if (supplierPage.filterText === "") return true;
                        var ft = supplierPage.filterText;
                        var sId = model.id ? model.id.toString().toLowerCase() : "";
                        var sName = model.name ? model.name.toString().toLowerCase() : "";
                        var sContact = model.contactPerson ? model.contactPerson.toString().toLowerCase() : "";
                        var sPhone = model.phone ? model.phone.toString().toLowerCase() : "";
                        var sAddress = model.address ? model.address.toString().toLowerCase() : "";
                        var sItems = model.itemsSupplied ? model.itemsSupplied.toString().toLowerCase() : "";
                        return (sId.indexOf(ft) >= 0) || (sName.indexOf(ft) >= 0) ||
                               (sContact.indexOf(ft) >= 0) || (sPhone.indexOf(ft) >= 0) ||
                               (sAddress.indexOf(ft) >= 0) || (sItems.indexOf(ft) >= 0);
                    }

                    visible: matchesFilter
                    height: matchesFilter ? cardContainer.implicitHeight : 0

                    Rectangle {
                        id: cardContainer
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        implicitHeight: Math.max(96, colInfo.implicitHeight + 28)
                        radius: 12
                        color: "#FFFFFF"
                        border.color: mouseArea.containsMouse ? "#38BDF8" : "#E2E8F0"
                        border.width: mouseArea.containsMouse ? 2 : 1

                        // Nhấp vào bất kỳ đâu trên ô để mở Bảng chi tiết
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                detailDialog.showDetail(model.id, model.name, model.contactPerson, model.phone, model.email, model.address, model.itemsSupplied, model.status)
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: 10
                                color: "#E0F2FE"
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "🏭"
                                    font.pixelSize: 22
                                }
                            }

                            ColumnLayout {
                                id: colInfo
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    spacing: 10
                                    Text {
                                        text: model.name ? model.name : ""
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#0F172A"
                                    }
                                    Rectangle {
                                        color: "#F1F5F9"
                                        radius: 6
                                        implicitWidth: txtId.implicitWidth + 12
                                        implicitHeight: 20
                                        Text {
                                            id: txtId
                                            anchors.centerIn: parent
                                            text: model.id ? model.id : ""
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: "#0369A1"
                                        }
                                    }
                                    Rectangle {
                                        color: model.status === "Hoạt động" ? "#DCFCE7" : (model.status === "Tạm dừng" ? "#FEF3C7" : "#FEE2E2")
                                        radius: 6
                                        implicitWidth: txtStatus.implicitWidth + 12
                                        implicitHeight: 20
                                        Text {
                                            id: txtStatus
                                            anchors.centerIn: parent
                                            text: model.status ? model.status : "Hoạt động"
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: model.status === "Hoạt động" ? "#15803D" : (model.status === "Tạm dừng" ? "#B45309" : "#B91C1C")
                                        }
                                    }
                                }

                                RowLayout {
                                    spacing: 16
                                    Text { text: "👤 " + (model.contactPerson ? model.contactPerson : "---"); font.pixelSize: 13; color: "#475569" }
                                    Text { text: "📞 " + (model.phone ? model.phone : "---"); font.pixelSize: 13; color: "#475569" }
                                    Text { text: "✉️ " + (model.email ? model.email : "---"); font.pixelSize: 13; color: "#475569" }
                                    Text { text: "📍 " + (model.address ? model.address : "---"); font.pixelSize: 13; color: "#475569"; elide: Text.ElideRight; Layout.fillWidth: true }
                                }

                                Text {
                                    text: "📦 Nguyên liệu: " + (model.itemsSupplied ? model.itemsSupplied : "Chưa cập nhật")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#16A34A"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                spacing: 8
                                Layout.alignment: Qt.AlignVCenter

                                // Nút Xem Chi Tiết
                                Button {
                                    text: "👁️ Chi tiết"
                                    implicitHeight: 36
                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    background: Rectangle { color: parent.pressed ? "#E0F2FE" : "#F0F9FF"; radius: 8; border.color: "#BAE6FD" }
                                    contentItem: Text { text: parent.text; color: "#0369A1"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: {
                                        detailDialog.showDetail(model.id, model.name, model.contactPerson, model.phone, model.email, model.address, model.itemsSupplied, model.status)
                                    }
                                }

                                Button {
                                    visible: isAdminUser
                                    text: "✏️"
                                    implicitWidth: 36
                                    implicitHeight: 36
                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    background: Rectangle { color: parent.pressed ? "#BAE6FD" : "#F0F9FF"; radius: 8; border.color: "#38BDF8" }
                                    onClicked: {
                                        supplierDialog.isEditMode = true
                                        supplierDialog.setupData(model.id, model.name, model.contactPerson, model.phone, model.email, model.address, model.itemsSupplied, model.status)
                                        supplierDialog.open()
                                    }
                                }

                                Button {
                                    visible: isAdminUser
                                    text: "🗑️"
                                    implicitWidth: 36
                                    implicitHeight: 36
                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    background: Rectangle { color: parent.pressed ? "#FECACA" : "#FEF2F2"; radius: 8; border.color: "#FCA5A5" }
                                    onClicked: {
                                        deleteConfirmDialog.targetId = model.id
                                        deleteConfirmDialog.targetName = model.name
                                        deleteConfirmDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // BẢNG THÔNG TIN CHI TIẾT NHÀ CUNG CẤP (CHO NHÂN VIÊN & ADMIN)
    Dialog {
        id: detailDialog
        width: Math.min(560, supplierPage.width * 0.92)
        modal: true
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        padding: 0

        property string sId: ""
        property string sName: ""
        property string sContact: ""
        property string sPhone: ""
        property string sEmail: ""
        property string sAddress: ""
        property string sItems: ""
        property string sStatus: ""

        function showDetail(id, name, contact, phone, email, address, items, status) {
            sId = id ? id : "---"
            sName = name ? name : "---"
            sContact = contact ? contact : "---"
            sPhone = phone ? phone : "---"
            sEmail = email ? email : "---"
            sAddress = address ? address : "---"
            sItems = items ? items : "---"
            sStatus = status ? status : "Hoạt động"
            open()
        }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#CBD5E1"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header Dialog
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 70
                color: "#0369A1"
                radius: 16

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 16
                    color: "#0369A1"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text { text: "🏢"; font.pixelSize: 26 }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: detailDialog.sName
                            font.bold: true
                            font.pixelSize: 18
                            color: "#FFFFFF"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "Mã NCC: " + detailDialog.sId
                            font.pixelSize: 12
                            color: "#BAE6FD"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        color: detailDialog.sStatus === "Hoạt động" ? "#22C55E" : (detailDialog.sStatus === "Tạm dừng" ? "#F59E0B" : "#EF4444")
                        radius: 8
                        implicitWidth: txtStatusBadge.implicitWidth + 16
                        implicitHeight: 26
                        Text {
                            id: txtStatusBadge
                            anchors.centerIn: parent
                            text: detailDialog.sStatus
                            font.pixelSize: 12
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }

                    Button {
                        text: "✖"
                        implicitWidth: 32
                        implicitHeight: 32
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle {
                            color: parent.hovered ? "#0284C7" : "transparent"
                            radius: 16
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: detailDialog.close()
                    }
                }
            }

            // Bảng nội dung chi tiết
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 12

                GridLayout {
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 12
                    Layout.fillWidth: true

                    // Ô Người liên hệ
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 60
                        color: "#F8FAFC"
                        radius: 10
                        border.color: "#E2E8F0"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            Text { text: "👤 Người liên hệ"; font.pixelSize: 11; color: "#64748B"; font.bold: true }
                            Text { text: detailDialog.sContact; font.pixelSize: 14; color: "#0F172A"; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                    }

                    // Ô Số điện thoại
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 60
                        color: "#F8FAFC"
                        radius: 10
                        border.color: "#E2E8F0"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            Text { text: "📞 Số điện thoại"; font.pixelSize: 11; color: "#64748B"; font.bold: true }
                            Text { text: detailDialog.sPhone; font.pixelSize: 14; color: "#0369A1"; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                    }

                    // Ô Email
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        implicitHeight: 60
                        color: "#F8FAFC"
                        radius: 10
                        border.color: "#E2E8F0"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            Text { text: "✉️ Email liên hệ"; font.pixelSize: 11; color: "#64748B"; font.bold: true }
                            Text { text: detailDialog.sEmail; font.pixelSize: 14; color: "#0F172A"; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                    }

                    // Ô Địa chỉ
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        implicitHeight: 65
                        color: "#F8FAFC"
                        radius: 10
                        border.color: "#E2E8F0"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            Text { text: "📍 Địa chỉ trụ sở / kho"; font.pixelSize: 11; color: "#64748B"; font.bold: true }
                            Text { text: detailDialog.sAddress; font.pixelSize: 13; color: "#334155"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                    }

                    // Ô Nguyên liệu cung cấp
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        implicitHeight: 70
                        color: "#F0FDF4"
                        radius: 10
                        border.color: "#BBF7D0"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            Text { text: "📦 Nguyên liệu / Danh mục cung cấp"; font.pixelSize: 11; color: "#166534"; font.bold: true }
                            Text { text: detailDialog.sItems; font.pixelSize: 14; color: "#15803D"; font.bold: true; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                    }
                }

                Button {
                    text: "Đóng"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    Layout.topMargin: 6
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle {
                        color: parent.pressed ? "#CBD5E1" : "#E2E8F0"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#334155"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: detailDialog.close()
                }
            }
        }
    }

    // DIALOG THÊM / SỬA NHÀ CUNG CẤP (ADMIN)
    Dialog {
        id: supplierDialog
        width: Math.min(580, supplierPage.width * 0.92)
        modal: true
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        padding: 0

        property bool isEditMode: false

        function clearForm() {
            txtSuppId.text = ""
            txtSuppId.readOnly = false
            txtSuppName.text = ""
            txtSuppContact.text = ""
            txtSuppPhone.text = ""
            txtSuppEmail.text = ""
            txtSuppAddress.text = ""
            txtSuppItems.text = ""
            cboStatus.currentIndex = 0
            lblError.visible = false
        }

        function setupData(sId, sName, sContact, sPhone, sEmail, sAddress, sItems, sStatus) {
            txtSuppId.text = sId ? sId : ""
            txtSuppId.readOnly = true
            txtSuppName.text = sName ? sName : ""
            txtSuppContact.text = sContact ? sContact : ""
            txtSuppPhone.text = sPhone ? sPhone : ""
            txtSuppEmail.text = sEmail ? sEmail : ""
            txtSuppAddress.text = sAddress ? sAddress : ""
            txtSuppItems.text = sItems ? sItems : ""
            if (sStatus === "Tạm dừng") cboStatus.currentIndex = 1
            else if (sStatus === "Ngừng hoạt động") cboStatus.currentIndex = 2
            else cboStatus.currentIndex = 0
            lblError.visible = false
        }

        function submitForm() {
            var id = txtSuppId.text.trim()
            var name = txtSuppName.text.trim()
            if (id === "" || name === "") {
                lblError.text = "Vui lòng nhập đầy đủ Mã NCC và Tên NCC!"
                lblError.visible = true
                if (id === "") txtSuppId.forceActiveFocus()
                else if (name === "") txtSuppName.forceActiveFocus()
                return
            }

            var st = cboStatus.currentText
            var ok = false
            if (supplierDialog.isEditMode) {
                ok = supplierManager.updateSupplier(id, name, txtSuppContact.text.trim(), txtSuppPhone.text.trim(), txtSuppEmail.text.trim(), txtSuppAddress.text.trim(), txtSuppItems.text.trim(), st)
            } else {
                ok = supplierManager.addSupplier(id, name, txtSuppContact.text.trim(), txtSuppPhone.text.trim(), txtSuppEmail.text.trim(), txtSuppAddress.text.trim(), txtSuppItems.text.trim(), st)
                if (!ok) {
                    lblError.text = "Mã NCC '" + id + "' đã tồn tại trong hệ thống!"
                    lblError.visible = true
                    txtSuppId.forceActiveFocus()
                    return
                }
            }

            if (ok) {
                supplierDialog.close()
            }
        }

        onOpened: {
            if (isEditMode) {
                txtSuppName.forceActiveFocus()
            } else {
                txtSuppId.forceActiveFocus()
            }
        }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 16
            border.color: "#E2E8F0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                color: "#F0F9FF"
                radius: 16

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 16
                    color: "#F0F9FF"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 12

                    Rectangle {
                        implicitWidth: 38
                        implicitHeight: 38
                        radius: 10
                        color: "#BAE6FD"
                        Text {
                            anchors.centerIn: parent
                            text: supplierDialog.isEditMode ? "✏️" : "🚚"
                            font.pixelSize: 20
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: supplierDialog.isEditMode ? "Sửa Thông Tin Nhà Cung Cấp" : "Thêm Nhà Cung Cấp Mới"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#0369A1"
                        }
                        Text {
                            text: "Điền thông tin chi tiết của đối tác cung ứng"
                            font.pixelSize: 12
                            color: "#64748B"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "✖"
                        implicitWidth: 32
                        implicitHeight: 32
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle {
                            color: parent.hovered ? "#E2E8F0" : "transparent"
                            radius: 16
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#64748B"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: supplierDialog.close()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#E2E8F0" }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        Layout.preferredWidth: 160
                        spacing: 6
                        Text { text: "Mã nhà cung cấp (*)"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppId
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "VD: SUP001"
                            font.pixelSize: 14
                            color: readOnly ? "#64748B" : "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppId.readOnly ? "#F1F5F9" : (txtSuppId.activeFocus ? "#FFFFFF" : "#F8FAFC")
                                border.color: txtSuppId.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppId.activeFocus ? 2 : 1
                            }
                            onAccepted: txtSuppName.forceActiveFocus()
                            KeyNavigation.tab: txtSuppName
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Tên nhà cung cấp (*)"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppName
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "Tên công ty / đại lý"
                            font.pixelSize: 14
                            color: "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppName.activeFocus ? "#FFFFFF" : "#F8FAFC"
                                border.color: txtSuppName.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppName.activeFocus ? 2 : 1
                            }
                            onAccepted: txtSuppContact.forceActiveFocus()
                            KeyNavigation.tab: txtSuppContact
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Người liên hệ"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppContact
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "VD: Nguyễn Văn An"
                            font.pixelSize: 14
                            color: "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppContact.activeFocus ? "#FFFFFF" : "#F8FAFC"
                                border.color: txtSuppContact.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppContact.activeFocus ? 2 : 1
                            }
                            onAccepted: txtSuppPhone.forceActiveFocus()
                            KeyNavigation.tab: txtSuppPhone
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Số điện thoại"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppPhone
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "VD: 0901234567"
                            font.pixelSize: 14
                            color: "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppPhone.activeFocus ? "#FFFFFF" : "#F8FAFC"
                                border.color: txtSuppPhone.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppPhone.activeFocus ? 2 : 1
                            }
                            onAccepted: txtSuppEmail.forceActiveFocus()
                            KeyNavigation.tab: txtSuppEmail
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        Layout.preferredWidth: 200
                        spacing: 6
                        Text { text: "Email liên hệ"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppEmail
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "VD: contact@brand.com"
                            font.pixelSize: 14
                            color: "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppEmail.activeFocus ? "#FFFFFF" : "#F8FAFC"
                                border.color: txtSuppEmail.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppEmail.activeFocus ? 2 : 1
                            }
                            onAccepted: txtSuppAddress.forceActiveFocus()
                            KeyNavigation.tab: txtSuppAddress
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Địa chỉ trụ sở / kho hàng"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppAddress
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "Nhập địa chỉ chi tiết"
                            font.pixelSize: 14
                            color: "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppAddress.activeFocus ? "#FFFFFF" : "#F8FAFC"
                                border.color: txtSuppAddress.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppAddress.activeFocus ? 2 : 1
                            }
                            onAccepted: txtSuppItems.forceActiveFocus()
                            KeyNavigation.tab: txtSuppItems
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Danh mục nguyên liệu cung cấp"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        TextField {
                            id: txtSuppItems
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: "VD: Hạt cà phê Robusta, Sữa tươi..."
                            font.pixelSize: 14
                            color: "#0F172A"
                            leftPadding: 12
                            rightPadding: 12
                            background: Rectangle {
                                radius: 10
                                color: txtSuppItems.activeFocus ? "#FFFFFF" : "#F8FAFC"
                                border.color: txtSuppItems.activeFocus ? "#0284C7" : "#CBD5E1"
                                border.width: txtSuppItems.activeFocus ? 2 : 1
                            }
                            onAccepted: supplierDialog.submitForm()
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 160
                        spacing: 6
                        Text { text: "Trạng thái"; font.bold: true; font.pixelSize: 13; color: "#334155" }
                        ComboBox {
                            id: cboStatus
                            Layout.fillWidth: true
                            implicitHeight: 42
                            model: ["Hoạt động", "Tạm dừng", "Ngừng hoạt động"]
                        }
                    }
                }

                Rectangle {
                    id: lblError
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: "#FEF2F2"
                    border.color: "#FCA5A5"
                    visible: false

                    property alias text: errTxt.text

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Text { text: "⚠️"; font.pixelSize: 14 }
                        Text {
                            id: errTxt
                            text: ""
                            color: "#DC2626"
                            font.bold: true
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.topMargin: 6

                    Button {
                        text: "Hủy bỏ"
                        Layout.fillWidth: true
                        implicitHeight: 42
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle {
                            color: parent.pressed ? "#E2E8F0" : (parent.hovered ? "#F1F5F9" : "#FFFFFF")
                            radius: 10
                            border.color: "#CBD5E1"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#475569"
                            font.bold: true
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: supplierDialog.close()
                    }

                    Button {
                        id: btnSave
                        text: supplierDialog.isEditMode ? "💾 Lưu thay đổi" : "➕ Thêm nhà cung cấp"
                        Layout.fillWidth: true
                        implicitHeight: 42
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        background: Rectangle {
                            color: parent.pressed ? "#0284C7" : (parent.hovered ? "#0369A1" : "#0284C7")
                            radius: 10
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.bold: true
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: supplierDialog.submitForm()
                    }
                }
            }
        }
    }

    // DIALOG XÁC NHẬN XÓA (ADMIN)
    Dialog {
        id: deleteConfirmDialog
        width: 340
        modal: true
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        title: "Xác nhận xóa"

        property string targetId: ""
        property string targetName: ""

        background: Rectangle { color: "#FFFFFF"; radius: 14; border.color: "#E2E8F0" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            Text {
                text: "⚠️ Bạn có chắc chắn muốn xóa nhà cung cấp:\n" + deleteConfirmDialog.targetName + " (" + deleteConfirmDialog.targetId + ")?";
                font.pixelSize: 13;
                color: "#1E293B";
                wrapMode: Text.WordWrap;
                Layout.fillWidth: true;
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Không"
                    Layout.fillWidth: true
                    implicitHeight: 38
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle { color: parent.pressed ? "#CBD5E1" : "#F1F5F9"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "#334155"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: deleteConfirmDialog.close()
                }

                Button {
                    text: "Xóa"
                    Layout.fillWidth: true
                    implicitHeight: 38
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    background: Rectangle { color: parent.pressed ? "#991B1B" : "#DC2626"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (typeof supplierManager !== "undefined") {
                            supplierManager.deleteSupplier(deleteConfirmDialog.targetId)
                        }
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }

    // FILE DIALOGS
    FileDialog {
        id: importFileDialog
        title: "Chọn file CSV để nhập danh sách Nhà Cung Cấp"
        nameFilters: ["CSV Files (*.csv)", "All Files (*)"]
        onAccepted: {
            if (typeof supplierManager !== "undefined") {
                supplierManager.importFromCSV(importFileDialog.selectedFile)
            }
        }
    }

    FileDialog {
        id: exportFileDialog
        title: "Chọn vị trí lưu file CSV"
        fileMode: FileDialog.SaveFile
        nameFilters: ["CSV Files (*.csv)"]
        onAccepted: {
            if (typeof supplierManager !== "undefined") {
                supplierManager.exportToCSV(exportFileDialog.selectedFile)
            }
        }
    }
}