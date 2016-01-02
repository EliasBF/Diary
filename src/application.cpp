/*

    diary.application
    ~~~~~~~~~~~~~~~~~

*/


#include <algorithm>

#include <QUrl>
#include <QDebug>
#include <QStringList>
#include <QCryptographicHash>
#include <QDateTime>

#include "application.h"


DiaryApplication::DiaryApplication(int &argc, char *argv[])
: app(argc, argv) {
    
    this->app.setOrganizationName("diary-project");
    this->app.setOrganizationDomain("diary-project.me");
    this->app.setApplicationName("diary");

    this->settings = new Settings();

}

DiaryApplication::~DiaryApplication() {}


int DiaryApplication::run() {
    
    this->app_engine = new QQmlApplicationEngine();
    this->app_engine->load(QUrl("qrc:/resources/qml/Diary.qml"));
    
    //this->new_journal("default");

    /*this->active_journal = this->loadJournal("default", "elias");
    this->active_journal->new_entry(
        "Prueba",
        "Esta es una prueba",
        QDateTime::currentDateTime(),
        false
    );
    this->active_journal->save();
    
    qDebug() << this->active_journal->length();
    for ( QObject *entrie : this->active_journal->getEntries() ) {
    	qDebug() << "Entrada";
    	qDebug() << entrie->property("title");
    	qDebug() << entrie->property("body");
    	qDebug() << entrie->property("starred");
    	qDebug() << entrie->property("date");
    	qDebug() << "Fin Entrada";
    }*/
    
    /*this->settings->setKey(this->make_key("Elias5emotionalhardcore"));
    if (this->settings->getKey() == this->make_key("Elias5emotionalhardcore")) {qDebug() << "Son iguales";}
    else {qDebug() << "No son iguales";}
    if (this->settings->getKey() == this->make_key("El perro de maris juana")) {qDebug() << "Son iguales";}
    else {qDebug() << "No son iguales";}*/
        
    return this->app.exec();

}

QByteArray DiaryApplication::make_key(QString password) {
    return QCryptographicHash::hash(
        password.toUtf8(),
        QCryptographicHash::Sha3_512
    ).toHex();
}

void DiaryApplication::new_journal(QString name) {
    QString filename = this->settings->add_journal(name);
    /*Journal *jrnl = new Journal(
        name,
        filename,
        this
    );
    this->journals.append(jrnl);*/
}

Journal* DiaryApplication::loadJournal(QString name, QString key) {
    QString filename;
    for ( QString &journal : this->settings->getJournals() ) {
        if ( journal.contains(name) ) {
            filename = journal.split("#")[1];
            break;
        }
    }
    return new Journal(
        name,
        filename,
        key,
        this
    );
}
