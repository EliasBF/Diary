import QtQuick 2.5
import Material 0.1
import Material.ListItems 0.1 as List


Dialog {
    id: dialog
    property alias tags: tags_list.model

    property bool starred: false
    property var _tags: []
    property var date_start: null
    property var date_end: null

    title: "Filtrar Entradas"
    text: "Seleciona como quieres filtrar tus entradas"

    minimumWidth: parent.width * 0.6

    positiveButtonText: "Filtrar"
    negativeButtonText: "No Filtrar"

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
            iconName: "navigation/expand_more"
        }
        action: Icon {
            anchors.centerIn: parent
            name: "awesome/tags"
            size: Units.dp(32)
        }

        onClicked: {
            if ( expandedTags.iconName == "navigation/expand_more" ) {
                expandedTags.iconName = "navigation/expand_less";
                tags_list.visible = true;
                return;
            }
            expandedTags.iconName = "navigation/expand_more";
            tags_list.visible = false;
        }
    }

    GridView {
        id: tags_list
        width: dialog.width - (dialog.contentMargins * 2)
        height: contentHeight
        cellWidth: tags_list.width / 2
        cellHeight: 20
        visible: false

        delegate: Rectangle {
            width: tags_list.cellWidth
            height: tags_list.cellHeight
            color: "transparent"

            CheckBox {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.slice(1, modelData.length)

                onClicked: {
                    if ( checked ) {
                        _tags.push(modelData);
                    {
                    else {
                        _tags.push(modelData);
                    }
                }
            }
        }
    }

    List.Subtitled {
        text: "Rango de fechas"
        subText: "Filtrar las entradas por un rango de fechas"
        secondaryItem: IconButton {
            id: expandedDates
            anchors.verticalCenter: parent.verticalCenter
            iconName: "navigation/expand_more"
        }
        action: Icon {
            anchors.centerIn: parent
            name: "awesome/calendar"
            size: Units.dp(32)
        }

        onClicked: {
            if ( expandedDates.iconName == "navigation/expand_more" ) {
                expandedDates.iconName = "navigation/expand_less";
                return;
            }
            expandedDates.iconName = "navigation/expand_more";
        }
    }

    onVisibleChanged: {
        if ( !visible ) {
            root.app.activeJournalTags = null;
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
        }
    }
}
