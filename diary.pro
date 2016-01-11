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

unix:LIBS += -lcrypto
#win32:LIBS +=

unix:QML_IMPORT_PATH += /usr/lib/qt/qml/QtQml

lupdate_only {
    SOURCES = resources/qml/*.qml
}

# Input
HEADERS += src/settings.h \
           src/cryptfiledevice.h \
           src/application.h \
	   src/diary.h
SOURCES += src/settings.cpp \
           src/cryptfiledevice.cpp \
           src/application.cpp \
	   src/diary.cpp \
	   src/main.cpp
RESOURCES += resources.qrc

TRANSLATIONS = translations/en_EN.ts

OTHER_FILES += resources/qml/BaseApplication.qml \
	       resources/qml/DiaryWindow.qml \
               resources/qml/WelcomeWindow.qml \
	       resources/qml/MainPage.qml \
               resources/qml/KeyDialog.qml \
               resources/qml/SwitchDialog.qml \
               resources/qml/FilterDialog.qml \
	       resources/qml/Diary.qml \
	       resources/images/logo.png \
	       translations/en_EN.ts
