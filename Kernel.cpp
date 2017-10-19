#include "Kernel.h"

#include <QJsonObject>
#include <QUrl>
#include <QtNetwork/QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QBuffer>
#include <QAudioOutput>
#include <QThread>

#include <QDebug>
#include <QDir>
#include <QJSValueIterator>

Kernel::Kernel(QQmlEngine* engine, QObject *rootObject, QObject *parent) :
    QObject(parent),
    _engine(engine),
    _rootObject(rootObject),
    _iconsImageProvider(new IconsImageProvider())
{
    engine->addImageProvider(QLatin1String("icons"), _iconsImageProvider);

    _menuObject = _rootObject->findChild<QObject*>("qmlMenu");

    Sample::mediaPath = engine->offlineStoragePath() + '/' + "media" + '/';
    QDir dir(Sample::mediaPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    connect(_rootObject, SIGNAL(componentCreated(QVariant)), this, SLOT(componentReady(QVariant)));

    connect(&_downloadManager, SIGNAL(downloaded()), this, SLOT(buildDownloads()));

    QMetaObject::invokeMethod(_rootObject, "start");
}

Kernel::~Kernel()
{
    //delete _iconsImageProvider;
}

void Kernel::qmlObjectsSet(QObject *qmlObject, QMap<QString, Sample*> &samples)
{
    foreach (QObject* qmlItem, qmlObject->children())
    {
        QString name = qmlItem->property("name").toString();
        if (samples.contains(name))
            samples[name]->setQmlObject(qmlItem);
    }
}

void Kernel::samplesClear()
{
    foreach (Sample* sample, _samples)
        delete sample;

    _samples.clear();
}

void Kernel::buildSamples()
{
    QObject* containerObject = _joystickObject->findChild<QObject*>("qmlContainer");

    QMetaObject::invokeMethod(containerObject, "load");

    foreach (QObject* qmlItem, containerObject->children())
    {
        QString name = qmlItem->property("name").toString();
        QString uuid = qmlItem->property("uuid").toString();
        QString category = qmlItem->property("category").toString();
        if (uuid.isEmpty())
            continue;
        _samples.insert(uuid, Sample::create(name, uuid, category));
        if (_samples.contains(uuid))
            _samples[uuid]->setQmlObject(qmlItem);
    }
}

void Kernel::buildDownloads()
{
    QMap<QString, Folder*> folders = _downloadManager.folders();
    _downloadsObject->setProperty("ready", QVariant(true));

    _samples.clear();
    foreach (Folder* folder, folders)
    {
        _iconsImageProvider->add(folder->name(), folder->icon());

        QMetaObject::invokeMethod(_downloadsObject, "addIcon",
                                  Q_ARG(QVariant, QVariant::fromValue(folder->name())),
                                  Q_ARG(QVariant, QVariant::fromValue(_iconsImageProvider->getIconData(folder->name()))));

        QVariantList list;
        foreach (Sample* sample, folder->samples)
        {
            list << sample->uuid() + '|' + sample->name();
            _samples.insert(sample->uuid(), sample);
        }

        QMetaObject::invokeMethod(_downloadsObject, "load",
                                  Q_ARG(QVariant, QVariant(folder->name())),
                                  Q_ARG(QVariant, QVariant::fromValue(list)));
    }

    QObject* container = _downloadsObject->findChild<QObject*>("qmlContainer");
    foreach (QObject* folder, container->children())
        connect(folder, SIGNAL(signalReady(QVariant)), this, SLOT(itemReady(QVariant)));

}

void Kernel::buildLibraryList()
{
    QVariant returnedValue;
    QMetaObject::invokeMethod(_libraryObject, "getFolders",
                              Q_RETURN_ARG(QVariant, returnedValue));

    QJSValueIterator it(returnedValue.value<QJSValue>());
    while (it.hasNext()) {
        it.next();

        if (!it.hasNext())
            continue;

        QJSValueIterator pair(it.value());
        pair.next();
        QString data = pair.value().toString();
        pair.next();
        QString name = pair.value().toString();

        _iconsImageProvider->add(name, data);
    }

    QMetaObject::invokeMethod(_libraryObject, "updateRecords");

    QObject* container = _libraryObject->findChild<QObject*>("qmlContainer");
    foreach (QObject* folder, container->children())
        connect(folder, SIGNAL(signalReady(QVariant)), this, SLOT(itemReady(QVariant)));
}

void Kernel::componentReady(QVariant obj)
{
    QObject* qmlObject = obj.value<QObject*>();
    QString name = qmlObject->objectName();
    Sample::qmlLibrary = qmlObject;
    samplesClear();

    if (name == "qmlDownloads")
    {
        _downloadsObject = qmlObject;
        QMetaObject::invokeMethod(_downloadsObject, "clear");
        connect(_downloadsObject, SIGNAL(signalClear()), this, SLOT(samplesClear()));
        _downloadManager.downloadSamplesPreviewList();
    }

    if (name == "qmlLibrary")
    {
        _libraryObject = qmlObject;
        QMetaObject::invokeMethod(_libraryObject, "clear");
        connect(_libraryObject, SIGNAL(signalClear()), this, SLOT(samplesClear()));
        buildLibraryList();
    }

    if (name == "qmlJoystick")
    {
        _joystickObject = qmlObject;
        QMetaObject::invokeMethod(_joystickObject, "clear");
        connect(_joystickObject, SIGNAL(signalClear()), this, SLOT(samplesClear()));
        buildSamples();
    }
}

void Kernel::itemReady(QVariant obj)
{
    QObject* qmlObject = obj.value<QObject*>();
    QString uuid = qmlObject->property("uuid").toString();
    QString name = qmlObject->property("name").toString();
    QString category = qmlObject->property("category").toString();
    if (!_samples.contains(uuid))
        _samples.insert(uuid, Sample::create(name, uuid, category));
    _samples[uuid]->setQmlObject(qmlObject);
}



