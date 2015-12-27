TEMPLATE = app
CONFIG += qt c++11
unix:CONFIG += x11
win32:CONFIG += windows
QT += qml quick
TARGET = diary

unix:DESTDIR = build
unix:OBJECTS_DIR = build/obj
unix:MOC_DIR = build/moc
unix:RCC_DIR = build/rcc

unix:INCLUDEPATH += /usr/include
#win32:INCLUDEPATH +=

unix:LIBPATH += /usr/lib
#win32:LIBPATH +=

unix:LIBS += -lsqlite3 -lcryptopp
#win32:LIBS +=

HEADERS += src/diary.h

SOURCES += src/main.cpp \
           src/diary.cpp

RESOURCES += resources.qrc

unix:QML_IMPORT_PATH += /usr/lib/qt/qml/QtQml

OTHER_FILES += resources/qml/main.qml
