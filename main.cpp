#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QThread>

#include "mydevice.h"
#include "Kernel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<MyDevice>("mydevice", 1, 0, "MyDevice");

    QQmlApplicationEngine engine;

    QQmlComponent component(&engine, QUrl(QLatin1String("qrc:/qml/main.qml")));
    QObject *rootObject = component.create();

    Kernel kernel(&engine, rootObject);

    return app.exec();
}
