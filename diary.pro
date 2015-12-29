TEMPLATE = app
CONFIG += qt c++11
unix:CONFIG += x11
win32:CONFIG += windows
QT += qml quick
TARGET = diary

unix:DESTDIR = build
unix:MOC_DIR = build/moc
unix:OBJECTS_DIR = build/obj
unix:RCC_DIR = build/rcc

INCLUDEPATH += .
unix:INCLUDEPATH += /usr/include
#win32:INCLUDEPATH +=

unix:LIBPATH += /usr/lib
#win32:LIBPATH +=

unix:LIBS += -lcryptopp
#win32:LIBS +=

unix:QML_IMPORT_PATH += /usr/lib/qt/qml/QtQml

# Input
HEADERS += src/settings.h \
       src/application.h \
	   src/diary.h
SOURCES += src/settings.cpp \
       src/application.cpp \
	   src/diary.cpp \
	   src/main.cpp
RESOURCES += resources.qrc
OTHER_FILES += resources/qml/BaseApplication.qml \
	       resources/qml/DiaryWindow.qml \
	       resources/qml/MainPage.qml \
	       resources/qml/Diary.qml \
	       resources/images/logo.png