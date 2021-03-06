#ifndef __DIARY_H

    #define __DIARY_H

    #include <QObject>
    #include <QRegularExpression>
    #include <QDateTime>
    #include <QString>
    #include <QStringList>
    #include <QMap>
    #include <QList>
    #include <QVariant>
    #include <QDir>


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
        Q_PROPERTY(
            QStringList tags
            MEMBER tags
            READ getTags
        )

    public:

        Entry(
            QObject *parent,
            QDateTime date,
            QString title,
            QString body,
            bool starred
        );
        ~Entry();

        static QRegularExpression tag_regex(QString tagsymbol);
        QString to_html();

    private:

        QDateTime _date;
        QString _title;
        QString _body;
        bool _starred;
        QStringList tags;

        QStringList parse_tags();

    signals:

        void dateChanged(QDateTime date);
        void titleChanged(QString title);
        void bodyChanged(QString body);
        void starredChanged(bool starred);
        void tagsChanged(QStringList tags);

    public slots:
        QString unicode();
        QVariantMap to_map();

        inline QString getTitle() { return this->_title; };
        inline void setTitle(QString title) {
            this->_title = title;
            this->setTags();
            emit titleChanged(this->_title);
        };
        inline QString getBody() { return this->_body; };
        inline void setBody(QString body) {
            this->_body = body;
            this->setTags();
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
        inline QStringList getTags() { return this->tags; };
        inline void setTags() {
            this->tags = this->parse_tags();
            emit tagsChanged(this->tags);
        }

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
            QString name,
            QString filename,
            QObject *parent
        );
        ~Journal();

        int length();
        void sort();
        QList<QObject*> filter(
            QStringList tags,
            QDateTime start_date,
            QDateTime end_date,
            bool starred,
            bool strict
        );
        void save();

        inline QString getName() { return this->_name; };
        inline void setName(QString name) { 
            this->_name = name;
            emit nameChanged(this->_name);
        };
        QVariantMap getEntries();
        QObject* getEntry(int index);
        void new_entry(
            QString title,
            QString body,
            bool starred,
            QDateTime date
        );

    private:
        
        QString filename;
        QStringList tags;
        QString _name;
        QList<QObject*> entries;

        void encrypt(QString);
        QString decrypt();
        void open();
        void write();
        void parse(QString journal);

    public slots:
        
        void new_entry(
            QString title,
            QString body,
            bool starred
        );
        void update_entry(
            QString title,
            QString body,
            bool starred,
            int index
        );
        void update_entry(
            QString title,
            QString body,
            bool starred
        );
        void delete_entry(int index);
        void delete_entry(QString title);

        QVariantList getTags();
        void setTags(QStringList tags);
        void removeTags(QStringList tags);

    signals:

        void nameChanged(QString name);

    };

#endif // __DIARY_H
