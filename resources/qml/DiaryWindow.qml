import QtQuick 2.4
import Material 0.1


ApplicationWindow {
    id: root

// {{{ Properties
    
    property QtObject app

    title: "Diary"
    visible: true
    minimumWidth: Units.dp(800)
    minimumHeight: Units.dp(400)
    // clientSideDecorations: true

    property bool fullscreen: false

    theme {
        primaryColor: Palette.colors["white"]["500"]
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

// Functions }}}

// {{{ Components

    initialPage: MainPage { id: main_page }

// Components }}}

    Component.onCompleted: {
        // ...
    }
}
