import QtQuick 2.4
import Material.Extras 0.1


BaseApplication {
    id: diary
    objectName: "diary"

    property Component diary_window: DiaryWindow {
        app: diary
    }

    property Component welcome_window: WelcomeWindow {
        app: diary
    }
    
    signal configuredDiary(string journal, string key)
    signal configuredComplete()
    signal selectedJournal(string name)
    signal createdJournal(string name)
    signal validatedKey(string key)
    signal createdEntry(string title, string body, bool starred)
    signal updatedEntry(string title, string body, bool starred, int index)
    signal createdComplete()
    signal deletedEntry(int index)
    signal requiredTags()
    signal filtered(
        bool starred, string tags,
        date date_start, date date_end
    )
    signal restoredEntries()

    function createWindow(window) {
        var new_window = window.createObject(diary);
        return new_window;
    }

    function load(configured) {
        if ( configured ) {
            var diary_application = createWindow(welcome_window);
        }
        else {
            var diary_application = createWindow(diary_window);
        }
    }

    Component.onCompleted: {
        // ...
    }
}
