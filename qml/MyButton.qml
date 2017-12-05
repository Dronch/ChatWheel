import QtQuick 2.0

Item {
    id: button
    property alias imgSrc: image.source
    scale: state === "Pressed" ? 0.75 : 1.0
    onEnabledChanged: state = ""
    signal clicked

    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    width: image.width
    height: image.sourceSize.height
    Image {
        id: image
        height: parent.height
        width: height/sourceSize.height * sourceSize.width

        anchors.horizontalCenter: parent.horizontalCenter
    }
    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        onEntered: { button.state='Hovering'}
        onExited: { button.state=''}
        onClicked: { button.clicked();}
        onPressed: { button.state="Pressed" }
        onReleased: {
            if (containsMouse)
              button.state="Hovering";
            else
              button.state="";
        }
    }
}
