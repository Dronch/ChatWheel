import QtQuick 2.5
import QtQuick.Controls 2.2
//import Qt.labs.controls 1.0

Item {
    id: root
    height: parent.height
    state: "ready"

    property string name: "sample"
    property string uuid: ""
    property string category: ""
    property bool inLib: false
    property bool choosed: false
    property color color: "#006699"

    signal signalPlay()
    signal signalStop()
    signal signalAdd()
    signal signalDel()
    signal signalChanged(string uuid, string name, string category)


    MyText {
        id: msignature
        text: root.name
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5
        visible: root.choosed
        width: parent.width - btns.width
        height: parent.height
        textColor: root.color
    }

    Text {
        id: signature
        text: root.name
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5
        width: parent.width
        visible: !root.choosed
        height: parent.height
        font.pointSize: 18
        color: root.color
    }


    Row{
        id: btns
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        anchors.right: parent.right
        anchors.leftMargin: 10
        height: parent.height

        MyButton {
            height: parent.height
            imgSrc: "qrc:/images/item-play.png"

            visible: root.state != "loading" && root.choosed

            onClicked: { root.state = "loading"; signalPlay(); }
        }

        MyButton {
            height: parent.height
            imgSrc: root.inLib ? "qrc:/images/item-del.png" : "qrc:/images/item-add.png"

            visible: root.state != "loading" && root.choosed

            onClicked: { root.state = "loading"; root.inLib ? signalDel() : signalAdd() }
        }

        BusyIndicator {
            id: busyIndicator
            z: 1
            height: parent.height

            visible: root.state == "loading"
            running: root.state == "loading"
        }
    }


    states: [
        State { name: "loading" },
        State { name: "ready" }
    ]
}
