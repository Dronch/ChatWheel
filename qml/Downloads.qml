import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "Database.js" as Db

MyPage {
    id: root
    objectName: "qmlDownloads"

    title: qsTr("Downloads")

    MySettings { id: mysettings }

    property bool ready: false
    property int itemHeight: root.height / 5
    property color textColor: mysettings.textColor
    property color highlightColor: mysettings.highlightColor

    signal signalClear()

    BusyIndicator {
        z: 1
        anchors.centerIn: parent

        visible: root.ready == false
        running: root.ready == false
    }


    SwipeView {
        id: view
        currentIndex: 0
        anchors.fill: parent


        Item {
            Rectangle {
                color: "transparent"
                width: parent.width * 0.9
                height: parent.height * 0.9
                x: parent.width * 0.05
                y: parent.height * 0.05

                ListModel {
                    id: foldersListModel
                }

                ListView {
                    id: foldersView
                    highlightMoveVelocity: -1
                    model: foldersListModel
                    anchors.fill: parent
                    clip: true
                    delegate: Component {
                        Item {
                            width: parent.width
                            height: root.itemHeight

                            Row {
                                id: row
                                anchors.fill: parent
                                spacing: 10
                                Image {
                                    id: img
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: parent.height - signature.height - row.spacing
                                    width: parent.height - signature.height - row.spacing
                                    source: "image://icons/" + name
                                }
                                Text {
                                    id: signature
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: name
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pointSize: 18
                                    color: root.textColor
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: { foldersView.currentIndex = index; view.currentIndex = 1; }
                            }
                        }
                    }
                    highlight: Rectangle {
                        color: root.highlightColor
                    }
                    onCurrentItemChanged: { container.choosed(foldersListModel.get(foldersView.currentIndex).name); view.currentIndex = 0 }
                }
            }
        }

        Item {
            Rectangle {
                color: "transparent"
                width: parent.width * 0.9
                height: parent.height * 0.9
                x: parent.width * 0.05
                y: parent.height * 0.05

                Item {
                    objectName: "qmlContainer"
                    id: container
                    anchors.fill: parent

                    function load(folder, items)
                    {
                        var component = Qt.createComponent("Folder.qml");

                        if (component.status == Component.Ready)
                        {
                            var obj = component.createObject(container, {"folder": folder,
                                                                         "visible": false,
                                                                         "itemHeight": root.itemHeight / 3,
                                                                         "textColor": root.textColor,
                                                                         "highlightColor": root.highlightColor})
                            obj.init(items)
                        }
                    }

                    function choosed(folder)
                    {
                        for (var i = 0; i < container.children.length; i++)
                            container.children[i].visible = container.children[i].folder == folder;
                    }

                    function clear()
                    {
                        for (var i = 0; i < container.children.length; i++)
                            container.children[i].destroy();
                    }
                }

            }
        }
    }


    Component.onCompleted: Db.init();

    function contains(uuid)
    {
        return Db.contains(uuid)
    }

    function addToLibrary(uuid, name, category)
    {
        Db.insertRecord(uuid, name, category)
    }

    function delFromLibrary(uuid)
    {
        Db.removeRecord(uuid)
    }

    function addIcon(name, data)
    {
        Db.insertIcon(name, data)
    }

    function load(folder, items)
    {
        foldersListModel.append({ "name": folder })

        container.load(folder, items)
    }

    function clear()
    {
        foldersListModel.clear()
        container.clear()
        root.ready = false
        signalClear()
    }
}
