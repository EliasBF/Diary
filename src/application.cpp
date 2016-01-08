#include <algorithm>

#include <QUrl>
#include <QDebug>
#include <QStringList>
#include <QCryptographicHash>
#include <QDateTime>
#include <QQmlContext>
#include <QTranslator>
#include <QLocale>
#include <QLibraryInfo>

#include "application.h"


DiaryApplication::DiaryApplication(int &argc, char *argv[])
: app(argc, argv) {
    
    this->app.setOrganizationName("diary-project");
    this->app.setOrganizationDomain("diary-project.me");
    this->app.setApplicationName("diary");

    QTranslator qt_translator;
    qt_translator.load(
        "qt_" + QLocale::system().name(),
        QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    this->app.installTranslator(&qt_translator);

    QTranslator diary_translator;
    diary_translator.load("qrc:/translations/" + QLocale::system().name());
    this->app.installTranslator(&diary_translator);

    this->settings = new Settings();

}

DiaryApplication::~DiaryApplication() {}


int DiaryApplication::run() {

    this->app_engine = new QQmlApplicationEngine();
    this->app_engine->load(QUrl("qrc:/resources/qml/Diary.qml"));

    this->setRootAndLoad(this->app_engine->rootObjects().first());
        
    return this->app.exec();

}

void DiaryApplication::setRootAndLoad(QObject *root) {
    
    if ( this->root != 0 ) { this->root->disconnect(this); }

    this->root = root;

    QObject::connect(
        this->root,
        SIGNAL(selectedJournal(QString)),
        this,
        SLOT(loadJournal(QString))
    );
    QObject::connect(
        this->root,
        SIGNAL(createdJournal(QString)),
        this,
        SLOT(new_journal(QString))
    );
    QObject::connect(
        this->root,
        SIGNAL(validatedKey(QString)),
        this,
        SLOT(authenticated(QString))
    );
    QObject::connect(
        this->root,
        SIGNAL(configuredDiary(QString, QString)),
        this,
        SLOT(prepareDiary(QString, QString))
    );
    QObject::connect(
        this->root,
        SIGNAL(configuredComplete()),
        this,
        SLOT(loadDiary())
    );

    this->loadDiary();

}

void DiaryApplication::prepareDiary(QString journal, QString key) {
    this->new_journal(journal);
    this->settings->setKey(this->make_key(key));
    this->settings->setConfigured(true);
    this->root->findChild<QQuickWindow*>("welcome")->setProperty("is_configured", true);
}

void DiaryApplication::loadDiary() {
    if ( this->settings->getConfigured() ) {
        this->root->setProperty("journals", this->list_journals());
        QMetaObject::invokeMethod(this->root, "startDiary");

        QMetaObject::invokeMethod(
            this->root,
            "load",
            Q_ARG(QVariant, QVariant::fromValue(false))
        );
    }
    else {
        QMetaObject::invokeMethod(
            this->root,
            "load",
            Q_ARG(QVariant, QVariant::fromValue(true))
        );
    }
}


QByteArray DiaryApplication::make_key(QString password) {
    return QCryptographicHash::hash(
        password.toUtf8(),
        QCryptographicHash::Sha3_512
    ).toHex();
}

void DiaryApplication::authenticated(QString key) {
    if ( this->settings->getKey() == this->make_key(key) ) {
        this->key = this->make_key(key);
        QMetaObject::invokeMethod(
            this->root->findChild<QQuickWindow*>("main_window"),
            "valid_key",
            Q_ARG(QVariant, QVariant::fromValue(key))
        );   
    }
    else {
        QMetaObject::invokeMethod(
            this->root->findChild<QQuickWindow*>("main_window"),
            "invalid_key"
        );
    }
}

void DiaryApplication::new_journal(QString name) {
    QStringList parts = this->settings->add_journal(name.toLower()).split("#");
    QVariantMap journal = {{parts[0], parts[1]}};
    this->root->setProperty("journals", journal);
}

void DiaryApplication::loadJournal(QString name) {
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
        this->root->findChild<QQuickWindow*>("main_window"),
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
