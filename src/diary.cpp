#include <QFile>
#include <QTextStream>
#include <QRegularExpressionMatch>
#include <QRegularExpressionMatchIterator>
#include <QDebug>
#include <QMetaObject>

#include <algorithm>

#include "diary.h"
#include "cryptfiledevice.h"


Journal::Journal(QString name, QString filename, QObject *parent)
: QObject(parent) {
    
    this->_name = name;
    this->filename = filename;
    this->open();
}

Journal::~Journal() {
    while ( !this->entries.isEmpty() ) {
        delete this->entries.takeFirst();
    }
    this->entries.clear();
}

int Journal::length() {
    return this->entries.count();
}

void Journal::new_entry(QString title, QString body,
                        bool starred, QDateTime date) 
{
    Entry *new_entry = new Entry(
        this, date, title, body, starred
    );
    this->entries.prepend(new_entry);
    this->setTags(new_entry->getTags());

    QObject::connect(
        new_entry,
        SIGNAL(tagsChanged(QStringList)),
        this, 
        SLOT(setTags(QStringList))
    );
}

void Journal::new_entry(QString title, QString body, bool starred) {
    Entry *new_entry = new Entry(
        this, QDateTime::currentDateTime(), title, body, starred
    );
    this->entries.prepend(new_entry);
    this->setTags(new_entry->getTags());

    QObject::connect(
        new_entry,
        SIGNAL(tagsChanged(QStringList)),
        this, 
        SLOT(setTags(QStringList))
    );
}

void Journal::update_entry(QString title, QString body,
                           bool starred, int index) 
{
    QObject *entry = this->entries.at(index);

    QMetaObject::invokeMethod(
        entry, "setTitle", Q_ARG(QString, title)
    );
    QMetaObject::invokeMethod(
        entry, "setBody", Q_ARG(QString, body)
    );
    QMetaObject::invokeMethod(
        entry, "setStarred", Q_ARG(bool, starred)
    );

    entry = NULL;
}

void Journal::delete_entry(int index) {
    this->entries.removeAt(index);
}

void Journal::sort() {
    
    std::sort (
        this->entries.begin(),
        this->entries.end(),
        [&](QObject* entry_one, QObject* entry_two) -> bool {
            return entry_one->property("date").toDateTime() 
                   > entry_two->property("date").toDateTime();
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
                if (( !tags.isEmpty() &&
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
                if (( !tags.isEmpty() &&
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

QVariantMap Journal::getEntries() {
    QVariantMap entries;
    int index = 0;
    for ( QObject *entry : this->entries ) {
        QVariantMap n_entry;
        n_entry.insert("title", entry->property("title"));
        n_entry.insert("body", entry->property("body"));
        n_entry.insert("starred", entry->property("starred"));
        n_entry.insert("date", entry->property("date"));
        n_entry.insert("tags", entry->property("tags"));
        entries.insert(QString::number(index), n_entry);
        index++;
    }
    return entries;
}

QVariantList Journal::getTags() {
    QVariantList tags;
    for ( QString &tag : this->tags ) {
        tags << tag;
    }
    return tags;
}

void Journal::setTags(QStringList tags) {
    for (QString &tag : tags ) {
        if ( !this->tags.contains(tag) ) {
            this->tags.append(tag);
        }
    }
}

QObject* Journal::getEntry(int index) {
    return this->entries.at(index);
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
    
    bool encrypted;
    QMetaObject::invokeMethod(
        this->parent(), "getEncrypted", Q_RETURN_ARG(bool, encrypted)
    );
    if ( encrypted ) {
        this->encrypt(journal);
        return;
    }

    QFile journal_file(this->filename);
    
    if ( journal_file.open(QIODevice::WriteOnly) )
    {
        QTextStream stream(&journal_file);
        stream << journal;
        journal_file.close();
    }

}

void Journal::encrypt(QString journal) {
    QFile crypt_file(this->filename);
    CryptFileDevice crypt_device(
        &crypt_file,
        this->parent()->property("key").toByteArray(),
        QString("diary").toUtf8()
    );
    if ( !crypt_device.open(QIODevice::WriteOnly | QIODevice::Truncate) ) {
        return;
    }
    crypt_device.write(journal.toUtf8());
    crypt_device.close();
}

QString Journal::decrypt() {
    QFile crypt_file(this->filename);

    CryptFileDevice crypt_device(
        &crypt_file,
        this->parent()->property("key").toByteArray(),
        QString("diary").toUtf8()
    );
    if ( !crypt_device.open(QIODevice::ReadOnly) ) {
        return "";
    }
    QByteArray journal = crypt_device.readAll();
    crypt_device.close();
    return QString::fromUtf8(journal);
}

void Journal::open() {

    QFile journal_file(this->filename);

    bool encrypted;
    QMetaObject::invokeMethod(
        this->parent(), "getEncrypted", Q_RETURN_ARG(bool, encrypted)
    );

    if ( encrypted ) {
        this->parse(this->decrypt());
        return;
    }

    QString journal = "";

    if ( journal_file.open(QIODevice::ReadOnly) ) 
    {
        QTextStream stream(&journal_file);
        journal = stream.readAll();
        this->parse(journal);
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
        
        this->new_entry(new_title, new_body, starred, new_date);
    }

    this->sort();

}


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

QVariantMap Entry::to_map() {
    QVariantMap wrapper;
    QVariantMap entry;
    entry.insert("title", this->_title);
    entry.insert("body", this->_body);
    entry.insert("starred", this->_starred);
    entry.insert("date", this->_date);
    entry.insert("tags", this->tags);
    wrapper.insert("0", entry);
    return wrapper; 
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
