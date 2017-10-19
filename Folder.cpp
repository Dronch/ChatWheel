#include "Folder.h"

Folder::Folder(const QString &name, QObject *parent) :
    QObject(parent),
    _name(name)
{

}

Folder *Folder::create(const QString &name)
{
    return new Folder(name);
}
