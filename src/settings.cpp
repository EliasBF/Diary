/*

    diary.settings
    ~~~~~~~~~~~~~~

*/


#include <QDir>

#include "settings.h"


Settings::Settings()
: QSettings((QDir::homePath() + "/.diary"), QSettings::NativeFormat)
{
    
    // Crear el archivo de configuracion por primera vez, sus secciones y
    // valores por defecto.
    if ( this->allKeys().isEmpty() == true ) {

        // Window
        this->setValue("window/x", 0);
        this->setValue("window/y", 0);
        this->setValue("window/width", 900.0);
        this->setValue("window/height", 400.0);

        // Journals
        this->setValue("data/journals", QStringList(""));

        // General
        this->setValue("general/encrypted", false);

    }
    
    this->window_x = this->value("window/x").toDouble();
    this->window_y = this->value("window/y").toDouble();
    this->window_width = this->value("window/width").toDouble();
    this->window_height = this->value("window/height").toDouble();
    this->journals = this->value("data/journals").toStringList();
    this->encrypted = this->value("general/encrypted").toBool();

}

Settings::~Settings() {}
