#include "Sample.h"

#include <QFile>
#include <QBuffer>
#include <QAudioOutput>
#include <QNetworkAccessManager>
#include <QFile>

QString Sample::mediaPath = QString::null;
QObject* Sample::qmlLibrary = nullptr;

Sample::Sample(const QString &uuid) :
    QObject(),
    _qmlObject(nullptr),
    _uuid(uuid),
    _sound(nullptr),
    _mute(false)
{
    _soundPath = Sample::mediaPath + _uuid;

    if (addedToLibrary())
        loadSound();
}

Sample::~Sample()
{
    if (_sound != nullptr)
        delete _sound;

    if (!addedToLibrary())
        delFile();
}


Sample* Sample::create(const QString &name, const QString &uuid, const QString &cat)
{
    Sample* sample = new Sample(uuid);
    sample->setName(name);
    sample->setCategory(cat);
    return sample;
}

Sample* Sample::create(const QString &uuid)
{
    return new Sample(uuid);
}

void Sample::downloadSound()
{
    if (_name.isEmpty())
        return;

    QNetworkAccessManager* manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(soundDownloaded(QNetworkReply*)));
    QUrl url("http://" + tr(HOST) + "/media/" + _uuid);
    manager->get(QNetworkRequest(url));
}

void Sample::delFile()
{
    QFile file(_soundPath);
    if (file.exists())
        file.remove();
}

void Sample::play()
{
#ifdef QT_DEBUG
    QString debug = "Debug\n" + _uuid;
    if (_sound)
        debug += tr("\n") + _sound->fileName();
    if (_qmlObject == nullptr)
        debug += tr("\n") + "qmlObject = null";
    QMetaObject::invokeMethod(qmlLibrary, "debug", Q_ARG(QVariant, QVariant::fromValue(debug)));
#endif
    if (hasSound())
    {
        _sound->play();
        if (_qmlObject != nullptr)
            _qmlObject->setProperty("state", "ready");
    }
    else
        downloadSound();
}

void Sample::stop()
{
    if (hasSound())
        _sound->stop();
}

void Sample::setQmlObject(QObject *qmlObject)
{
    _qmlObject = qmlObject;
    _qmlObject->setProperty("inLib", QVariant(addedToLibrary()));
    connect(qmlObject, SIGNAL(signalPlay()), this, SLOT(play()));
    connect(qmlObject, SIGNAL(signalStop()), this, SLOT(stop()));
    connect(qmlObject, SIGNAL(signalAdd()), this, SLOT(addToLibrary()));
    connect(qmlObject, SIGNAL(signalDel()), this, SLOT(delFromLibrary()));
    connect(qmlObject, SIGNAL(signalChanged(QString, QString, QString)), this, SLOT(change(QString,QString,QString)));
}

bool Sample::addedToLibrary()
{
    QVariant returnedValue;
    QMetaObject::invokeMethod(qmlLibrary, "contains",
                              Q_RETURN_ARG(QVariant, returnedValue),
                              Q_ARG(QVariant, QVariant::fromValue(_uuid)));

    return returnedValue.toBool();
}

void Sample::addToLibrary()
{
    loadSound();
    QMetaObject::invokeMethod(qmlLibrary, "addToLibrary",
                              Q_ARG(QVariant, QVariant::fromValue(_uuid)),
                              Q_ARG(QVariant, QVariant::fromValue(_name)),
                              Q_ARG(QVariant, QVariant::fromValue(_category)));

    _qmlObject->setProperty("inLib", QVariant(true));
}

void Sample::delFromLibrary()
{
    QMetaObject::invokeMethod(qmlLibrary, "delFromLibrary",
                              Q_ARG(QVariant, QVariant::fromValue(_uuid)));
    delFile();

    _qmlObject->setProperty("inLib", QVariant(false));
    _qmlObject->setProperty("state", "ready");
}

void Sample::change(QString id, QString n, QString c)
{
    _uuid = id;
    _name = n;
    _category = c;

    _soundPath = Sample::mediaPath + _uuid;

    if (_sound != nullptr)
        delete _sound;
    _sound = nullptr;

    loadSound();
}

void Sample::loadSound()
{
    if (QFile(_soundPath).exists())
    {
        if (_sound != nullptr)
            delete _sound;

        _sound = new QSound(_soundPath);
        if (_qmlObject != nullptr)
            _qmlObject->setProperty("state", "ready");
    }
    else {
        _mute = true;
        downloadSound();
    }
}

void Sample::soundDownloaded(QNetworkReply *reply)
{
    if(reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QBuffer buffer(&data);
        buffer.open(QIODevice::ReadOnly);

        QFile file(_soundPath);
        file.open(QIODevice::WriteOnly);
        file.write(data);
        file.close();

        loadSound();
        if (_mute)
            _mute = false;
        else
            _sound->play();
        if (_qmlObject != nullptr)
            _qmlObject->setProperty("state", "ready");

    } else {
        qDebug() << reply->error();
    }

    reply->deleteLater();
}

