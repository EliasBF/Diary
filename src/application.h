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

    #include "settings.h"
    #include "diary.h"


    class DiaryApplication : public QObject {

	    Q_OBJECT

    public:
	
        DiaryApplication(int &argc, char** argv);
    	~DiaryApplication();

	    // Interfaces
    	int run();
        inline bool getEncrypted() { return this->settings->getEncrypted(); };
        inline QByteArray getKey() { return this->settings->getKey(); };
        void new_journal(QString name);
        Journal* loadJournal(QString name);

    private:

	    // Atributos
    	QGuiApplication app;
    	QQmlApplicationEngine *app_engine;
        Settings *settings;
        Journal *active_journal;

        QByteArray make_key(QString password);

    };

#endif // __APPLICATION_H
