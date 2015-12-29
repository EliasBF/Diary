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

    #include "settings.h"


    class DiaryApplication : public QObject {

	    Q_OBJECT

    public:
	
        DiaryApplication(int &argc, char** argv);
    	~DiaryApplication();

	    // Interfaces
    	int run();

    private:

	    // Atributos
    	QGuiApplication app;
    	QQmlApplicationEngine *app_engine;
        Settings *settings;

    };

#endif // __APPLICATION_H
