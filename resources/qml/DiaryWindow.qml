import QtQuick 2.4
import Material 0.1


ApplicationWindow {
    id: root
    objectName: "main_window"

// {{{ Properties
    
    property QtObject app

    title: "Diary"
    visible: true
    minimumWidth: Units.dp(950)
    minimumHeight: Units.dp(400)

    property bool fullscreen: false
    property string current_journal

    theme {
        primaryColor: Palette.colors["purple"]["600"]
        primaryDarkColor: Palette.colors["purple"]["600"]
        accentColor: Palette.colors["purple"]["600"]
        tabHighlightColor: Palette.colors["white"]["500"]
        backgroundColor: Palette.colors["white"]["500"]
    }

// Properties }}}

// {{{ Functions

    function startFullscreenMode() {
        fullscreen = true;
        showFullScreen();
    }

    function endFullscreenMode() {
        fullscreen = false;
        showNormal();
    }

    function displayJournal(name) {
        main_page.entries = root.app.journal_entries_model;
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

// Functions }}}

// {{{ Components

    initialPage: MainPage { id: main_page }

    SwitchDialog { 
        id: switch_dialog
        journals: root.app.journal_model
        state: root.app.journal_model.count == 0 ? "nothing" : "start"

        onSwitched: {
            root.current_journal = journal_name;
            if ( switch_dialog.state != "switch" ) {
                switch_dialog.state == "switch";
            }
            root.app.selectedJournal(root.current_journal);       
        }
    }

    KeyDialog {
        id: key_dialog

        onTried: {
            root.app.validatedKey(key);
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

// Components }}}

    onClosing: {
        console.log("Close...");
    }

    Component.onCompleted: {
        timer.start();
    }
}
