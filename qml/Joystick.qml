import QtQuick 2.4
import QtQuick.Controls 1.2
import "Database.js" as Db

MyPage {
    id: game
    objectName: "qmlJoystick"

    title: qsTr("Chat wheel")

    MySettings { id: mysettings }

    property url background: "qrc:/images/joystick/joystick-bg.png"
    property url finger: "qrc:/images/joystick/joystick-finger.png"
    property url glow: "qrc:/images/joystick/joystick-glow.png"

    signal signalClear()

    property bool ready: false

    BusyIndicator {
        z: 10
        anchors.fill: parent
        anchors.centerIn: parent
        visible: root.ready == false

        running: root.ready == false
    }

    MouseArea {
        id: mouse
        property real fingerAngle : Math.atan2(mouseX, mouseY)
        property int mcx : mouseX - joystick.width * 0.5
        property int mcy : mouseY - joystick.height * 0.5
        property bool fingerInBounds : fingerDistance2 < distanceBound2
        property real fingerDistance2 : mcx * mcx + mcy * mcy
        property real distanceBound : joystick.width * 0.5 - thumb.width * 0.5
        property real distanceBound2 : distanceBound * distanceBound

        property double signal_x : (mouseX - joystick.width/2) / distanceBound
        property double signal_y : -(mouseY - joystick.height/2) / distanceBound

        property bool activated: false

        anchors.fill: parent

        onPressed: {
            returnAnimation.stop();

            mcx = mouseX - width * 0.5
            mcy = mouseY - height * 0.5

            activated = fingerInBounds
            handleThumbPos()
        }

        onReleased: {
            container.release()
            returnAnimation.restart()
            activated = false
        }

        onPositionChanged: handleThumbPos()

        function handleThumbPos() {
            if (activated)
            {
                mcx = mouseX - width * 0.5
                mcy = mouseY - height * 0.5
                if (fingerInBounds) {
                    thumb.anchors.horizontalCenterOffset = mcx
                    thumb.anchors.verticalCenterOffset = mcy
                } else {
                    var angle = Math.atan2(mcy, mcx)
                    thumb.anchors.horizontalCenterOffset = Math.cos(angle) * distanceBound
                    thumb.anchors.verticalCenterOffset = Math.sin(angle) * distanceBound
                }

                container.checkActivation();
            }
        }
    }

    Rectangle{
        id: root
        color: "transparent"
        visible: game.ready
        anchors.centerIn: parent
        width: (parent.width > parent.height ? parent.height : parent.width) * 0.6
        height: root.width
        Image {
            id: joystick
            anchors.fill: parent

            property real angle : 0
            property real distance : 0

            source: game.background
            anchors.centerIn: parent

            ParallelAnimation {
                id: returnAnimation
                NumberAnimation { target: thumb.anchors; property: "horizontalCenterOffset";
                    to: 0; duration: 200; easing.type: Easing.OutSine }
                NumberAnimation { target: thumb.anchors; property: "verticalCenterOffset";
                    to: 0; duration: 200; easing.type: Easing.OutSine }
            }

            Image {
                id: thumb
                width: joystick.width / 5
                height: joystick.height / 5
                source: game.finger
                anchors.centerIn: parent
            }
        }


        Item {
            objectName: "qmlContainer"
            id: container
            anchors.fill: parent
            onWidthChanged: {
                acceptWidthChange()
            }

            function acceptWidthChange()
            {
                var edge = width;
                var radius = width / 5 + edge / 2;
                var phi = 2 * Math.PI / children.length;
                for (var i = 0; i < children.length; i++)
                {
                    var x = radius * Math.sin(i * phi);
                    var y = radius * Math.cos(i * phi);
                    children[i].anchors.horizontalCenterOffset = x
                    children[i].anchors.verticalCenterOffset = y
                    children[i].width = width / 2;
                    var angle = 180 - i * phi * 180 / Math.PI;
                    children[i].rotation = Math.abs(angle) > 90 ? angle + 180 : angle;
                }
            }

            function load()
            {
                container.clear();

                var component = Qt.createComponent("Sample.qml");
                var items = Db.getSamplesOnJoystick()

                if (component.status == Component.Ready)
                {
                    for (var i = 0; i < 8; i++)
                    {
                        var itemHasSample = false
                        for (var j = 0; j < items.length; j++)
                            if (items[j].pos == i)
                            {
                                itemHasSample = true;
                                break;
                            }

                        component.createObject(container, {"name": itemHasSample ? items[j].name : "",
                                                           "uuid": itemHasSample ? items[j].uuid : "NONE " + i,
                                                           "category": itemHasSample ? items[j].category : "",
                                                           "pos": i,
                                                           "color": mysettings.joysticTextColor});

                    }

                    container.acceptWidthChange();
                    game.ready = true
                }
            }



            function checkActivation()
            {
                var x = thumb.anchors.horizontalCenterOffset;
                var y = thumb.anchors.verticalCenterOffset;
                var triggerLength = width / 5 + (root.width / 2) / 2;
                var minLength = triggerLength * 2;
                var index = -1;
                for (var i = 0; i < children.length; i++)
                {
                    var m_x = children[i].anchors.horizontalCenterOffset;
                    var m_y = children[i].anchors.verticalCenterOffset;
                    var curLength = Math.sqrt(Math.pow((x - m_x), 2) + Math.pow((y - m_y), 2));
                    if (curLength < minLength)
                    {
                        minLength = curLength;
                        index = i;
                    }
                }

                if (minLength < triggerLength && index >= 0)
                    children[index].highlight();

                for (i = 0; i < children.length; i++)
                    if (i != index || index < 0)
                        children[i].lowlight();
            }

            function release()
            {
//                for (var i = 0; i < children.length; i++)
//                    children[i].stop();

                for (var i = 0; i < children.length; i++)
                {
                    children[i].play();
                    children[i].lowlight();
                }
            }

            function clear()
            {
                for (var i = container.children.length ; i > 0; i--)
                    container.children[i-1].destroy();
                container.children = []
            }
        }
    }

    Component.onCompleted: { Db.init(); container.acceptWidthChange(); }
    onWidthChanged: container.acceptWidthChange();

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

    function clear()
    {
        container.clear()
        game.ready = false
    }
}
