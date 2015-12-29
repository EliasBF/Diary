/*
    diary.application
    ~~~~~~~~~~~~~~~~~

    :copyright: (c) por Elias Becerra
    :license: GPL2, ver LICENSE para mas detalles
*/


#include <QUrl>
#include <QDebug>

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
    qDebug() << this->settings->getEncrypted();
    /* qDebug() << app_engine->rootObjects()[0]->objectName();
    QObject::connect(
        app_engine, 
        SIGNAL(objectCreated(QObject*, QUrl)),
        this,
        SLOT(test(QObject*, QUrl))
    );*/
    return this->app.exec();

}

/*void DiaryApplication::test(QObject *object, QUrl url) {
    qDebug() << object->objectName();
    qDebug() << url;
}*/
