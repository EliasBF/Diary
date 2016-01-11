import QtQuick 2.5
import Material 0.1


Dialog {
    id: dialog
    property alias tags: tags_list.model

    ListView {
        id: tags_list
        width: dialog.width - (dialog.contentMargins * 2)
        height: 200

        delegate: Label {
            text: modelData
        }
    }
}
