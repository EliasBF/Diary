/*

    diary.diary
    ~~~~~~~~~~~

    Clases para representar los diarios y las entradas de cada uno

*/

#include <QFile>
#include <QTextStream>
#include <QRegularExpressionMatch>
#include <QRegularExpressionMatchIterator>
#include <QDebug>
#include <QMetaObject>

#include <algorithm>

#include "diary.h"


/*
* Journal
*/

Journal::Journal(QString name, QString filename, QObject *parent)
: QObject(parent) {
    
    this->_name = name;
    this->filename = filename;
    this->open();
}

Journal::~Journal() {}

int Journal::length() {
    return this->entries.count();
}

void Journal::new_entry(QString title, QString body, 
                         QDateTime date, bool starred) 
{
    Entry *new_entry = new Entry(
        this, date, title, body, starred
    );
    this->entries.append(new_entry);
    this->sort();
}

void Journal::sort() {
    std::sort (
        this->entries.begin(),
        this->entries.end(),
        [&](QObject* entry_one, QObject* entry_two) -> bool {
            return entry_one->property("date").toDateTime() 
                   < entry_two->property("date").toDateTime();
        }
    );
}

QList<QObject*> Journal::filter(QStringList tags, QDateTime start_date,
                    QDateTime end_date, bool starred,
                    bool strict)
{

    QList<QObject*> filter_list;

    std::for_each(
        this->entries.begin(),
        this->entries.end(),
        [&](QObject *entry) {
            if ( strict ) {
                if (( !tags.isEmpty() ||
                     std::all_of(
                        tags.begin(),
                        tags.end(),
                        [&](QString &tag) {
                            return entry->property("tags").toStringList().contains(tag);
                        }
                     )
                   )
                   && ( !starred || entry->property("starred").toBool() )
                   && ( start_date.isNull() 
                        || entry->property("date").toDateTime() >= start_date )
                   && ( end_date.isNull() 
                        || entry->property("date").toDateTime() <= end_date ))
                {
                    filter_list.append(entry);
                }
            }
            else {
                if (( !tags.isEmpty() ||
                     std::any_of(
                        tags.begin(),
                        tags.end(),
                        [&](QString &tag) {
                            return entry->property("tags").toStringList().contains(tag);
                        }
                     )
                   )
                   && ( !starred || entry->property("starred").toBool() )
                   && ( start_date.isNull() 
                        || entry->property("date").toDateTime() >= start_date )
                   && ( end_date.isNull() 
                        || entry->property("date").toDateTime() <= end_date ))
                {
                    filter_list.append(entry);
                }
            }
        }
    );
    return filter_list;

}

void Journal::save() { this->write(); }

void Journal::write() {
    
    QString journal = "";
    
    std::for_each(
        this->entries.begin(),
        this->entries.end(),
        [&](QObject *entry) { 
            QString repr = "";
            QMetaObject::invokeMethod(
                entry, "unicode", Q_RETURN_ARG(QString, repr)
            );
            journal.append(repr);
        }
    );

    if ( this->parent()->property("encrypted").toBool() ) {
        journal = this->encrypt(journal);
    }

    QFile journal_file(this->filename);
    
    if ( journal_file.open(QIODevice::WriteOnly) )
    {
        QTextStream stream(&journal_file);
        stream << journal;
        journal_file.close();
    }

}

QString Journal::encrypt(QString journal) {}

QString Journal::decrypt(QString journal) {}

void Journal::open() {

    QFile journal_file(this->filename);
    QString journal = "";
    if ( journal_file.open(QIODevice::ReadOnly) ) 
    {
        QTextStream stream(&journal_file);
        journal = stream.readAll();
        if ( this->parent()->property("encrypted").toBool() ) {
            this->parse(this->decrypt(journal));
        }
        else {
            this->parse(journal);
        }
    }
    else {
        qDebug() << "El archivo de este journal no existe";
    }
}

void Journal::parse(QString journal) {

    int date_length = (
        QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm")
    ).count() + 2;
    
    for ( QString line : journal.split("\n", QString::SkipEmptyParts) ) {
        QStringList entry_parts = line.split(" ");
        QDateTime new_date = QDateTime::fromString(
                                entry_parts[0].replace("{s}", " "),
                                "dd/MM/yyyy HH:mm");
        bool starred = entry_parts[1].endsWith("*");
        if ( starred ) { entry_parts[1].remove(-1, 1); }
        QString new_title = entry_parts[1].replace("{s}", " ");
        QString new_body = entry_parts[2].replace(
            "{s}", " "
        ).replace(
            "{n}", "\n"
        );
        
        this->new_entry(new_title, new_body, new_date, starred);
    }

}


/*
* Entry
*/

Entry::Entry(QObject *parent, QDateTime date,
             QString title, QString body,
             bool starred) 
: QObject(parent)
{
	this->_date = date;
	this->_title = title;
	this->_body = body;
	this->tags = this->parse_tags();
	this->_starred = starred;
}

Entry::~Entry() {}

QRegularExpression Entry::tag_regex(QString tagsymbol) {
    QString pattern = "\\s([%1][\\w]+)";
    QRegularExpression regex(pattern.arg(QString(tagsymbol)));
    return regex;
}

QStringList Entry::parse_tags() {
    QString fulltext = (this->getTitle() + " " + this->getBody()).toLower();
    QRegularExpressionMatchIterator results = this->tag_regex("@").globalMatch(fulltext);
    QStringList tags;
    
    while ( results.hasNext() ) {
    	QRegularExpressionMatch tag = results.next();
    	tags << tag.captured(1);
    }
    
    return tags;
}

QMap<QString, QVariant> Entry::to_map() {
    return {
        {"title", this->getTitle()},
        {"body", this->getBody()},
        {"date", this->getDate()},
        {"starred", this->getStarred()}
    };
}

QString Entry::to_html() { return ""; }

bool Entry::equal(Entry &other) {
    if (( this->getDate() != other.getDate())
    || ( this->getTitle() != other.getTitle() )
    || ( this->getBody() != other.getBody() ))
    {
        return false;
    }
    else { return true; }
}

QString Entry::unicode() {
    QString date_str = this->getDate().toString("dd/MM/yyyy HH:mm").replace(" ", "{s}");
    QString title_str = this->getTitle().replace(" ", "{s}");
    if ( this->getStarred() ) { title_str += "*"; }
    QString body_str = this->getBody().replace(" ", "{s}").replace("\n", "{n}");
    QString temp = "%1 %2 %3 %4";
    return temp.arg(date_str).arg(title_str).arg(body_str).arg("\n");
}
