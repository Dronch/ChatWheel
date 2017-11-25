TEMPLATE = app

QT += qml quick multimedia network
CONFIG += c++11

android: {
QT += androidextras
}

SOURCES += main.cpp \
    mydevice.cpp \
    Downloader.cpp \
    DownloadManager.cpp \
    Folder.cpp \
    IconsImageProvider.cpp \
    Kernel.cpp \
    Sample.cpp

RESOURCES += qml.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    mydevice.h \
    Downloader.h \
    DownloadManager.h \
    Folder.h \
    IconsImageProvider.h \
    Kernel.h \
    Sample.h \
    Config.h
