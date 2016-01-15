#ifndef __APPLICATION_H

    #define __APPLICATION_H

    #include <QObject>
    #include <QGuiApplication>
    #include <QQmlApplicationEngine>
    #include <QQuickWindow>
    #include <QByteArray>
    #include <QVariant>

    #include "settings.h"
    #include "diary.h"


    class DiaryApplication : public QObject {

	    Q_OBJECT
        Q_PROPERTY(QByteArray key MEMBER key)

    public:
	
        DiaryApplication(int &argc, char** argv);
    	~DiaryApplication();

    	int run();
        inline QByteArray getKey() { return this->settings->getKey(); };
        QVariantMap list_journals();
        
    public slots:
        
        void prepareDiary(QString journal, QString key);
        void loadDiary();
        inline bool getEncrypted() { return this->settings->getEncrypted(); };
        void loadJournal(QString name);
        void new_journal(QString name);
        void authenticated(QString key);
        void sendEntry();
        void sendTags();
        void sendFilteredEntries(
            bool starred, QString tags,
            QDateTime date_start, QDateTime date_end
        );
        void sendEntries();

    private:

    	QGuiApplication app;
    	QQmlApplicationEngine *app_engine;
        Settings *settings;
        Journal *active_journal;
        QObject *root;
        QByteArray key;

        QByteArray make_key(QString password);
        void setRootAndLoad(QObject *root);

    };

#endif // __APPLICATION_H
