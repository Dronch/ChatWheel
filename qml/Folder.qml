import QtQuick 2.5

Item {
    id: list
    anchors.fill: parent

    property int itemHeight: 75

    signal signalReady(variant obj)
    signal signalEmpty(string name)

    property string folder: ""
    property bool onlyInLib: false

    property color textColor: "#006699"
    property color highlightColor: "#93bcd1"

    function delItem(uuid)
    {
        if (onlyInLib)
        {
            for (var i = 0; i < itemListModel.count; i++)
                if (itemListModel.get(i).uuid == uuid)
                {
                    itemListModel.remove(i)
                    break
                }

            if (itemListModel.count == 0)
                list.signalEmpty(list.folder)
        }
    }

    ListModel {
        id: itemListModel
    }

    ListView {
        id: listView
        model: itemListModel
        anchors.fill: parent
        clip: true
        highlightMoveVelocity: -1
        delegate: Component{
            Item {
                width: parent.width
                height: list.itemHeight

                ItemSample {
                    anchors.verticalCenter: parent.verticalCenter
                    id: item
                    name: model.name;
                    uuid: model.uuid;
                    category: list.folder
                    height: list.itemHeight
                    width: parent.width;
                    onSignalDel: list.delItem(uuid)
                    Component.onCompleted: list.signalReady(this)
                    choosed: listView.currentIndex == index
                    color: list.textColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: listView.currentIndex = index
                    visible: listView.currentIndex != index
                }
            }
        }

        highlight: Rectangle {
            color: list.highlightColor
        }
    }

    function init(items)
    {
        itemListModel.clear()

        for (var i = 0; i < items.length; i++)
        {
            var data = items[i].split('|')
            itemListModel.append({ "uuid": data[0], "name": data[1] })
        }
    }
}
