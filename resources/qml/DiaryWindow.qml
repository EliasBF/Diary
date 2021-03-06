import QtQuick 2.4
import Material 0.1


ApplicationWindow {
    id: root
    objectName: "main_window"
    
    property QtObject app

    title: "Diary"
    visible: true
    minimumWidth: 700
    minimumHeight: 400
    width: 950
    height: 500

    property bool fullscreen: false
    property string current_journal

    theme {
        primaryColor: Palette.colors["purple"]["600"]
        primaryDarkColor: Palette.colors["purple"]["600"]
        accentColor: Palette.colors["purple"]["600"]
        tabHighlightColor: Palette.colors["white"]["500"]
        backgroundColor: Palette.colors["white"]["500"]
    }

    function startFullscreenMode() {
        fullscreen = true;
        showFullScreen();
    }

    function endFullscreenMode() {
        fullscreen = false;
        showNormal();
    }

    function displayJournal(name) {
        if ( !main_page.entries ) {
            main_page.entries = root.app.journal_entries_model;
        }
        main_page.journal_name = name;
        main_page.state = "journal";
    }

    function valid_key(key) {
        key_dialog.close();
        switch_dialog.show();
    }

    function invalid_key() {
        key_dialog.state = "warning";
    }

    function no_match_filter() {
        main_page.snackbar.open(qsTr("No se encontraron entradas"));
    }

    initialPage: MainPage { id: main_page }

    SwitchDialog { 
        id: switch_dialog
        journals: root.app.journal_model
        state: root.app.journal_model.count == 0 ? "nothing" : "start"

        onSwitched: {
            root.current_journal = journal_name;
            if ( switch_dialog.state != "switch" ) {
                switch_dialog.state = "switch";
            }
            root.app.switchJournal = true;
            main_page.state = "no_journal";
            root.app.selectedJournal(root.current_journal);
        }
    }

    KeyDialog {
        id: key_dialog

        onTried: {
            root.app.validatedKey(key);
        }
    }

    FilterDialog {
        id: filter_dialog
        tags: root.app.activeJournalTags

        onFilter: {
            var string_tags = "";
            if ( tags && tags.length > 0 ) {
                tags.forEach(function(tag) {
                    string_tags += tag + "/";
                });
                string_tags = string_tags.slice(0, string_tags.length - 1);
            }
            root.app.filterEntries = true;
            main_page.list_filtered = true;
            root.app.filtered(
                starred, 
                string_tags,
                date_start ? date_start : new Date(1,1,1),
                date_end ? date_end : new Date(25,10,275759),
                strict
            );
        }
    }

    Timer {
        id: timer
        repeat: false
        interval: 500
        running: false

        onTriggered: {
           key_dialog.show(); 
        }
    }

    onClosing: {
        console.log("Close...");
    }

    Component.onCompleted: {
        timer.start();
    }
}
