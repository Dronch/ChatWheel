#include "DownloadManager.h"

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

DownloadManager::DownloadManager(QObject *parent) :
    QObject(parent),
    _progress(0)
{

}

void DownloadManager::clear()
{
    _folders.clear();
    _progress = 0;

    foreach (QObject* obj, _downloaders)
        delete obj;

    _downloaders.clear();
}

void DownloadManager::downloadSamplesPreviewList()
{
    clear();
    Downloader* downloader = new Downloader();
    connect(downloader, SIGNAL(downloaded()), this, SLOT(downloadSamplesPreviewListCompleted()));
    downloader->Download(QUrl("http://" + tr(HOST)));
    _downloaders.append(downloader);
}

void DownloadManager::downloadSamplesPreviewListCompleted()
{
    if (Sample::qmlLibrary == nullptr)
        return;

    Downloader* downloader = qobject_cast<Downloader*>(sender());

    QString strReply = (QString)downloader->downloadedData();

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
        _downloaders.append(downloader);
    }
}

void DownloadManager::downloadFolderIconCompleted()
{
    Downloader* downloader = qobject_cast<Downloader*>(sender());
    QByteArray data = downloader->downloadedData();
    QString name = downloader->property("foldername").toString();

    QPixmap pixmap;

    if(pixmap.loadFromData(data, "PNG") && _folders.contains(name))
       _folders[name]->setIcon(pixmap);

    if (++_progress == _folders.count())
        emit downloaded();
}

void DownloadManager::downloadFolderIconErr()
{
    if (++_progress == _folders.count())
        emit downloaded();
}
