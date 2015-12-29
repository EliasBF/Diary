import QtQuick 2.4

import Material 0.1
import Material.ListItems 0.1 as Lists 
import QtQuick.Layouts 1.2


Page {
    id: page

    actionBar {
        hidden: true
    }

    Sidebar {
        id: side

        mode: "left"
        expanded: true
        autoFlick: false
        width: parent.width * 0.3

        ColumnLayout {
            id: entries_list
            
            anchors.top: parent.top
            height: parent.height - toolbar.height
            width: parent.width
            spacing: 0

            Lists.Standard {
                Layout.alignment: Qt.AlignTop

                content: RowLayout {
                    anchors.centerIn: parent
                    width: parent.width

                    Label {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        elide: Text.ElideRight
                        style: "body1"
                        text: "Entradas"
                    }

                    IconButton {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        
                        action: Action {
                            name: "Nueva"
                            iconName: "awesome/plus"
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
                            name: "Ordenar"
                            iconName: "content/sort"
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

    View {
        id: content

        anchors.right: parent.right
        anchors.left: side.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Label {
            anchors.centerIn: parent
            text: "Diary"
        }
    }

}
