#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>

#include "Folder.h"
#include "Downloader.h"

class DownloadManager : public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(QObject *parent = nullptr);

    QMap<QString, Folder*> folders() { return _folders; }

    void clear();

private:
    QMap<QString, Folder*> _folders;
    int _progress;
    QList<QObject*> _downloaders;

signals:
    void downloaded();

public slots:
    void downloadSamplesPreviewList();

private slots:
    void downloadSamplesPreviewListCompleted();
    void downloadFolderIconCompleted();
    void downloadFolderIconErr();
};

#endif // DOWNLOADMANAGER_H
