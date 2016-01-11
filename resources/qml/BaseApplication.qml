import QtQuick 2.4


Item {
    id: application
    objectName: "application"

    property bool enableShortCuts: false
    property int entries_count: journal_entries_model.count
    property bool switchJournal: false
    property var journals: {}
    property var activeJournalEntries: {}
    property var activeJournalTags: []

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

    onActiveJournalEntriesChanged: {
        if ( activeJournalEntries ) {
            if ( application.switchJournal ) { 
                journal_entries_model.clear(); 
                if ( activeJournalTags ) { activeJournalTags = null; }
            }
            if ( journal_entries_model.count == 0 ) {
                for ( var entry in application.activeJournalEntries ) {
        
                    journal_entries_model.append({
                        "title": application.activeJournalEntries[entry].title,
                        "body": application.activeJournalEntries[entry].body,
                        "starred": application.activeJournalEntries[entry].starred,
                        "date": application.activeJournalEntries[entry].date,
                        "tags": application.activeJournalEntries[entry].tags
                    });
                }
            }
            else {
                for ( var entry in application.activeJournalEntries ) {

                    journal_entries_model.insert(0, {
                        "title": application.activeJournalEntries[entry].title,
                        "body": application.activeJournalEntries[entry].body,
                        "starred": application.activeJournalEntries[entry].starred,
                        "date": application.activeJournalEntries[entry].date,
                        "tags": application.activeJournalEntries[entry].tags
                    });
                }
            }

            application.activeJournalEntries = null;
        }
    }

    property ListModel journal_model: ListModel {
        id: journal_model
        dynamicRoles: true

        property int current_index: -1
    }

    property ListModel journal_entries_model: ListModel {
        id: journal_entries_model
        dynamicRoles: true

        function update(entry) {

            journal_entries_model.setProperty(
                entry.index, "title",
                (entry.title ? entry.title : Qt.formatDateTime(
                    (entry.date ? entry.date : new Date()),
                    ("dd '" + qsTr("de") + "' MMMM '" + qsTr("de") + "' yyyy")
                ))
            );
            journal_entries_model.setProperty(
                entry.index, "body", entry.body
            );
            journal_entries_model.setProperty(
                entry.index, "starred", entry.starred
            );

            return;
        }

        function _delete(entry_index) {
            journal_entries_model.remove(entry_index);
            return;
        }
    }

    function startDiary() {

        if ( application.journals ) {
            application.journals = null;
        }

    }

    function activate_journal(name) {
        console.log("Activate journal: " + name);
        
        if ( application.activeJournalEntries ) {
            application.activeJournalEntries = null;
        }

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
        
        if ( application.switchJournal ) { application.switchJournal = false; }

        console.log("Journal: " + name + "... is active");
    }

    Component.onCompleted: {
        // ...
    }
}
