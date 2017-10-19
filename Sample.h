#ifndef SAMPLE_H
#define SAMPLE_H

#include <QObject>
#include <QSound>

#include "Downloader.h"
#include "Config.h"

class Sample : public QObject
{
    Q_OBJECT
public:
    explicit Sample(const QString &uuid);
    ~Sample();

    static QString mediaPath;
    static QObject* qmlLibrary;

    static Sample* create(const QString &name, const QString &uuid, const QString &cat);
    static Sample* create(const QString &uuid);

    void setName(const QString &name) { _name = name; }
    QString name() { return _name; }

    QString uuid() { return _uuid; }

    void setCategory(const QString &category) { _category = category; }
    QString category() { return _category; }

    bool hasSound() { return _sound != nullptr; }

    void setQmlObject(QObject* qmlObject);

    bool addedToLibrary();

private:
    QObject* _qmlObject;
    QString _name;
    QString _uuid;
    QString _category;
    QSound* _sound;
    QString _soundPath;

    void loadSound();
    void downloadSound();

    bool _mute;

    void delFile();

private slots:
    void soundDownloaded(QNetworkReply *reply);
    void play();
    void stop();
    void addToLibrary();
    void delFromLibrary();
    void change(QString, QString, QString);

};

#endif // SAMPLE_H
