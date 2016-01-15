import QtQuick 2.4

import Material 0.1
import Material.ListItems 0.1 as Lists 
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls.Styles 1.4 as Style


Page {
    id: page

    property alias entries: entries_list.model
    property string journal_name
    property bool list_filtered: false

    property QtObject current_entry: QtObject {
        property var index
        property string title
        property var date
        property string body
        property bool starred
        property var tags

        function reset() {
            current_entry.index = null;
            current_entry.title = "";
            current_entry.date = null;
            current_entry.body = "";
            current_entry.tags = null;
        }
    }

    property alias content: content
    property alias header: header
    property alias body: body

    state: "no_journal"

    states: [
        State {
            name: "no_journal"
            PropertyChanges {
                target: side;
                visible: false
            }
            PropertyChanges {
                target: content;
                visible: false
            }
        },
        State {
            name: "journal"
            PropertyChanges {
                target: side;
                visible: true
            }
            PropertyChanges {
                target: content;
                visible: true
            }
        }
    ]

    actionBar {
        hidden: true
    }

    Sidebar {
        id: side

        mode: "left"
        expanded: true
        autoFlick: false
        width: 300

        ListView {
            id: entries_list
            
            anchors.top: parent.top
            height: parent.height - toolbar.height
            width: parent.width

            add: Transition {
                NumberAnimation {
                    property: "opacity";
                    to: 1; 
                    duration: 2000
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y";
                    duration: 1000
                }
            }

            header : Lists.Standard {

                showDivider: true

                content: RowLayout {
                    anchors.centerIn: parent
                    width: parent.width

                    Label {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        elide: Text.ElideRight
                        style: "title"
                        text: page.journal_name
                        font.capitalization: Font.Capitalize
                        color: Theme.accentColor
                    }

                    IconButton {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                        visible: page.list_filtered

                        action: Action {
                            name: qsTr("Deshacer Filtrado")
                            iconName: "awesome/refresh"

                            onTriggered: {
                                root.app.filterEntries = true;
                                root.app.restoredEntries();
                                page.list_filtered = false;
                            }
                        }
                    }

                    IconButton {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        
                        action: Action {
                            name: qsTr("Nueva Entrada")
                            iconName: "awesome/plus"

                            onTriggered: {
                                page.content.state = "writing";
                                page.header.state = "new";
                                page.body.state = "new";
                                page.content.new_entry = true;
                                page.content.sync = false;
                                page.content.saved = false;

                                page.current_entry.reset();
                            }
                        }
                    }
                }
            }

            delegate: Lists.Subtitled {
                id: entry_item

                text: model.title
                subText: Qt.formatDateTime(model.date, ("dd/MM/yyyy '" + qsTr("a las") + "' hh:mm"))

                showDivider: true

                onClicked: {
                    page.current_entry.index = index;
                    page.current_entry.title = model.title;
                    page.current_entry.body = model.body;
                    page.current_entry.date = model.date;
                    page.current_entry.starred = model.starred;
                    page.current_entry.tags = model.tags;
                    
                    if ( page.content.state != "reading" ) {
                        page.content.state = "reading";
                    }    
                    page.header.state = "read";
                    page.body.state = "read";

                    console.log(page.current_entry.tags);
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {
                        if ( mouse.button == Qt.LeftButton ) {
                            mouse.accepted = true;
                            entry_item.clicked();
                        }
                        else if ( mouse.button == Qt.RightButton ) {
                            mouse.accepted = true;
                            entry_menu.open(this, mouse.x - width * 0.2, mouse.y);
                        }
                    }
                }

                Dropdown {
                    id: entry_menu
                    width: 200
                    height: action_export.height + action_del.height

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Lists.Standard {
                            id: action_export
                            text: qsTr("Exportar")
                            iconName: "awesome/files_o"
                            onClicked: {
                                entry_menu.close();
                            }
                        }

                        Lists.Standard {
                            id: action_del
                            text: qsTr("Eliminar")
                            iconName: "awesome/trash"
                            onClicked: {
                                entry_menu.close();
                                root.app.deletedEntry(index);
                                root.app.journal_entries_model._delete(index);
                            }
                        }
                    }
                }
            }
        }

        View {
            id: toolbar
            
            anchors.bottom: parent.bottom
            height: 48
            width: parent.width
            backgroundColor: "white"

            Lists.Standard {
                anchors.fill: parent

                content: RowLayout {
                    anchors.centerIn: parent
                    width: parent.width

                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: qsTr("Cambiar Diario")
                            iconName: "action/swap_horiz"
                            onTriggered: {
                                switch_dialog.show();
                            }
                        }
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: qsTr("Filtrar")
                            iconName: "content/filter_list"

                            onTriggered: {
                                if ( entries_list.count == 0 ) {
                                    snackbar.open(qsTr("Debes tener entradas para poder filtrarlas"));
                                    return;
                                }
                                else {
                                    if ( !root.app.activeJournalTags ) {
                                        root.app.requiredTags();
                                    }
                                    filter_dialog.show();
                                }
                            }
                        }
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: qsTr("Sin Distracciones")
                            iconName: "action/launch"
                            onTriggered: root.startFullscreenMode()
                        }
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: qsTr("Ajustes")
                            iconName: "action/settings"
                        }
                    }
                    
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter
                        
                        action: Action {
                            name: qsTr("Manual")
                            iconName: "awesome/heart"
                        }
                        
                        color: "red"
                    }
                }
            }
        }

    }

    rightSidebar: Sidebar {
        id: right_side

        mode: "right"
        width: 70
        expanded: !side.anchors.leftMargin == 0
    }

    View {
        id: content

        property bool saved: false
        property bool new_entry: false
        property bool sync: false

        state: "stand"

        states: [
            State {
                name: "stand"
                when: (page.state == "journal")
                PropertyChanges {
                    target: header;
                    visible: false
                }
                PropertyChanges {
                    target: body;
                    visible: false
                }
                PropertyChanges {
                    target: action_button;
                    iconName: "awesome/plus"
                }
                PropertyChanges {
                    target: msg;
                    visible: true;
                    text: entries_list.model.count != 0 ? qsTr("Selecciona algun item de la lista a la izquierda o haz click en el boton morado de la derecha para comenzar a escribir") : qsTr("Aun no hay nada escrito, haz click en el boton morado de la derecha para comenzar a escribir")
                }
                PropertyChanges {
                    target: side;
                    expanded: true
                }
            },
            State {
                name: "reading"
                PropertyChanges {
                    target: header;
                    visible: true
                }
                PropertyChanges {
                    target: body;
                    visible: true
                }
                PropertyChanges {
                    target: action_button;
                    iconName: "awesome/pencil"
                }
                PropertyChanges {
                    target: msg;
                    visible: false;
                    text: ""
                }
                PropertyChanges {
                    target: side;
                    expanded: true
                }
            },
            State {
                name: "writing"
                PropertyChanges {
                    target: header;
                    visible: true
                }
                PropertyChanges {
                    target: body;
                    visible: true
                }
                PropertyChanges {
                    target: action_button;
                    iconName: "awesome/save"
                }
                PropertyChanges {
                    target: msg;
                    visible: false
                }
                PropertyChanges {
                    target: side;
                    expanded: false
                }
            }
        ]

        anchors.right: parent.right
        anchors.left: side.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Rectangle {
            id: header

            states: [
                State {
                    name: "new"
                    PropertyChanges {
                        target: header_text;
                        text: "";
                        selected: false
                    }
                },
                State {
                    name: "edit"
                    PropertyChanges {
                        target: header_text;
                        text: page.current_entry.title;
                        selected: page.current_entry.starred
                    }
                },
                State {
                    name: "read"
                    PropertyChanges {
                        target: header_content;
                        text: page.current_entry.title;
                        subText: Qt.formatDateTime(
                            page.current_entry.date,
                            ("'" + qsTr("Escrito el") + "' dd '" + qsTr("de") + "' MM '" + qsTr("a las") + "' hh:mm")
                        );
                        selected: page.current_entry.starred
                    }
                },
                State {
                    name: "stand"
                    extend: "new"
                }
            ]

            width: parent.width
            height: childrenRect.height
            visible: true

            anchors.top: parent.top

            Lists.Subtitled {
                id: header_content
                interactive: true
                iconName: "awesome/star"
                
                visible: content.state == "reading"
                selected: page.current_entry.starred

                onClicked: {
                    page.current_entry.starred = !selected;
                    root.app.updatedEntry(
                        page.current_entry.title,
                        page.current_entry.body,
                        page.current_entry.starred,
                        page.current_entry.index
                    );

                    root.app.journal_entries_model.update(page.current_entry);
                }
            }

            Lists.Standard {
                id: header_text

                property alias text: title_edit.text

                interactive: false
                selected: false

                visible: content.state == "writing"

                content: RowLayout {
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: 10

                    TextField {
                        id: title_edit

                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        
                        placeholderText: qsTr("Titulo")

                        onTextChanged: {
                            page.current_entry.title = text;
                            content.saved = false;
                        }

                    }

                    IconButton {
                        id: starred_action
                        Layout.alignment: Qt.AlignRight

                        action: Action {
                            name: qsTr("Marcar")
                            iconName: "awesome/star"
                            onTriggered: {
                                if (starred_action.color == Theme.accentColor){
                                    // starred_action.color = Theme.light.iconColor;
                                    page.current_entry.starred = false;
                                    content.saved = false;
                                }
                                else {
                                    // starred_action.color = Theme.accentColor
                                    page.current_entry.starred = true;
                                    content.saved = false;
                                }
                            }
                        }

                        color: page.current_entry.starred ? Theme.accentColor : Theme.light.iconColor
                    }

                    IconButton {
                        id: finish_action

                        Layout.alignment: Qt.AlignRight

                        action: Action {
                            name: qsTr("Terminar")
                            iconName: "awesome/check"

                            onTriggered: {
                                if ( page.content.saved ) {
                                    if ( !page.current_entry.title ) {
                                        msg_confirm.state = "not_title";
                                        msg_confirm.show();
                                        return;
                                    }
                                    page.content.state = "stand";
                                    page.body.state = "stand";
                                    page.header.state = "stand";
                                    if ( !page.content.sync ) {
                                        root.app.createdComplete();
                                        snackbar.open("Nueva entrada creada");
                                        return;
                                    }
                                    page.current_entry.reset()
                                    snackbar.open("Cambios guardados");
                                    return;
                                }
                                else {
                                    if ( !page.current_entry.title &&
                                         !page.current_entry.body &&
                                         page.content.new_entry
                                       )
                                    {
                                        page.content.state = "stand";
                                        page.body.state = "stand";
                                        page.header.state = "stand";
                                        page.current_entry.reset();
                                        snackbar.open("Sin cambios");
                                        return;
                                    }
                                    else if ( !page.current_entry.title ) {
                                        msg_confirm.state = "not_title";
                                        msg_confirm.show();
                                        return;
                                    }

                                    msg_confirm.state = "not_save";
                                    msg_confirm.show();
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: body

            states: [
                State {
                    name: "new"
                    PropertyChanges {
                        target: body_text;
                        text: ""
                    }
                },
                State {
                    name: "edit"
                    PropertyChanges {
                        target: body_text;
                        text: page.current_entry.body
                    }
                },
                State {
                    name: "read"
                    PropertyChanges {
                        target: body_label;
                        text: page.current_entry.body
                    }
                },
                State {
                    name: "stand"
                    extend: "new"
                }
            ]

            width: parent.width
            height: parent.height - header.height
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            visible: true

            Label {
                id: body_label
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignJustify
                wrapMode: Text.WordWrap
                width: parent.width / 2
                height: parent.height * 0.9
                visible: content.state == "reading"
            }

            Controls.TextArea {
                id: body_text

                anchors.fill: parent
                activeFocusOnPress: true
                selectByKeyboard: true
                selectByMouse: true
                textFormat: TextEdit.AutoText
                textColor: Theme.light.textColor
                tabChangesFocus: false
                textMargin: 40
                horizontalAlignment: TextEdit.AlignLeft
                verticalAlignment: TextEdit.AlignTop
                wrapMode: TextEdit.WrapAnywhere
                focus: true
                frameVisible: false

                visible: content.state == "writing"

                font.family: "Roboto"
                font.pixelSize: 13
                font.weight: Font.Normal

                style: Style.ScrollViewStyle {
                    handle: Item {
                        implicitWidth: 8

                        Rectangle {
                            color: "black"
                            radius: 2,5
                            opacity: 0.3
                            anchors.fill: parent
                            anchors.topMargin: 6
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            anchors.bottomMargin: 6
                        }
                    }

                    scrollBarBackground: Item {
                        implicitWidth: 8
                    }

                    decrementControl: null
                    incrementControl: null
                }

                Label {
                    anchors.fill: parent
                    anchors.margins: 40
                    text: qsTr("Escribe aqui")
                    visible: !body_text.text
                    color: Theme.light.hintColor
                }

                onTextChanged: {
                    page.current_entry.body = text;
                    content.saved = false;
                }
            }
        }

        Rectangle {
            id: msg

            property alias text: label.text

            anchors.fill: parent
            visible: false

            Label {
                id: label
                
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
                style: "subheading"
                color: Theme.light.hintColor
                wrapMode: Text.WordWrap
                width: parent.width * 0.7
                height: contentHeight
            }
        }

        ActionButton {
            id: action_button

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: true

            anchors.margins: visible ? 25 : -50

            Behavior on anchors.margins {
                NumberAnimation { duration: 200 }
            }

            onClicked: {
                if ( page.content.state == "reading" ) {
                    page.header.state = "edit"
                    page.body.state = "edit"
                    page.content.state = "writing";
                    page.content.new_entry = false;
                    page.content.sync = true;
                    page.content.saved = true;
                }
                else if ( page.content.state == "stand" ) {
                    page.content.state = "writing";
                    page.header.state = "new";
                    page.body.state = "new";
                    page.content.new_entry = true;
                    page.content.sync = false;
                    page.content.saved = false;
                }
                else if ( page.content.state == "writing" ) {
                    if ( page.content.saved ) { 
                        snackbar.open(qsTr("No hay cambios"))
                        return;
                    }
                    else {
                        if ( 
                            !page.current_entry.title &&
                            !page.current_entry.body 
                           )
                        {
                            snackbar.open(qsTr("Debes escribir algo que guardar"))
                            return;
                        }
                        if ( page.content.new_entry ) {
                            root.app.createdEntry(
                                page.current_entry.title,
                                page.current_entry.body,
                                page.current_entry.starred
                            );
                            page.content.saved = true;
                            page.content.new_entry = false;
                        }
                        else {
                            root.app.updatedEntry(
                                page.current_entry.title,
                                page.current_entry.body,
                                page.current_entry.starred,
                                page.current_entry.index ? page.current_entry.index : 0
                            );


                            if ( page.content.sync ) {
                                root.app.journal_entries_model.update(
                                    page.current_entry
                                );
                            }

                            page.content.saved = true;
                        }

                        snackbar.open(qsTr("Guardado"));
                    }
                }
            }
        }
    }

    Snackbar {
        id: snackbar
    }

    Dialog {
        id: msg_confirm

        states: [
            State {
                name: "not_title"
                PropertyChanges {
                    target: msg_confirm;
                    title: qsTr("Nueva Entrada");
                    text: qsTr("Tu entrada no tiene un titulo, Diary usara la fecha actual de tu entrada como titulo, si no escribes uno por tu cuenta.");
                    positiveButtonText: qsTr("Escribir titulo");
                    negativeButtonText: qsTr("Aceptar")
                }
            },
            State {
                name: "not_save"
                PropertyChanges {
                    target: msg_confirm;
                    title: qsTr("Entrada sin Guardar");
                    text: qsTr("hay cambios realizados que no han sido guardados");
                    positiveButtonText: qsTr("Guardar y salir");
                    negativeButtonText: qsTr("Salir sin guardar")
                }
            }
        ]

        onAccepted: {
            if ( state == "not_title" ) {
                close();
                title_edit.forceActiveFocus();
                return;
            }
            else if ( state == "not_save" ) {
                close();
                if ( page.content.new_entry ) {
                    root.app.createdEntry(
                        page.current_entry.title,
                        page.current_entry.body,
                        page.current_entry.starred
                    );

                    page.current_entry.reset();
                }
                else {
                    root.app.updatedEntry(
                        page.current_entry.title,
                        page.current_entry.body,
                        page.current_entry.starred,
                        page.current_entry.index ? page.current_entry.index : 0
                    );
                    
                    if ( page.content.sync ) {
                        root.app.journal_entries_model.update(
                            page.current_entry
                        );
                    }

                    page.current_entry.reset();
                }

                page.content.state = "stand";
                page.body.state = "stand";
                page.header.state = "stand";

                if ( !page.content.sync ) {
                    root.app.createdComplete();
                    snackbar.open(qsTr("Nueva entrada creada"));
                    return;
                }

                snackbar.open(qsTr("Cambios guardados"));
            }
        }

        onRejected: {
            if ( state == "not_title" ) {
                close();
                if ( page.content.new_entry ) {
                    root.app.createdEntry(
                        Qt.formatDateTime(
                            new Date(),
                            ("dd '" + qsTr("de") + "' MMMM '" + qsTr("de") + "' yyyy")
                        ),
                        page.current_entry.body,
                        page.current_entry.starred
                    );

                    page.current_entry.reset();
                }
                else {
                    root.app.updatedEntry(
                        Qt.formatDateTime(
                            (page.current_entry.date ? page.current_entry.date : new Date()),
                            ("dd '" + qsTr("de") + "' MMMM '" + qsTr("de") + "' yyyy")
                        ),
                        page.current_entry.body,
                        page.current_entry.starred,
                        page.current_entry.index ? page.current_entry.index : 0
                    );

                    if ( page.content.sync ) {
                        root.app.journal_entries_model.update(
                            page.current_entry
                        );
                    }

                    page.current_entry.reset();
                }
                page.content.state = "stand";
                page.body.state = "stand";
                page.header.state = "stand";

                if ( !page.content.sync ) {
                    root.app.createdComplete();
                    snackbar.open(qsTr("Nueva entrada creada"));
                    return;
                }

                snackbar.open(qsTr("Cambios guardados"));
            }
            else if ( state == "not_save" ) {
                close();
                page.content.state = "stand";
                page.body.state = "stand";
                page.header.state = "stand";
                if ( !page.content.sync ) {
                    root.app.deletedEntry(0);
                }
                page.current_entry.reset();
                snackbar.open(qsTr("Entrada descartada"));
            }
        }
    }
}
