/*

    diary.application
    ~~~~~~~~~~~~~~~~~

*/


#include <algorithm>

#include <QUrl>
#include <QDebug>
#include <QStringList>
#include <QCryptographicHash>

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

    this->active_journal = this->loadJournal("default");
    this->active_journal->new_entry(
        "Super Test", 
        "Saluditos a todos mis @amigos los quiero saludar por este año nuevo.\n\nespero que les vaya muy bien este año.\n\nAdios.",
        QDateTime::currentDateTime(),
        false
    );
    this->active_journal->save();
    qDebug() << this->active_journal->length();
    //qDebug() << this->journals.count();
    //qDebug() << app_engine->rootObjects()[0]->objectName();
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

Journal* DiaryApplication::loadJournal(QString name) {
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
        this
    );
}
