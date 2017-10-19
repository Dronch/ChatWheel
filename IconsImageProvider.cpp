#include "IconsImageProvider.h"

#include <QBuffer>

IconsImageProvider::IconsImageProvider() :
    QQuickImageProvider(QQuickImageProvider::Pixmap)
{

}

QPixmap IconsImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)

    QPixmap result;

    if (_icons.contains(id))
        result = _icons[id];

    return result;
}

void IconsImageProvider::add(const QString &id, QPixmap pixmap)
{
    if (_icons.contains(id))
        _icons.remove(id);
    _icons.insert(id, pixmap);
}

void IconsImageProvider::add(const QString &id, const QString &data)
{
    QByteArray arr = QByteArray::fromBase64(data.toUtf8());
    add(id, QPixmap::fromImage(QImage::fromData(arr, "PNG")));
}

QString IconsImageProvider::getIconData(const QString &id)
{
    if (!_icons.contains(id))
        return QString::null;

    QImage img = _icons[id].toImage();
    QByteArray arr;
    QBuffer buffer(&arr);
    buffer.open(QIODevice::WriteOnly);
    img.save(&buffer, "PNG");

    return QString::fromUtf8(arr.toBase64());
}
