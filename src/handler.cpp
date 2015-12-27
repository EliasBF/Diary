/*
    diary.diary.cpp
    ~~~~~~~~~~~~~~~

    :copyright: (c) por Elias Becerra
    :license: GPL2, ver LICENSE para mas detalles
*/


#include <QQmlComponent>
#include <QUrl>

#include "diary.h"


DiaryApplication::DiaryApplication(int &argc, char *argv[])
: app(argc, argv) {}

DiaryApplication::~DiaryApplication() {}


int DiaryApplication::run() {
    
    QQmlComponent *component = new QQmlComponent(&engine);
    component->loadUrl(QUrl("qrc:/resources/qml/main.qml"));
    root = component->create();
    main_view = qobject_cast<QQuickWindow*>(root);
    main_view->show();
    return app.exec();

}
