/*
    diary.entry
    ~~~~~~~~~~~
*/


#include <QObject>
#include <QRegExp>
#include <QDatetime>
#include <QString>


class Journal : public QObject {

    Q_OBJECT

public:

    Journal(
        QString name="default",
        QMap<Qstring, QVariant> args
    );
    ~Journal();

    int length();
    Entry new_entry(
        QString title,
        QString body,
        QDateTime date=NULL,
        bool sort=true
    );
    QList<Entry> sort();
    QList<Entry> filter(
        QStringList tags=[],
        QDateTime start_date=NULL,
        QDateTime end_date=NULL,
        bool starred=false,
        bool strict=false,
        bool short=false
    );

private:
    
    QMap<QString, QVariant> config;
    QString key;
    QStringList search_tags;
    QString name;

    void encrypt();
    void decrypt();
    void make_key();
    void open();

public slots:
signals:

}


class Entry : public QObject {

    Q_OBJECT
    Q_PROPERTY(
        QDateTime date
        MEMBER date
        READ getDate
        WRITE setDate
        NOTIFY dateChanged
    )
    Q_PROPERTY(
        QString title
        MEMBER title
        READ getTitle
        WRITE setTitle
        NOTIFY titleChanged
    )
    Q_PROPERTY(
        QString body
        MEMBER body
        READ getBody
        WRITE setBody
        NOTIFY bodyChanged
    )
    Q_PROPERTY(
        bool starred
        MEMBER starred
        READ getStarred
        WRITE setStarred
        NOTIFY starredChanged
    )

public:

    Entry(
        Journal jrnl,
        QDateTime date=NULL,
        QString title="",
        QString body="",
        bool starred=false
    );
    ~Entry();

    static tag_regex(QList<QString> tagsymbols):
    QStringList parse_tags();

private:

    Journal jrnl;
    QDateTime date;
    QString title;
    QString body;
    bool starred;
    QStringList tags;
    bool modified;

}
