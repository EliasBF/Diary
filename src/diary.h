/*

    diary.diary
    ~~~~~~~~~~~

    Clases para representar los diarios y las entradas de cada uno

*/

#ifndef __DIARY_H

    #define __DIARY_H

    #include <QObject>
    #include <QRegExp>
    #include <QDateTime>
    #include <QString>
    #include <QStringList>
    #include <QMap>
    #include <QList>
    #include <QVariant>


    class Journal;


    class Entry : public QObject {

        Q_OBJECT
    
        Q_PROPERTY(
            QDateTime date
            MEMBER _date
            READ getDate
            WRITE setDate
            NOTIFY dateChanged
        )
        Q_PROPERTY(
            QString title
            MEMBER _title
            READ getTitle
            WRITE setTitle
            NOTIFY titleChanged
        )
        Q_PROPERTY(
            QString body
            MEMBER _body
            READ getBody
            WRITE setBody
            NOTIFY bodyChanged
        )
        Q_PROPERTY(
            bool starred
            MEMBER _starred
            READ getStarred
            WRITE setStarred
            NOTIFY starredChanged
        )

    public:

        Entry(
            Journal *jrnl,
            QDateTime date,
            QString title,
            QString body,
            bool starred
        );
        ~Entry();

        static QRegExp tag_regex(QStringList tagsymbols);
        QStringList parse_tags();
        QMap<QString, QVariant> to_map();
        bool equal(Entry other);

        inline QString getTitle() { return this->_title; };
        inline void setTitle(QString title) {
            this->_title = title;
            emit titleChanged(this->_title);
        };
        inline QString getBody() { return this->_body; };
        inline void setBody(QString body) {
            this->_body = body;
            emit bodyChanged(this->_body);
        };
        inline QDateTime getDate() { return this->_date; };
        inline void setDate(QDateTime date) {
            this->_date = date;
            emit dateChanged(this->_date);
        };
        inline bool getStarred() { return this->_starred; };
        inline void setStarred(bool starred) {
            this->_starred = starred;
            emit starredChanged(this->_starred);
        };

    private:

        Journal *jrnl;
        QDateTime _date;
        QString _title;
        QString _body;
        bool _starred;
        QStringList tags;
        bool modified;

    signals:

        void dateChanged(QDateTime date);
        void titleChanged(QString title);
        void bodyChanged(QString body);
        void starredChanged(bool starred);

    };


    class Journal : public QObject {

        Q_OBJECT
        Q_PROPERTY(
            QString name
            MEMBER _name
            READ getName
            WRITE setName
            NOTIFY nameChanged
        )

    public:

        Journal(
            QMap<QString, QVariant> args,
            QString name
        );
        ~Journal();

        int length();
        Entry new_entry(
            QString title,
            QString body,
            QDateTime date,
            bool sort
        );
        QList<Entry> sort();
        QList<Entry> filter(
            QStringList tags,
            QDateTime start_date,
            QDateTime end_date,
            bool starred,
            bool strict,
            bool _short
        );
        void write(QString filename);

        inline QString getName() { return this->_name; };
        inline void setName(QString name) { 
            this->_name = name;
            emit nameChanged(this->_name);
        };

    private:
    
        QMap<QString, QVariant> config;
        QString key;
        QStringList search_tags;
        QString _name;

        void encrypt();
        void decrypt();
        void make_key();
        void open();
        QList<Entry> parse();

    signals:
        void nameChanged(QString name);

    };

#endif // __DIARY_H
