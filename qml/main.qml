import QtQuick 2.4
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import QtQuick.Controls 1.2

import mydevice 1.0

ApplicationWindow {
    id: app

    property string appTitle: "Chat wheel"
    signal componentCreated(variant obj)

    width: 360
    height: 640
    //width: 640
    //height: 360

    visible: true

    property alias dp: device.dp
    MyDevice { id: device }

    MySettings { id: mysettings }

    QtObject {
        id: palette
        property color darkPrimary: mysettings.darkPrimary
        property color primary: mysettings.primary
        property color lightPrimary: mysettings.lightPrimary
        property color text: mysettings.text
        property color accent: mysettings.accent
        property color primaryText: mysettings.primaryText
        property color secondaryText: mysettings.secondaryText
        property color divider: mysettings.divider

        property color currentHighlightItem: mysettings.currentHighlightItem
    }


    property int orientationPortrait: 1
    property int orientationLandscape: 2
    property int orientation: 0
    onWidthChanged: {
        if( width > height ) {
            app.orientation = app.orientationLandscape
        } else {
            app.orientation = app.orientationPortrait
        }
    }

    Settings {
        id: settings
    }

    property alias currentPage: loader.source

    property int durationOfMenuAnimation: 500
    property int menuWidth: app.orientation == app.orientationLandscape ? 300*app.dp : app.width*0.85
    property int widthOfSeizure: 15*app.dp
    property bool menuIsShown: Math.abs(menuView.x) < (menuWidth*0.5) ? true : false
    property real menuProgressOpening


    onClosing: {
        close.accepted = false
    }


    Rectangle {
        id: normalView
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        color: palette.lightPrimary

        focus: true
        Keys.onReleased: {
            if (event.key == Qt.Key_Back) {
                if(app.menuIsShown)
                    app.onMenu()
                else
                    loader.item.back()
                event.accepted=true;
            }
        }


        //*************************************************//
        Rectangle {
            id: menuBar
            z: 5
            anchors.top: parent.top
            anchors.topMargin: 0
            width: parent.width
            height: app.orientation == app.orientationLandscape ? 40*app.dp : 50*app.dp
            color: palette.darkPrimary
            Rectangle {
                id: menuButton
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 1.2*height
                height: parent.height
                scale: maMenuBar.pressed ? 1.2 : 1
                color: "transparent"
                MenuIconLive {
                    id: menuBackIcon
                    scale: (parent.height/height)*0.65
                    anchors.centerIn: parent
                    value: menuProgressOpening
                }
                MouseArea {
                    id: maMenuBar
                    anchors.fill: parent
                    onClicked: onMenu()
                }
                clip: true
            }
            Label {
                id: titleText
                anchors.left: menuButton.right
                anchors.verticalCenter: parent.verticalCenter
                text: appTitle
                font.pixelSize: 0.35*parent.height
                color: palette.text
            }
        }
        Image {
            id: imgShadow
            anchors.top: menuBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 6*app.dp
            z: 4
            source: "qrc:/images/shadow_title.png"
        }


        //*************************************************//
        Rectangle {
            id: menuView
            anchors.top: menuBar.bottom
            height: parent.height - menuBar.height
            width: menuWidth
            z: 3
            color: palette.lightPrimary
            property bool itemClicked: false
            MainMenu {
                id: mainMenu
                anchors.fill: parent
                onMenuItemClicked: {
                    onMenu()
                    loader.source = page
                    menuView.itemClicked = true
                }
            }
            x: -menuWidth

            Behavior on x { NumberAnimation { duration: app.durationOfMenuAnimation;
                    easing.type: Easing.OutQuad;
                    onRunningChanged: {
                        if (menuView.itemClicked && menuProgressOpening == 0 && running == false) {
                            app.componentCreated(loader.item)
                            menuView.itemClicked = false
                        }
                    }
                }
            }
            onXChanged: {
                menuProgressOpening = (1-Math.abs(menuView.x/menuWidth))
            }

            MouseArea {
                anchors.right: parent.right
                anchors.rightMargin: app.menuIsShown ? (menuWidth - app.width) : -widthOfSeizure
                anchors.top: parent.top
                width: app.menuIsShown ? (app.width - menuWidth) : widthOfSeizure
                height: parent.height
                drag {
                    target: menuView
                    axis: Drag.XAxis
                    minimumX: -menuView.width
                    maximumX: 0
                }
                onClicked: {
                    if(app.menuIsShown) app.onMenu()
                }
                onReleased: {
                    if( Math.abs(menuView.x) > 0.5*menuWidth ) {
                        menuView.x = -menuWidth //close the menu
                    } else {
                        menuView.x = 0 //fully opened
                    }
                }
            }
        }
        Image {
            id: imgShadowMenu
            anchors.top: menuBar.bottom
            anchors.bottom: menuView.bottom
            anchors.left: menuView.right
            width: 6*app.dp
            z: 5
            source: "qrc:/images/shadow_long.png"
            visible: menuView.x != -menuWidth
        }
        Rectangle {
            id: curtainMenu
            z: 1
            anchors.fill: parent
            color: "black"
            opacity: app.menuProgressOpening*0.5
        }


        //*************************************************//
        Loader {
            id: loader
            anchors.top: menuBar.bottom;
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            //asynchronous: true
            onStatusChanged: {
                if( status == Loader.Loading ) {
                    curtainLoading.visible = true
                    titleText.text = appTitle
                } else if( status == Loader.Ready ) {
                    curtainLoading.visible = false
                } else if( status == Loader.Error ) {
                    curtainLoading.visible = false
                }
            }
            onLoaded: {
                titleText.text = item.title
            }
            Rectangle {
                id: curtainLoading
                anchors.fill: parent
                visible: false
                color: "white"
                opacity: 0.8
                BusyIndicator {
                    anchors.centerIn: parent
                }
            }
        }
    }

    function onMenu() {
        menuView.x = app.menuIsShown ? -menuWidth : 0
    }

    Component.onCompleted: {
        currentPage = "Joystick.qml"
        mainMenu.currentItem = 0
    }

    function start()
    {
        componentCreated(loader.item)
    }
}
