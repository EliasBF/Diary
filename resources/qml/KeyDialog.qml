import QtQuick 2.5
import QtQuick.Layouts 1.2
import Material 0.1


Dialog {
    id: dialog

    signal tried(string key)

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: key_text;
                helperText: "";
                hasError: false
            }
        },
        State {
            name: "warning";
            PropertyChanges {
                target: key_text;
                helperText: qsTr("Frase incorrecta");
                hasError: true
            }
        },
        State {
            name: "nothing";
            PropertyChanges {
                target: key_text;
                helperText: qsTr("Debes escribir una frase");
                hasError: true
            }
        }
    ]
    
    positiveButtonText: qsTr("Aceptar")
    negativeButtonText: qsTr("Salir")

    minimumWidth: parent.width * 0.6
    dismissOnTap: false

    ColumnLayout {

        width: dialog.width - (dialog.contentMargins * 2)
        height: 400
        spacing: 10

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/resources/images/logo.png"
            sourceSize {
                width: 280
                height: 124
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            style: "title"
            text: qsTr("Ingresa tu frase para ingresar")
            color: Theme.accentColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            Layout.alignment: Qt.AlignHCenter
            Layout.minimumWidth: parent.width * 0.6
            id: key_text
            echoMode: TextInput.Password

            onTextChanged: {
                if ( hasError ) { dialog.state = "normal"; }
            }
        }
    }

    Keys.onReturnPressed: {
        if ( !key_text.text ) {
            dialog.state = "nothing";
            return;
        }
        else { tried(key_text.text); }
    }

    onAccepted: {
        if ( !key_text.text ) {
            dialog.show();
            dialog.state = "nothing";
            return;
        }
        else {
            dialog.show();
            tried(key_text.text);
        }
    }

    onRejected: {
        root.close();
    }

    onVisibleChanged: {
        if ( visible ) { key_text.forceActiveFocus(); }
        else {
            key_text.text = "";
        }
    }
}
