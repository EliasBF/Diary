/*

    diary.settings
    ~~~~~~~~~~~~~~

*/


#include <QDir>
#include <QFile>

#include "settings.h"


Settings::Settings()
: QSettings(
    (Settings::createDirectory() + "diary.conf"),
    QSettings::NativeFormat
  )
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
        this->setValue("data/journals", QStringList());

        // General
        this->setValue("general/encrypted", false);
        this->setValue("general/path", this->fileName().remove("diary.conf"));

    }
    
    this->window_x = this->value("window/x").toDouble();
    this->window_y = this->value("window/y").toDouble();
    this->window_width = this->value("window/width").toDouble();
    this->window_height = this->value("window/height").toDouble();
    this->journals = this->value("data/journals").toStringList();
    this->encrypted = this->value("general/encrypted").toBool();
    this->path = this->value("general/path").toString();

}

Settings::~Settings() {}

QString Settings::createDirectory() {
    QDir homepath(QDir::homePath());
    homepath.mkpath(".diary/journals");
    return homepath.absolutePath() + "/.diary/";
}

QString Settings::add_journal(QString name) {
    QString filename = (this->getPath() + "journals/" + name + ".txt");
    QStringList update_journals = this->getJournals();
    update_journals << (name + "#" + filename);
    this->setJournals(update_journals);
    QFile(filename).open(QIODevice::WriteOnly);
    return filename;
}

void Settings::setKey(QByteArray key) {
    
    QString filename = (this->getPath() + ".key");
    QFile keyfile(filename);
    if ( keyfile.open(QIODevice::WriteOnly) ) {
        keyfile.write(key);
        keyfile.close();
    }

}

QByteArray Settings::readKey() {
    QString filename = (this->getPath() + ".key");
    QFile keyfile(filename);
    keyfile.open(QIODevice::ReadOnly);
    QByteArray key = keyfile.readAll();
    return key;
}
