import QtQuick 2.0

Rectangle{
    id: root
    property string textColor: "#006699"
    color: "transparent"
    clip: true
    state: moving_text.text.length * moving_text.font.pointSize > root.width ? "long-text" : "short-text"
    onWidthChanged: root.state = moving_text.text.length * moving_text.font.pointSize > root.width ?
                        "long-text" : "short-text"


    property string text: ""

    onVisibleChanged: {
        moving_text.x = 0;
        longTextAnim.restart();
    }


    Text {
        id:moving_text
        text: root.text
        font.pointSize: 18
        color: root.textColor

        SequentialAnimation on x {
            id: longTextAnim
            loops: Animation.Infinite
            PropertyAnimation {
                id: forward
                duration: 3000
            }
            PropertyAnimation {
                id: backward
                duration: 3000
            }
        }
    }

    states: [
        State {
            name: "long-text"
            PropertyChanges {
                target: longTextAnim
                running: true
            }
            PropertyChanges {
                target: forward
                to: root.width - moving_text.text.length * moving_text.font.pointSize
            }
            PropertyChanges {
                target: backward
                to: root.width / 2
            }
        },
        State {
            name: "short-text"
            PropertyChanges {
                target: longTextAnim
                running: false
            }
            PropertyChanges {
                target: moving_text
                x: 0
            }
        }
    ]
}
