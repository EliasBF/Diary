/*
    diary.diary
    ~~~~~~~~~~~

    :copyright: (c) por Elias Becerra
    :license: GPL2, ver LICENSE para mas detalles
*/


#include <QObject>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QQuickWindow>


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
	QQmlEngine engine;
	QObject *root;
	QQuickWindow *main_view;

};
