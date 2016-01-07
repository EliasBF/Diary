/*

    diary.settings
    ~~~~~~~~~~~~~~

*/


#ifndef __SETTINGS_H
    #define __SETTINGS_H

    #include <QSettings>
    #include <QStringList>
    #include <QByteArray>


    class Settings : public QSettings {

        Q_OBJECT
        Q_PROPERTY(
            double windowX
            MEMBER window_x
            READ getWindowX
            WRITE setWindowX
            NOTIFY windowXChanged
        )
        Q_PROPERTY(
            double windowY
            MEMBER window_y
            READ getWindowY
            WRITE setWindowY
            NOTIFY windowYChanged
        )
        Q_PROPERTY(
            double windowWidth
            MEMBER window_width
            READ getWindowWidth
            WRITE setWindowWidth
            NOTIFY windowWidthChanged
        )
        Q_PROPERTY(
            double windowHeight
            MEMBER window_height
            READ getWindowHeight
            WRITE setWindowHeight
            NOTIFY windowHeightChanged
        )
        Q_PROPERTY(
            QStringList journals
            MEMBER journals
            READ getJournals
            WRITE setJournals
            NOTIFY journalsChanged
        )
        Q_PROPERTY(
            bool encrypted
            MEMBER encrypted
            READ getEncrypted
            WRITE setEncrypted
            NOTIFY encryptedChanged
        )

    public:

        Settings();
        ~Settings();

        static QString createDirectory();
        QString add_journal(QString name);

        inline double getWindowX() { return this->window_x; };
        inline void setWindowX(double x) {
            this->window_x = x;
            this->setValue("window/x", x);
            emit windowXChanged(this->window_x);
        };
        inline double getWindowY() { return this->window_y; };
        inline void setWindowY(double y) {
            this->window_y = y;
            this->setValue("window/y", y);
            emit windowYChanged(this->window_y);
        };
        inline double getWindowWidth() { return this->window_width; };
        inline void setWindowWidth(double width) {
            this->window_width = width;
            this->setValue("window/width", width);
            emit windowWidthChanged(this->window_width);
        };
        inline double getWindowHeight() { return this->window_height; };
        inline void setWindowHeight(double height) {
            this->window_height = height;
            this->setValue("window/height", height);
            emit windowHeightChanged(this->window_height);
        };
        inline QStringList getJournals() { return this->journals; };
        inline void setJournals(QStringList journals) {
            this->journals = journals;
            this->setValue("data/journals", journals);
            emit journalsChanged(this->journals);
        };
        inline bool getEncrypted() { return this->encrypted; };
        inline void setEncrypted(bool encrypted) {
            this->encrypted = encrypted;
            this->setValue("general/encrypted", encrypted);
            emit encryptedChanged(this->encrypted);
        };
        inline QByteArray getKey() { return this->readKey(); };
        void setKey(QByteArray key);
        inline QString getPath() { return this->path; };
        inline void setPath(QString path) {
            this->path = path;
            this->setValue("general/path", path);
        };
        inline bool getConfigured() {
            return this->value("General/configured").toBool();
        };
        inline void setConfigured(bool configured) {
            this->setValue("General/configured", configured);
        }

    private:

        double window_x;
        double window_y;
        double window_width;
        double window_height;
        QStringList journals;
        bool encrypted;
        QByteArray key;
        QString path;

        QByteArray readKey();

    signals:
        void windowXChanged(double x);
        void windowYChanged(double y);
        void windowWidthChanged(double width);
        void windowHeightChanged(double height);
        void journalsChanged(QStringList journals);
        void encryptedChanged(bool encrypted);
        void keyChanged(QByteArray key);

    };

#endif // __SETTINGS_H
