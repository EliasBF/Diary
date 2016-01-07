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
                helperText: "Frase incorrecta";
                hasError: true
            }
        },
        State {
            name: "nothing";
            PropertyChanges {
                target: key_text;
                helperText: "Debes escribir una frase";
                hasError: true
            }
        }
    ]
    
    positiveButtonText: "Aceptar"
    negativeButtonText: "Salir"

    minimumWidth: parent.width * 0.4
    title: "Diary"
    text: "Ingresa tu frase secreta para acceder"

    TextField {
        id: key_text

        width: dialog.width - (dialog.contentMargins * 2)

        onTextChanged: {
            if ( hasError ) { dialog.state = "normal"; }
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
