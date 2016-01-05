import QtQuick 2.4


Item {
    id: application
    objectName: "application"

// {{{ Properties

    property bool enableShortCuts: false
    property var journals: {}
    property var active_journal_entries: {}

// Properties }}}

// {{{ Properties bindings

    onJournalsChanged: {
        if ( journals ) {

            for ( var journal in application.journals ) {
                journal_model.append({
                    "name": journal,
                    "filename": application.journals[journal],
                    "current": false
                });
            }

            application.journals = null;

        }
    }

// Properties bindings }}}

// {{{ Models

    property ListModel journal_model: ListModel {
        id: journal_model
        dynamicRoles: true

        property int current_index: -1
    }

    property ListModel journal_entries_model: ListModel {
        id: current_entries_model
        dynamicRoles: true
    }

// Models }}}

// {{{ Functions

    function startDiary() {
        console.log("Locale name: " + Qt.locale().name); 

        if ( journal_model.count != 0 ) {
            application.journals = null;
        }
        else {
        
            for ( var journal in application.journals ) {
                journal_model.append({
                    "name": journal,
                    "filename": application.journals[journal],
                    "current": false
                });
            }
        }

        console.log("Diary is running...");
    }

    function activate_journal(name) {
        console.log("Activate journal: " + name);
        
        for ( var entry in application.active_journal_entries ) {

            journal_entries_model.append({
                "index": entry,
                "title": application.active_journal_entries[entry].title,
                "body": application.active_journal_entries[entry].body,
                "starred": application.active_journal_entries[entry].starred,
                "date": application.active_journal_entries[entry].date,
                "tags": application.active_journal_entries[entry].tags
            });

        }

        application.active_journal_entries = null;

        if ( journal_model.current_index != -1 ) {

            journal_model.setProperty(
                journal_model.current_index,
                "current",
                false
            );
        }

        for ( var index = 0; index <  journal_model.count; index++ ) {
            
            if ( journal_model.get(index).name == name ) {
                journal_model.setProperty(index, "current", true);
                journal_model.current_index = index;
                break;
            }
        }

        console.log("Journal: " + name + "... is active");
    }

// Functions }}}

    Component.onCompleted: {
        // ...
    }
}
