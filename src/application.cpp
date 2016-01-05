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

    this->setRootObject(this->app_engine->rootObjects().first());

    this->root->setProperty("journals", this->list_journals());
    QMetaObject::invokeMethod(this->root, "startDiary");
    QMetaObject::invokeMethod(this->root, "load");
    
    //qDebug() << this->root->children()[4]->property("fullscreen");
    
    //this->new_journal("default");

    
    /*this->active_journal->new_entry(
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
    
    /*QMap<QString, QString> map = this->list_journals();
    qDebug() << map;*/
        
    return this->app.exec();

}

void DiaryApplication::setRootObject(QObject *root) {
    
    if ( this->root != 0 ) { this->root->disconnect(this); }

    this->root = root;

    if ( this->root ) {
        QObject::connect(
            this->root,
            SIGNAL(selectedJournal(QString, QString)),
            this,
            SLOT(loadJournal(QString, QString))
        );
        QObject::connect(
            this->root,
            SIGNAL(createdJournal(QString)),
            this,
            SLOT(new_journal(QString))
        );
    }
}


QByteArray DiaryApplication::make_key(QString password) {
    return QCryptographicHash::hash(
        password.toUtf8(),
        QCryptographicHash::Sha3_512
    ).toHex();
}

void DiaryApplication::new_journal(QString name) {
    QStringList parts = this->settings->add_journal(name.toLower()).split("#");
    QVariantMap journal = {{parts[0], parts[1]}};
    this->root->setProperty("journals", journal);
}

void DiaryApplication::loadJournal(QString name, QString key) {
    QString filename;
    for ( QString &journal : this->settings->getJournals() ) {
        if ( journal.contains(name.toLower()) ) {
            filename = journal.split("#")[1];
            break;
        }
    }
    this->active_journal = new Journal(
        name.toLower(),
        filename,
        key,
        this
    );

    this->root->setProperty(
        "active_journal_entries",
        this->active_journal->getEntries()
    );

    QMetaObject::invokeMethod(
        this->root,
        "activate_journal",
        Q_ARG(QVariant, QVariant::fromValue(name))
    );

    QMetaObject::invokeMethod(
        this->root->children()[4],
        "displayJournal",
        Q_ARG(QVariant, QVariant::fromValue(name))
    );
}

QVariantMap DiaryApplication::list_journals() {
    QVariantMap journals;
    for ( QString &journal : this->settings->getJournals() ) {
    	QStringList parts = journal.split("#");
        journals.insert(parts[0], parts[1]);
    }
    return journals;
}
