import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4 as Controls
import Material 0.1
import Material.ListItems 0.1 as List


Dialog {
    id: dialog
    property alias tags: tags_list.model

    property bool starred: false
    property bool strict: false
    property var _tags: null
    property var date_start: null
    property var date_end: null

    signal filter(
        bool starred, variant tags,
        variant date_start, variant date_end
    )

    states: [
        State {
            name: "start"
            PropertyChanges {
                target: dialog;
                text: qsTr("Seleciona como quieres filtrar tus entradas")
                positiveButtonText: qsTr("Filtrar")
                negativeButtonText: qsTr("No Filtrar")
            }
        },
        State {
            name: "tags"
            PropertyChanges {
                target: dialog;
                text: qsTr("Selecciona las palabras clave que deben contener las entradas")
                positiveButtonText: qsTr("Volver")
            }
            PropertyChanges {
                target: negativeButton;
                visible: false
            }
        },
        State {
            name: "date"
            extend: "tags"
            PropertyChanges {
                target: dialog;
                text: qsTr("Seleciona un rango de fechas en el que fueron creadas tus entradas")
            }
        }
    ]

    title: "Filtrar Entradas"

    minimumWidth: parent.width * 0.6

    Controls.StackView {
        id: stack_items

        width: dialog.width - (dialog.contentMargins * 2)
        height: 300

        initialItem: start

        Item {
            id: start

            width: stack_items.width
            height: stack_items.height

            visible: false

            ColumnLayout {
                anchors.fill: parent

                List.Subtitled {
                    text: "Entradas marcadas"
                    subText: "Filtrar solo las entradas marcadas con estrella"
                    secondaryItem: Switch {
                        id: enablingMark
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    action: Icon {
                        anchors.centerIn: parent
                        name: "awesome/star"
                        size: Units.dp(32)
                    }

                    onClicked: {
                        enablingMark.checked = !enablingMark.checked;
                        dialog.starred = enablingMark.checked;
                    }
                }

                List.Subtitled {
                    text: "Palabras clave"
                    subText: "Filtrar las entradas si contienen una palabra clave"

                    enabled: tags_list.count > 0

                    secondaryItem: IconButton {
                        id: expandedTags
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "awesome/arrow_right"
                    }
                    action: Icon {
                        anchors.centerIn: parent
                        name: "awesome/tags"
                        size: Units.dp(32)
                    }

                    onClicked: {
                        stack_items.push(tags_item);
                        dialog.state = "tags";
                    } 
                }

                List.Subtitled {
                    text: "Rango de fechas"
                    subText: "Filtrar las entradas por un rango de fechas"
                    secondaryItem: IconButton {
                        id: expandedDates
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "awesome/arrow_right"
                    }
                    action: Icon {
                        anchors.centerIn: parent
                        name: "awesome/calendar"
                        size: Units.dp(32)
                    }

                    onClicked: {
                        stack_items.push(date_item);
                        dialog.state = "date";
                    }
                }
    
                Label {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    text: qsTr("Puedes selecionar más de un filtro, aquellos que no seleciones se omitiran")
                    style: "caption"
                    color: Theme.accentColor
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            id: tags_item

            width: stack_items.width
            height: stack_items.height
            visible: false

            ColumnLayout {

                anchors.centerIn: parent
                width: parent.width * 0.9
                height: parent.height

                GridView {
                    id: tags_list
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: tags_list.width / 2
                    cellHeight: 30

                    delegate: Rectangle {
                        width: tags_list.cellWidth
                        height: tags_list.cellHeight
                        color: "transparent"

                        CheckBox {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.slice(1, modelData.length)

                            onClicked: {
                                if ( checked ) {
                                    if ( !_tags ) {
                                        dialog._tags = new Array();
                                        dialog._tags[String(index)] = modelData;
                                    }
                                    else {
                                        dialog._tags[String(index)] = modelData;
                                    }
                                }
                                else {
                                    delete _tags[String(index)];
                                }
                            }
                        }
                    }
                }

                List.Standard {
                    id: markStrict
                    Layout.alignment: Qt.AlignBottom
                    interactive: true

                    content: RowLayout {

                        width: parent.width
                        anchors.centerIn: parent

                        Label {
                            Layout.fillWidth: true
                            style: "caption"
                            text: qsTr("Solo aceptar entradas que contengan todas las palabras seleccionadas")
                            color: Theme.accentColor
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Switch {
                            id: enablingStrict
                        }
                    }
                        
                    onClicked: {
                        enablingStrict.checked = !enablingStrict.checked;
                        dialog.strict = enablingStrict.checked;
                    }
                }
            }
        }

        Item {
            id: date_item
            width: stack_items.width
            height: stack_items.height
            visible: false

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: parent.height

                List.Standard {
                    id: inputStart

                    content: RowLayout {
                        width: parent.width * 0.7
                        anchors.centerIn: parent
                        spacing: 20

                        Label {
                            Layout.alignment: Qt.AlignLeft
                            text: qsTr("Desde")
                            style: "subheading"
                        }

                        Label {
                            Layout.alignment: Qt.AlignLeft
                            text: Qt.formatDate(dialog.date_start, "dd/MM/yyyy")
                            style: "subheading"
                        }

                        Button {
                            Layout.alignment: Qt.AlignLeft
                            text: qsTr("Seleccionar fecha")
                            elevation: 1

                            onClicked: {
                                if ( dialog.date_end ) {
                                    stack_items.push({
                                        item: picker_item,
                                        properties: {
                                            maximumDate: dialog.date_end,
                                            minimumDate: new Date(1,1,1),
                                            start: true
                                        }
                                    });
                                }
                                else {
                                    stack_items.push({
                                        item: picker_item,
                                        properties: {
                                            minimumDate: new Date(1,1,1),
                                            start: true
                                        }
                                    });
                                }
                            }
                        }
                    }
                }

                List.Standard {
                    id: inputEnd

                    content: RowLayout {
                        width: parent.width * 0.7
                        anchors.centerIn: parent
                        spacing: 20

                        Label {
                            Layout.alignment: Qt.AlignLeft
                            text: qsTr("Hasta")
                            style: "subheading"
                        }

                        Label {
                            Layout.alignment: Qt.AlignLeft
                            text: Qt.formatDate(dialog.date_end, "dd/MM/yyyy")
                            style: "subheading"
                        }

                        Button {
                            Layout.alignment: Qt.AlignLeft
                            text: qsTr("Seleccionar fecha")
                            elevation: 1

                            onClicked: {
                                if ( dialog.date_start ) {
                                    stack_items.push({
                                        item: picker_item,
                                        properties: {
                                            minimumDate: dialog.date_start,
                                            maximumDate: new Date(25,10,272759),
                                            start: false
                                        }
                                    });
                                }
                                else {
                                    stack_items.push({
                                        item: picker_item,
                                        properties: {
                                            maximumDate: new Date(25,10,272529),
                                            start: false
                                        }
                                    });
                                }
                            }
                        }
                    }
                }

                Label {
                    id: dateMsg
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    style: "caption"
                    text: qsTr("Puedes seleccionar solo una fecha y se realizara el filtro hasta o desde la fecha que ingreses. Si no seleccionas ninguna, el filtro por fechas se omitira")
                    color: Theme.accentColor
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Item {
            id: picker_item

            property alias maximumDate: date_picker.maximumDate
            property alias minimumDate: date_picker.minimumDate
            property bool start

            width: stack_items.width
            height: stack_items.height
            visible: false

            DatePicker {
                id: date_picker
                anchors.centerIn: parent
                isLandscape: true
                frameVisible: false

                onClicked: {
                    if ( picker_item.start ) {
                        dialog.date_start = selectedDate;
                    }
                    else {
                        dialog.date_end = selectedDate;
                    }
                }
            }
        }
    }

    onAccepted: {
        dialog.show();
        if ( dialog.state == "tags" || dialog.state == "date" ) {
            if ( stack_items.currentItem == picker_item ) {
                stack_items.pop();
                return;
            }
            stack_items.pop();
            dialog.state = "start";
            return;
        }
        dialog.close();

        filter(
            dialog.starred,
            dialog._tags,
            dialog.date_start,
            dialog.date_end,
            dialog.strict
        );
    }

    onVisibleChanged: {
        if ( !visible ) {
            root.app.activeJournalTags = null;
            dialog.starred = false;
            dialog.strict = false;
            dialog._tags = null;
            dialog.date_start = null;
            dialog.date_end = null;
            dialog.state = "";
            enablingMark.checked = false;
            enablingStrict.checked = false;
            expandedTags.iconName = "awesome/arrow_right";
            expandedDates.iconName = "awesome/arrow_right";
        }
        else { 
            dialog.state = "start";
            if ( stack_items.currentItem != start ) {
                stack_items.push(start);
            }
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
        }
    }
}
