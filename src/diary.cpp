/*

    diary.diary
    ~~~~~~~~~~~

    Clases para representar los diarios y las entradas de cada uno

*/


#include "diary.h"


/*
* Journal
*/

Journal::Journal(QMap<QString, QVariant> args, QString name) {
    this->config.swap(args);
    this->_name = name;

    this->open();
}

Journal::~Journal() {}

int Journal::length() {}

Entry Journal::new_entry(QString title, QString body, 
                         QDateTime date, bool sort) 
{}

QList<Entry> Journal::sort() {}

QList<Entry> Journal::filter(QStringList tags, QDateTime start_date,
                    QDateTime end_date, bool starred,
                    bool strict, bool _short)
{}

void Journal::write(QString filename) {}

void Journal::encrypt() {}

void Journal::decrypt() {}

void Journal::make_key() {}

void Journal::open() {}

QList<Entry> parse() {}


/*
* Entry
*/

Entry::Entry(Journal *jrnl, QDateTime date,
             QString title, QString body,
             bool starred) 
{
	this->jrnl = jrnl;
	this->_date = date;
	this->_title = title;
	this->_body = body;
	this->tags = this->parse_tags();
	this->_starred = starred;
	this->modified =false;
}

Entry::~Entry() {}

QRegExp Entry::tag_regex(QStringList tagsymbols) {}

QStringList Entry::parse_tags() {}

QMap<QString, QVariant> Entry::to_map() {}

bool Entry::equal(Entry other) {}
