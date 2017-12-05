import QtQuick 2.4
import QtQuick.Controls 2.2
//import Qt.labs.controls 1.0
import "Database.js" as Db

Item {
    id: root
    state: "lowlighted"
    anchors.centerIn: parent
    height: signature.font.pixelSize * 2
    z: (root.state == "highlighted" || mousearea.menuInvoked) ? 1 : 0

    property string name: "sample"
    property string uuid: ""
    property string category: ""
    property int pos: -1
    property color color: "#969b9e"

    rotation: 0
    transformOrigin: Item.Center
    antialiasing: true

    signal signalPlay()
    signal signalStop()
    signal signalAdd()
    signal signalDel()
    signal signalChanged(string uuid, string name, string category)

    Image {
        source: "qrc:/images/sample-bg.png"
        anchors.fill: parent
        scale: (root.state == "highlighted" || mousearea.menuInvoked) ? 1.3 : 1

        Rectangle{
            color:"transparent"
            clip: true
            width: parent.width * 0.8
            height: root.height
            anchors.centerIn: parent

            Text {
                id: signature
                color: root.color
                visible: root.state == "lowlighted" && !mousearea.menuInvoked
                text: root.name
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            MyText
            {
                text: root.name
                anchors.verticalCenter: parent.verticalCenter
                height: signature.height
                width: parent.width
                visible: root.state == "highlighted"  || mousearea.menuInvoked
                textColor: root.color
            }
        }

        Timer {
            id: timer
            interval: 1000
            running: false
            repeat: false
            onTriggered: mousearea.menuInvoked = true
        }

        MouseArea{
            id: mousearea
            anchors.fill: parent
            property bool menuInvoked: false

            onPressed: {
                timer.start()
            }

            onReleased: {
                timer.stop()
                if (menuInvoked)
                {
                    folderItems.init()
                    folderMenu.x = mouseX
                    folderMenu.y = mouseY
                    folderMenu.open()
                }
                menuInvoked = false
            }

            onExited: {
                timer.stop()
                menuInvoked = false
            }



            ListModel{
                id:folderItems
                function init() {
                    folderItems.clear()
                    var folders = Db.getFoldersWithDataToAdd()
                    for (var i = 0; i < folders.length; i++)
                        folderItems.append({"text": folders[i].name})
                }
            }

            Menu{
                id: folderMenu
                width: root.parent.parent.width
                MenuItem
                {
                    text: "..."
                    onTriggered: {
                        Db.setPos(root.uuid, -1)
                        root.uuid = ""
                        root.name = ""
                        root.category = ""
                        root.signalChanged(root.uuid, root.name, root.category)
                    }
                }
                Repeater {
                    model: folderItems
                    MenuItem {
                        text: modelData
                        onTriggered: {
                            sampleItems.init(text)
                            sampleMenu.x = folderMenu.x
                            sampleMenu.y = folderMenu.y
                            sampleMenu.open()
                        }
                    }
                }
            }

            ListModel{
                id:sampleItems
                function init(folder)
                {
                    sampleItems.clear()
                    var samples = Db.getFreeRecords(folder)
                    for (var i = 0; i < samples.length; i++)
                        sampleItems.append({"name": samples[i].name, "uuid": samples[i].uuid, "category": samples[i].category})
                }
            }

            Menu{
                id: sampleMenu
                width: root.parent.parent.width
                Repeater {
                    model: sampleItems
                    MenuItem {
                        text: model.name
                        property string uuid: model.uuid
                        property string category: model.category
                        onTriggered: {
                            Db.setPos(root.uuid, -1)
                            Db.setPos(uuid, pos)
                            root.uuid = uuid
                            root.name = name
                            root.category = category
                            root.signalChanged(root.uuid, root.name, root.category)
                            root.state = "highlighted"
                            root.state = "lowlighted"
                        }
                    }
                }
            }

        }
    }


    states: [
        State {
            name: "highlighted"
        },

        State {
            name: "lowlighted"
        }
    ]

    function highlight()
    {
        root.state = "highlighted"
    }

    function lowlight()
    {
        root.state = "lowlighted"
    }

    function play()
    {
        if (root.state == "highlighted")
            root.signalPlay();
    }

    function stop()
    {
        root.signalStop();
    }
}


