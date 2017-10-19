#ifndef FOLDER_H
#define FOLDER_H

#include <QObject>
#include <QPixmap>
#include <QMap>

#include "Sample.h"

class Folder : public QObject
{
    Q_OBJECT
public:
    explicit Folder(const QString &name, QObject *parent = nullptr);

    static Folder* create(const QString &name);

    QString name() { return _name; }

    void setIcon(const QPixmap &icon) { _icon = icon; }
    QPixmap icon() { return _icon; }

    QMap<QString, Sample*> samples;

private:
    QString _name;
    QPixmap _icon;
};

#endif // FOLDER_H
