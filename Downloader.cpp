#include "Downloader.h"

Downloader::Downloader(QObject *parent) :
    QObject(parent)
{
    connect(&_WebCtrl, SIGNAL (finished(QNetworkReply*)), this, SLOT (fileDownloaded(QNetworkReply*)));
}

Downloader::~Downloader()
{

}

QByteArray Downloader::downloadedData() const
{
    return _DownloadedData;
}

void Downloader::Download(QUrl url)
{
    QNetworkRequest request(url);
    _WebCtrl.get(request);
}

void Downloader::fileDownloaded(QNetworkReply *reply)
{
    if(reply->error() == QNetworkReply::NoError)
    {
        _DownloadedData = reply->readAll();
        emit downloaded();
    } else
        emit errDownload();
}
