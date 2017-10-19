import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import "Database.js" as Db

MyPage {
    id: root
    objectName: "qmlLibrary"

    title: qsTr("Library")


    property bool ready: false
    property int itemHeight: root.height / 5

    signal signalClear()

    BusyIndicator {
        z: 1
        anchors.fill: parent
        anchors.centerIn: parent

        running: root.ready == false
    }

    Rectangle {
        color: "transparent"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 5
        anchors.leftMargin: 5

       ListModel {
           id: foldersListModel
       }

       ListView {
           id: foldersView
           model: foldersListModel
           anchors.fill: parent
           clip: true
           delegate: Component {
               Item {
                   width: parent.width
                   height: root.itemHeight

                   Column {
                       id: col
                       anchors.fill: parent
                       spacing: 2
                   Image {
                       anchors.horizontalCenter: parent.horizontalCenter
                       height: parent.height - signature.height - col.spacing
                       width: parent.height - signature.height - col.spacing
                       source: "image://icons/" + name
                   }
                   Text {
                       id: signature
                       anchors.horizontalCenter: parent.horizontalCenter
                       text: name
                       verticalAlignment: Text.AlignBottom
                       horizontalAlignment: Text.AlignHCenter
                       font.pointSize: 10
                       color: "#006699"
                   }
                   }

                   MouseArea {
                       anchors.fill: parent
                       onClicked: foldersView.currentIndex = index
                   }
               }
           }
           highlight: Rectangle {
               color: "#93bcd1"
           }
           onCurrentItemChanged: container.choosed(foldersListModel.get(foldersView.currentIndex).name)
       }
    }

    Rectangle {
        id: list
        color: "transparent"
        anchors.left: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.leftMargin: 5

        Item {
            objectName: "qmlContainer"
            id: container
            anchors.fill: parent

            function load(folder, items)
            {
                var component = Qt.createComponent("Folder.qml");

                if (component.status == Component.Ready)
                {
                    var obj = component.createObject(container, {"folder": folder, "visible": false, "onlyInLib": true, "itemHeight": root.itemHeight})
                    obj.init(items)
                    obj.signalEmpty.connect(delFolder)
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

    function delFolder(name)
    {
        for (var i = 0; i < foldersListModel.count; i++)
            if (foldersListModel.get(i).name == name)
            {
                foldersListModel.remove(i)
                break
            }
    }

    Component.onCompleted: Db.init()

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

    function delIcon(name)
    {
        Db.removeIcon(name)
    }

    function getFolders()
    {
        return Db.getFolders()
    }

    function updateRecords()
    {
        foldersListModel.clear()
        container.clear()
        root.ready = false

        var folders = getFolders()

        for (var i = 0; i < folders.length; i++)
        {
            foldersListModel.append({ "name": folders[i].name })
            var data = Db.getRecords(folders[i].name)
            var items = []
            for (var j = 0; j < data.length; j++)
                items.push(data[j].uuid + '|' + data[j].name)
            container.load(folders[i].name, items)
        }

        root.ready = true
    }



    function clear()
    {
        foldersListModel.clear()
        container.clear()
        root.ready = false
        signalClear()
    }
}