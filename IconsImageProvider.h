#ifndef ICONSIMAGEPROVIDER_H
#define ICONSIMAGEPROVIDER_H

#include <QQuickImageProvider>

class IconsImageProvider : public QQuickImageProvider
{
public:
    IconsImageProvider();

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);

    void add(const QString &id, QPixmap pixmap);

    void add(const QString &id, const QString &data);

    QString getIconData(const QString &id);

private:
    QMap<QString, QPixmap> _icons;
};

#endif // ICONSIMAGEPROVIDER_H
