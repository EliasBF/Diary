import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as List


Dialog {
    id: dialog

    property alias journals: journals_list.model
    property string old_state

    states: [
        State {
            name: "start"
            PropertyChanges {
                target: dialog;
                dismissOnTap: false;
                title: "Tus Diarios";
                text: "¿ Cual deseas abrir ?";
                positiveButtonText: "Nuevo diario";
                width: 300
            }
            PropertyChanges {
                target: negativeButton;
                visible: false
            }
            PropertyChanges {
                target: journals_list;
                visible: true;
                focus: true
            }
            PropertyChanges {
                target: new_journal;
                visible: false
            }
        },
        State {
            name: "create"
            extend: "start"
            PropertyChanges {
                target: dialog;
                title: "Nuevo Diario"
                text: ""
                positiveButtonText: "Crear"
                negativeButtonText: "Cancelar"
                width: parent.width * 0.5
            }
            PropertyChanges {
                target: journals_list;
                visible: false
            }
            PropertyChanges {
                target: new_journal;
                visible: true
            }
            PropertyChanges {
                target: negativeButton;
                visible: true
            }
        },
        State {
            name: "switch"
            extend: "start"
            PropertyChanges {
                target: dialog;
                dismissOnTap: true
            }
            PropertyChanges {
                target: negativeButton;
                visible: true
            }
        },
        State {
            name: "nothing"
            extend: "start"
            PropertyChanges {
                target: dialog;
                title: "Diary"
                text: "No tienes ningun diario, crea uno para comenzar"
            }
            PropertyChanges {
                target: journals_list;
                visible: false
            }
        }
    ]

    state: "start"

    negativeButtonText: "No cambiar"

    ListView {
        id: journals_list
        
        width: dialog.width - (dialog.contentMargins * 2)
        height: 200
        focus: true

        highlight: Rectangle {
            Icon {
                name: "awesome/book"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.margins: 10
                color: Theme.accentColor

                visible: journals_list.visible

                Behavior on visible {
                    NumberAnimation {
                        duration: 200;
                    }
                }
            }
        }

        delegate: List.Standard {
            text: model.name
            selected: model.current
            interactive: false
            itemLabel.font.capitalization: Font.Capitalize
            itemLabel.font.underline: model.current
        }
    }

    Rectangle {
        id: new_journal

        property alias new_journal_name: journal_name_edit.text
        property alias journal_state: journal_name_edit.state

        width: dialog.width - (dialog.contentMargins * 2)
        height: childrenRect.height * 2
        color: "transparent"

        onVisibleChanged: {
            if ( visible ) { journal_name_edit.forceActiveFocus(); }
            else { journal_name_edit.text = ""; }
        }

        TextField {
            id: journal_name_edit

            state: "fine"

            states: [
                State {
                    name: "fine"
                    PropertyChanges {
                        target: journal_name_edit;
                        helperText: "Escribe el nombre de tu nuevo diario (solo puede contener letras)"
                        hasError: false
                    }
                },
                State {
                    name: "warning"
                    PropertyChanges {
                        target: journal_name_edit;
                        helperText: "Escribe un nombre que contenga minimo 5 letras"
                        hasError: true
                    }
                }
            ]

            anchors.centerIn: parent

            placeholderText: "Nombre..."
            width: parent.width

            characterLimit: 100
            validator: RegExpValidator {
                regExp: /^[A-Za-z ]{1,100}$i/
            }

            onTextChanged: {

                if ( hasError ) {
                    var regexp = /^[A-Za-z ]{5,100}$/
                    if ( text.match(regexp) ) { 
                        state = "fine";
                    }
                    else { state = "warning"; }
                }

            }
        }
    }

    Keys.onReturnPressed: {
        if ( journals_list.visible && dialog.state != "nothing" ) {
            event.accepted = true;
            close();
            if ( dialog.state != "switch" ) { dialog.state = "switch"; }
            if ( journals_list.currentItem.selected ) { return; }
            root.app.selectedJournal(journals_list.currentItem.text, "elias");
        }
        else {
            event.accepted = false;
        }
    }

    onAccepted: {
        dialog.show();

        if ( new_journal.visible ) {

            // Crear nuevo diario pero antes validar la entrada del usuario.
            if ( !new_journal.new_journal_name.match(/^[A-Za-z ]{5,100}$/) ) {
                new_journal.journal_state = "warning";
                return;
            }
            else {
                root.app.createdJournal(new_journal.new_journal_name);
            }

            if ( dialog.old_state != "" ) {
                dialog.state = dialog.old_state;
            }
            else {
                root.app.selectedJournal(new_journal.new_journal_name, "elias");
            }
        }
        else {
            dialog.old_state = dialog.state != "nothing" ? dialog.state : "";
            dialog.state = "create"
        }
    }

    onRejected: {
        dialog.show();

        if ( dialog.state != "create" ) {
            dialog.close();
        }
        else {
            if ( dialog.old_state == "" ) {
                dialog.state = "nothing";
                return
            }
            dialog.state = dialog.old_state;
        }
    }
    Behavior on width {
        NumberAnimation {
            duration: 200;
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 200;
        }
    }
}
