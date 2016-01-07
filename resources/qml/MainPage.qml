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

    property QtObject current_entry: QtObject {
        property int index
        property string title
        property var date
        property string body
        property bool starred
        property var tags
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
                        
                        action: Action {
                            name: "Nueva Entrada"
                            iconName: "awesome/plus"
                        }
                    }
                }
            }

            delegate: Lists.Subtitled {
                id: entry_item

                text: model.title
                subText: Qt.formatDateTime(model.date, "dd/MM/yyyy 'a las' hh:mm")

                showDivider: true

                onClicked: {
                    page.current_entry.index = model.index;
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
                            text: "Exportar"
                            iconName: "awesome/files_o"
                            onClicked: {
                                entry_menu.close();
                            }
                        }

                        Lists.Standard {
                            id: action_del
                            text: "Eliminar"
                            iconName: "awesome/trash"
                            onClicked: {
                                entry_menu.close()
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
                            name: "Cambiar Diario"
                            iconName: "action/swap_horiz"
                            onTriggered: {
                                switch_dialog.show();
                            }
                        }
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: "Filtrar"
                            iconName: "content/filter_list"
                        }
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: "Sin Distracciones"
                            iconName: "action/launch"
                            onTriggered: root.startFullscreenMode()
                        }
                    }
                    IconButton {
                        Layout.alignment: Qt.AlignVCenter

                        action: Action {
                            name: "Ajustes"
                            iconName: "action/settings"
                        }
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
                    text: entries_list.model.count != 0 ? "Selecciona algun item de la lista a la izquierda o haz click en el boton morado de la derecha para comenzar a escribir" : "Aun no hay nada escrito, haz click en el boton morado de la derecha para comenzar a escribir"
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
                        selected: current_entry.starred;
                    }
                },
                State {
                    name: "read"
                    PropertyChanges {
                        target: header_content;
                        text: page.current_entry.title;
                        subText: Qt.formatDateTime(
                            page.current_entry.date,
                            "'Escrito el' dd 'de' MM 'a las' hh:mm"
                        );
                        selected: page.current_entry.starred
                    }
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

                onClicked: {
                    selected = !selected;
                    page.current_entry.starred = selected;
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
                        
                        placeholderText: "Titulo..."
                    }

                    IconButton {
                        id: starred_action
                        Layout.alignment: Qt.AlignRight

                        action: Action {
                            name: "Marcar"
                            iconName: "awesome/star"
                            onTriggered: {
                                if (starred_action.color == Theme.accentColor){
                                    starred_action.color = Theme.light.iconColor;
                                }
                                else {
                                    starred_action.color = Theme.accentColor
                                }
                            }
                        }

                        color: Theme.light.iconColor
                    }

                    IconButton {
                        id: back_action

                        Layout.alignment: Qt.AlignRight

                        action: Action {
                            name: "Terminar"
                            iconName: "awesome/check"

                            onTriggered: {
                                page.content.state = "stand";
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
                    text: "Escribe aqui..."
                    visible: !body_text.text
                    color: Theme.light.hintColor
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
                }
                else if ( page.content.state == "stand" ) {
                    page.content.state = "writing";
                    page.header.state = "new";
                    page.body.state = "new";
                    //page.content.state = "writing";
                }
                else if ( page.content.state == "writing" ) {
                    console.log("SAVED");
                }
            }
        }
    }
}
