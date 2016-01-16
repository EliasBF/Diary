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
    this->active_journal = NULL;

}

DiaryApplication::~DiaryApplication() {  
    
    if ( this->active_journal != NULL ) {
        this->active_journal->save();
        delete this->active_journal;
        this->active_journal = NULL;
    }

    QQuickWindow *window;
    window = this->root->findChild<QQuickWindow*>("main_window");

    if ( window != 0 ) {

        this->settings->setWindowWidth(
            window->width()
        );
        this->settings->setWindowHeight(
            window->height()
        );
        this->settings->setWindowX(
            window->x()
        );
        this->settings->setWindowY(
            window->y()
        );
    }

    delete window; window = NULL;

    if ( this->settings != NULL ) {
        delete this->settings; this->settings = NULL;
    }
    if ( this->root != NULL ) {
        delete this->root; this->root = NULL;
    }
    if ( this->app_engine != NULL ) {
        delete this->app_engine; this->app_engine = NULL;
    }
}


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
    QObject::connect(
        this->root,
        SIGNAL(createdComplete()),
        this,
        SLOT(sendEntry())
    );
    QObject::connect(
        this->root,
        SIGNAL(requiredTags()),
        this,
        SLOT(sendTags())
    );
    QObject::connect(
        this->root,
        SIGNAL(filtered(bool, QString, QDateTime, QDateTime, bool)),
        this,
        SLOT(sendFilteredEntries(bool, QString, QDateTime, QDateTime, bool))
    );
    QObject::connect(
        this->root,
        SIGNAL(restoredEntries()),
        this,
        SLOT(sendEntries())
    );
    
    this->loadDiary();

}

void DiaryApplication::prepareDiary(QString journal, QString key) {
    this->new_journal(journal);
    this->settings->setKey(this->make_key(key));
    this->settings->setConfigured(true);
    this->root->findChild<QQuickWindow*>("welcome")->setProperty("is_configured", true);
}

void DiaryApplication::sendEntry() {
    if ( this->active_journal->length() ==
         this->root->property("entries_count").toInt()
       )
    {
        return;
    }
    else {
        QVariantMap wrapper_entry;
        QVariantMap entry;
        QMetaObject::invokeMethod(
            this->active_journal->getEntry(0),
            "to_map",
            Q_RETURN_ARG(QVariantMap, entry)
        );
        wrapper_entry.insert("0", entry);
        this->root->setProperty(
            "activeJournalEntries",
            wrapper_entry
        );
    }
}

void DiaryApplication::sendTags() {
    this->root->setProperty(
        "activeJournalTags",
        this->active_journal->getTags()
    );
}

void DiaryApplication::sendEntries() {
    this->root->setProperty(
        "activeJournalEntries",
        this->active_journal->getEntries()
    );
}

void DiaryApplication::sendFilteredEntries(
    bool starred, QString tags,
    QDateTime date_start, QDateTime date_end,
    bool strict
)
{
    QStringList tags_list;
    if ( tags.count() > 0 ) {
        if ( tags.contains("/") ) {
            tags_list = tags.split("/");
        }
        else {
            tags_list << tags;
        }
    }

    auto filter_list = this->active_journal->filter(
        tags_list, date_start, date_end, starred, strict
    );

    if ( filter_list.isEmpty() ) {
        QMetaObject::invokeMethod(
            this->root->findChild<QQuickWindow*>("main_window"),
            "no_match_filter"
        );
        return;
    }
    
    QVariantMap entries;
    int index = 0;

    for ( auto entry : filter_list ) {
        QVariantMap n_entry;
        QMetaObject::invokeMethod(
            entry, "to_map", Q_RETURN_ARG(QVariantMap, n_entry)
        );
        entries.insert(QString::number(index), n_entry);
        index++;
    }

    this->root->setProperty(
        "activeJournalEntries",
        entries
    );
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
        
        QQuickWindow *window;
        window = this->root->findChild<QQuickWindow*>("main_window");
        window->setProperty("width", this->settings->getWindowWidth());
        window->setProperty("height", this->settings->getWindowHeight());
        window->setProperty("x", this->settings->getWindowX());
        window->setProperty("y", this->settings->getWindowY());
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

    if ( this->active_journal != NULL ) {
        this->active_journal->save();
        this->root->disconnect(this->active_journal);
        delete this->active_journal;
        this->active_journal = NULL;
    }

    this->active_journal = new Journal(
        name.toLower(),
        filename,
        this
    );

    QObject::connect(
        this->root,
        SIGNAL(createdEntry(QString, QString, bool)),
        this->active_journal,
        SLOT(new_entry(QString, QString, bool))
    );
    QObject::connect(
        this->root,
        SIGNAL(updatedEntry(QString, QString, bool, int)),
        this->active_journal,
        SLOT(update_entry(QString, QString, bool, int))
    );
    QObject::connect(
        this->root,
        SIGNAL(updatedInFilter(QString, QString, bool)),
        this->active_journal,
        SLOT(update_entry(QString, QString, bool))
    );
    QObject::connect(
        this->root,
        SIGNAL(deletedEntry(int)),
        this->active_journal,
        SLOT(delete_entry(int))
    );
    QObject::connect(
        this->root,
        SIGNAL(deletedInFilter(QString)),
        this->active_journal,
        SLOT(delete_entry(QString))
    );

    this->root->setProperty(
        "activeJournalEntries",
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
