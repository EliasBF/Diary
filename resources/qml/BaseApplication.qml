import QtQuick 2.4


Item {
    id: application
    objectName: "application"

// {{{ Properties

    property string platform: "unknown/desktop"
    property bool enableShortCuts: false

// Properties }}}

// {{{ Models

    property ListModel journal_model: ListModel {
        id: journal_model
        dynamicRoles: true
    }

    property ListModel journal_entries_model: ListModel {
        id: current_entries_model
        dynamicRoles: true
    }

// Models }}}

// {{{ Functions
// Functions }}}

    Component.onCompleted: {
        console.log("Locate name: " + Qt.locale().name);
        console.log("Diary is Running");
    }
}
