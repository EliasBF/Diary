import QtQuick 2.4
import Material.Extras 0.1


BaseApplication {
    id: diary
    objectName: "diary"

    property Component diary_window: DiaryWindow {
        app: diary
    }

    function createWindow() {
        var new_window = diary_window.createObject(diary);
        return new_window;
    }

    function load() {
        var diary_application = createWindow();
    }

    Component.onCompleted: {
        diary.load();
    }
}
