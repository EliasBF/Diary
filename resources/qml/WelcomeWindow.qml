import QtQuick 2.5
import QtQuick.Layouts 1.2
import Material 0.1
import Material.ListItems 0.1 as List


ApplicationWindow {
    id: root
    objectName: "welcome"

    property QtObject app

    property string journal
    property string key
    property bool is_configured: false

    title: "Diary"
    visible: true
    minimumWidth: Units.dp(950)
    minimumHeight: Units.dp(400)

    property alias state: proxy_state.state

    theme {
        primaryColor: Palette.colors["purple"]["600"]
        primaryDarkColor: Palette.colors["purple"]["600"]
        accentColor: Palette.colors["purple"]["600"]
        tabHighlightColor: Palette.colors["white"]["500"]
        backgroundColor: Palette.colors["white"]["500"]
    }

    initialPage: presentation

    Item {
        id: proxy_state

        states: [
            State {
                name: "start"
                PropertyChanges {
                    target: next;
                    visible: true;
                    text: qStr("Comenzar")
                }
                PropertyChanges {
                    target: previous;
                    visible: false
                }
            },
            State {
                name: "config"
                extend: "start"
                PropertyChanges {
                    target: next;
                    text: qsTr("Siguiente");
                }
                PropertyChanges {
                    target: previous;
                    visible: true
                }
            },
            State {
                name: "end"
                PropertyChanges {
                    target: actions;
                   visible: false
                }
            }
        ]

        state: "start"
    }

    Page {
        id: presentation

        actionBar { hidden: true }
        visible: false

        ColumnLayout {
            width: parent.width * 0.7
            anchors.top: parent.top
            anchors.margins: parent.width * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/resources/images/logo.png"
                sourceSize {
                    width: 280
                    height: 124
                }
            }

            Label {
                style: "title"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft

                text: qsTr("Bienvenido a Diary")
            }

            Label {
                style: "subheading"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft

                text: qsTr("Diary es tu espacio personal y privado, en el puedes escribir sucesos de tu vida además de todos tus pensamientos e ideas, Diary te brinda un lugar seguro donde escribir todas tus pensamientos y una manera sencilla de mantenerlos ordenados y a tu disposición.")
            }
        }
    }

    Page {
        id: key

        actionBar { hidden: true }
        visible: false

        ColumnLayout {
            width: parent.width * 0.7
            anchors.top: parent.top
            anchors.margins: parent.width * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 40

            Label {
                style: "subheading"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft

                text: qsTr("Diary protege todos tus pensamientos e ideas para que solo tu puedas acceder a ellas. Para eso es necesario una contraseña o frase secreta que utilizaras cada vez que ingreses en Diary.")
            }
            
            List.Standard {

                content: RowLayout {
                    width: parent.width * 0.8
                    clip: false
                    anchors.centerIn: parent
                    spacing: 20

                    TextField {
                        id: key_one
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        placeholderText: qsTr("Tu frase")
                        floatingLabel: true
                        echoMode: TextInput.Password
                    }

                    Icon {
                        id: check_one
                        Layout.alignment: Qt.AlignVCenter
                        name: "awesome/check"
                        color: Theme.accentColor
                        visible: false

                        Behavior on visible {
                            NumberAnimation {
                                duration: 200;
                            }
                        }
                    }
                }
            }
            
            List.Standard {

                content: RowLayout {
                    width: parent.width * 0.8
                    clip: false
                    anchors.centerIn: parent
                    spacing: 20

                    TextField {
                        id: key_two
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        placeholderText: qsTr("Repite tu frase")
                        floatingLabel: false
                        echoMode: TextInput.Password

                        onTextChanged: {
                            if ( text == key_one.text ) {
                                check_one.visible = true;
                                check_two.visible = true;

                                if ( key_one.hasError ) {
                                    key_one.hasError = false;
                                    key_two.hasError = false;
                                }
                            }
                            else {
                                check_one.visible = false;
                                check_two.visible = false;
                            }
                        }
                    }

                    Icon {
                        id: check_two
                        Layout.alignment: Qt.AlignVCenter
                        name: "awesome/check"
                        color: Theme.accentColor
                        visible: false

                        Behavior on visible {
                            NumberAnimation {
                                duration: 200;
                            }
                        }
                    }
                }
            }

            Label {
                style: "body1"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Theme.accentColor

                text: key_one.hasError ? qsTr("Tus frases no coinciden.") : qsTr("Utiliza una frase larga con numeros y mayusculas para más seguridad")
            }
        }
    }

    Page {
        id: journal

        actionBar { hidden: true }
        visible: false

        ColumnLayout {
            width: parent.width * 0.7
            anchors.top: parent.top
            anchors.margins: parent.width * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 40

            Label {
                style: "subheading"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft

                text: qsTr("Diary organiza todos tus pensamientos e ideas en diarios, los que puedes utilizar para agrupar tus pensamientos por categorias o temas. Puedes usar Diary como tu diario personal o para escribir sobre algo en particular. Tu decides como organizar tus ideas.")
            }
            
            List.Standard {

                content: RowLayout {
                    width: parent.width * 0.8
                    clip: false
                    anchors.centerIn: parent
                    spacing: 20

                    TextField {
                        id: journal_name
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        placeholderText: qsTr("Nombre")
                        floatingLabel: true

                        onTextChanged: {
                            if ( hasError ) {
                                if ( text.match(/^[A-Za-z ]{5,}$/) ) {
                                    hasError = false;
                                }
                            }
                        }
                    }

                    Icon {
                        Layout.alignment: Qt.AlignVCenter
                        name: "awesome/book"
                        color: Theme.accentColor
                    }
                }
            }

            Label {
                style: "body1"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Theme.accentColor
                height: contentHeight

                text: journal_name.hasError ? qsTr("Para los nombres de tus diarios solo debes utilizar letras y como minimo cinco letras.") : qsTr("Escribe el nombre de tu primer diario.")
            } 
        }
    }

    Page {
        id: finish

        actionBar { hidden: true }
        visible: false

        ColumnLayout {
            width: parent.width * 0.7
            anchors.top: parent.top
            anchors.margins: parent.width * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 40
            
            List.Standard {

                content: RowLayout {
                    width: parent.width * 0.8
                    clip: false
                    anchors.centerIn: parent
                    spacing: 10

                    Icon {
                        Layout.alignment: Qt.AlignVCenter
                        name: "awesome/heart"
                        color: "red"
                        size: 64
                    }

                    Label {
                        Layout.alignment: Qt.AlignVCenter
                        text: qsTr("Gracias por utilizar Diary")
                        style: "display2"
                    }
                }
            }

            Label {
                style: "subheading"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter

                text: qsTr("Todo listo para comenzar !")
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                elevation: 1
                backgroundColor: Theme.accentColor
                text: qsTr("Ir a Diary")
                onClicked: {
                    root.app.configuredComplete();
                    root.close();
                }
            }
 

            Label {
                style: "body1"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Theme.accentColor

                text: qsTr("Si necesitas ayuda para utilizar Diary puedes revisar el manual de ayuda desde el boton con forma de corazon una vez que inicies Diary.")
            } 
        }

        Rectangle {
            id: load
            anchors.fill: parent
            visible: !root.is_configured

            ColumnLayout {
                width: parent.width * 0.7
                anchors.top: parent.top
                anchors.margins: parent.width * 0.1
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 100

                ProgressCircle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width * 0.5
                    Layout.preferredHeight: parent.height * 0.5
                    anchors.centerIn: parent

                    color: Theme.accentColor
                }
    
                Label {
                    style: "subheading"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter

                    text: qsTr("Preparando y configurando Diary...")
                }
            }
        }

        onVisibleChanged: {
            if ( visible ) {
                root.app.configuredDiary(root.journal, root.key);
            }
        }
 
    }

    RowLayout {
        id: actions
        width: parent.width * 0.8
        height: parent.height * 0.15
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Button {
            id: previous
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            context: "dialog"
            text: qsTr("Atras")
            textColor: Theme.accentColor

            onClicked: {
                if ( root.pageStack.currentItem == key ) {
                    root.state = "start";
                }

                root.pageStack.pop();
            }
        }

        Button {
            id: next
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            context: "dialog"
            text: qsTr("Comenzar")
            textColor: Theme.accentColor

            onClicked: {
                if ( root.pageStack.currentItem == presentation ) {
                    root.pageStack.push(key);
                    root.state = "config";
                }
                else if ( root.pageStack.currentItem == key ) {
                    if ( check_one.visible && check_two.visible ) {
                        root.key = key_one.text;
                        root.pageStack.push(journal);
                    }
                    else {
                        key_one.hasError = true;
                        key_two.hasError = true;
                    }
                }
                else if ( root.pageStack.currentItem == journal ) {
                    if ( !journal_name.text.match(/^[A-Za-z ]{5,}$/) ) {
                        journal_name.hasError = true;
                        return;
                    }
                    root.journal = journal_name.text;
                    root.pageStack.push(finish);
                    root.state = "end";
                }
            }
        }
    }
}
