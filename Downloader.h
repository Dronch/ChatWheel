#ifndef DOWNLOADER_H
#define DOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class Downloader : public QObject
{
    Q_OBJECT
public:
    explicit Downloader(QObject *parent = 0);
    ~Downloader();
    QByteArray downloadedData() const;
    void Download(QUrl url);

signals:
    void downloaded();
    void errDownload();

private slots:
    void fileDownloaded(QNetworkReply* reply);

private:
    QNetworkAccessManager _WebCtrl;
    QByteArray _DownloadedData;
};

#endif // DOWNLOADER_H
