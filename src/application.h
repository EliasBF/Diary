/*

    diary.application
    ~~~~~~~~~~~~~~~~~

*/

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

    public:
	
        DiaryApplication(int &argc, char** argv);
    	~DiaryApplication();

	    // Interfaces
    	int run();
        inline QByteArray getKey() { return this->settings->getKey(); };
        QVariantMap list_journals();
        
    public slots:
    
        inline bool getEncrypted() { return this->settings->getEncrypted(); };
        void loadJournal(QString name, QString key);
        void new_journal(QString name);

    private:

	    // Atributos
    	QGuiApplication app;
    	QQmlApplicationEngine *app_engine;
        Settings *settings;
        Journal *active_journal;
        QObject *root;

        QByteArray make_key(QString password);
        void setRootObject(QObject *root);

    };

#endif // __APPLICATION_H
