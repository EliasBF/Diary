#include <QDir>
#include <QSaveFile>
#include <QFile>
#include <QDebug>

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
        this->setValue("window/width", 1000.0);
        this->setValue("window/height", 600.0);

        // Journals
        this->setValue("data/journals", QStringList());

        // General
        this->setValue("General/encrypted", true);
        this->setValue("General/path", this->fileName().remove("diary.conf"));
        this->setValue("General/configured", false);

    }
    
    this->window_x = this->value("window/x").toDouble();
    this->window_y = this->value("window/y").toDouble();
    this->window_width = this->value("window/width").toDouble();
    this->window_height = this->value("window/height").toDouble();
    this->journals = this->value("data/journals").toStringList();
    this->encrypted = this->value("General/encrypted").toBool();
    this->path = this->value("General/path").toString();

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
    QSaveFile journal_file(filename);
    journal_file.open(QIODevice::WriteOnly);
    journal_file.commit();
    return (name + "#" + filename);
}

void Settings::setKey(QByteArray key) {
    
    QString filename = (this->getPath() + ".key");
    QSaveFile keyfile(filename);
    if ( keyfile.open(QIODevice::WriteOnly) ) {
        keyfile.write(key);
        keyfile.commit();
    }

}

QByteArray Settings::readKey() {
    QString filename = (this->getPath() + ".key");
    QFile keyfile(filename);
    keyfile.open(QIODevice::ReadOnly);
    QByteArray key = keyfile.readAll();
    return key;
}
