#ifndef KERNEL_H
#define KERNEL_H

#include <QObject>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QUrl>

#include "DownloadManager.h"
#include "IconsImageProvider.h"

class Kernel : public QObject
{
    Q_OBJECT
public:
    explicit Kernel(QQmlEngine* engine, QObject *rootObject, QObject *parent = 0);
    ~Kernel();

private:
    QQmlEngine* _engine;

    QObject *_rootObject;
    QObject *_menuObject;
    QObject *_libraryObject;
    QObject *_downloadsObject;
    QObject *_joystickObject;

    DownloadManager _downloadManager;
    IconsImageProvider* _iconsImageProvider;

    QMap<QString, Sample*> _samples;
    void qmlObjectsSet(QObject *qmlObject, QMap<QString, Sample*> &samples);


signals:

private slots:
    void samplesClear();

    void buildSamples();

    void buildDownloads();

    void buildLibraryList();

    void componentReady(QVariant);

    void itemReady(QVariant);
};

#endif // KERNEL_H
