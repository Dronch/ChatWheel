import QtQuick 2.4
import QtQuick.Controls 1.3
import "Database.js" as Db


MyPage {
    id: pageSettings

    title: qsTr("About")


    Label {
        anchors.centerIn: parent
        text: qsTr("About")
    }

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
}
