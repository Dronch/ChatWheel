#include "DownloadManager.h"

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

DownloadManager::DownloadManager(QObject *parent) :
    QObject(parent),
    _progress(0)
{

}

void DownloadManager::downloadSamplesPreviewList()
{
    _folders.clear();
    _progress = 0;

    Downloader* downloader = new Downloader();
    connect(downloader, SIGNAL(downloaded()), this, SLOT(downloadSamplesPreviewListCompleted()));
    connect(downloader, SIGNAL(errDownload()), downloader, SLOT(deleteLater()));
    downloader->Download(QUrl("http://" + tr(HOST)));
}

void DownloadManager::downloadSamplesPreviewListCompleted()
{
    Downloader* downloader = qobject_cast<Downloader*>(sender());

    QString strReply = (QString)downloader->downloadedData();

    downloader->deleteLater();

    QJsonDocument jsonResponse = QJsonDocument::fromJson(strReply.toUtf8());

    QJsonObject jsonObject = jsonResponse.object();

    QJsonArray jsonArray = jsonObject["samples"].toArray();

    for (int i = 0; i < jsonArray.count(); i++)
    {
        QJsonObject jsonSample = jsonArray.at(i).toObject();
        QString name = jsonSample["name"].toString();
        QString uuid = jsonSample["uuid"].toString();
        QString category = jsonSample["category"].toString();

        if (!_folders.contains(category))
            _folders.insert(category, Folder::create(category));

        _folders[category]->samples.insert(uuid, Sample::create(name, uuid, category));
    }

    foreach (Folder* folder, _folders) {
        downloader = new Downloader();
        downloader->setProperty("foldername", QVariant(folder->name()));
        connect(downloader, SIGNAL(downloaded()), this, SLOT(downloadFolderIconCompleted()));
        connect(downloader, SIGNAL(errDownload()), this, SLOT(downloadFolderIconErr()));
        downloader->Download(QUrl("http://" + tr(HOST) + "/category/" + folder->name()));
    }
}

void DownloadManager::downloadFolderIconCompleted()
{
    Downloader* downloader = qobject_cast<Downloader*>(sender());
    QByteArray data = downloader->downloadedData();
    QString name = downloader->property("foldername").toString();
    downloader->deleteLater();

    QPixmap pixmap;

    if(pixmap.loadFromData(data, "PNG"))
       _folders[name]->setIcon(pixmap);

    if (++_progress == _folders.count())
        emit downloaded();
}

void DownloadManager::downloadFolderIconErr()
{
    sender()->deleteLater();

    if (++_progress == _folders.count())
        emit downloaded();
}
