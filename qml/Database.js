.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var db = Sql.LocalStorage.openDatabaseSync("joystick_db", "1.0", "storage data and settings", 100000);

function init() {
    db.transaction(
                function(tx){
                    tx.executeSql('CREATE TABLE IF NOT EXISTS library(uuid VARCHAR(50), name VARCHAR(20), category VARCHAR(20), pos INT);')
                }
                );
    db.transaction(
                function(tx){
                    tx.executeSql('CREATE TABLE IF NOT EXISTS icons(name VARCHAR(20), data TEXT);')
                }
                );
}

function getFolders(){
    var folders = []

    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT DISTINCT category FROM library ORDER BY category;');
                    for (var i = 0; i < rs.rows.length; i++)
                    {
                        var folder = {
                            name: rs.rows.item(i).category,
                            data: ""
                        }
                        folders.push(folder)
                    }
                }
                );

    for (var i = 0; i < folders.length; i++)
        folders[i].data = getIcon(folders[i].name)

    return folders;
}

function getFoldersWithDataToAdd(){
    var folders = []

    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT DISTINCT category FROM library ORDER BY category;');
                    for (var i = 0; i < rs.rows.length; i++)
                    {
                        var folder = {
                            name: rs.rows.item(i).category,
                            data: ""
                        }
                        if (getFreeRecords(folder.name).length > 0)
                            folders.push(folder)
                    }
                }
                );

    for (var i = 0; i < folders.length; i++)
        folders[i].data = getIcon(folders[i].name)

    return folders;
}

function getRecords(folder){
    var records = []

    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT * FROM library WHERE category=? ORDER BY name;', folder);
                    for (var i = 0; i < rs.rows.length; i++)
                    {
                        var record = {
                            uuid: rs.rows.item(i).uuid,
                            name: rs.rows.item(i).name,
                            category: rs.rows.item(i).category
                        }
                        records.push(record)
                    }
                }
                );

    return records;
}

function getFreeRecords(folder){
    var records = []

    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT * FROM library WHERE category=? AND pos=-1 ORDER BY name;', folder);
                    for (var i = 0; i < rs.rows.length; i++)
                    {
                        var record = {
                            uuid: rs.rows.item(i).uuid,
                            name: rs.rows.item(i).name,
                            category: rs.rows.item(i).category
                        }
                        records.push(record)
                    }
                }
                );

    return records;
}

function contains(uuid){
    var result = false;
    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT * FROM library WHERE uuid=?;', uuid);
                    result = rs.rows.length > 0
                }
                );

    return result;
}

function getSamplesOnJoystick()
{
    var records = []

    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT * FROM library WHERE pos>-1;');
                    for (var i = 0; i < rs.rows.length; i++)
                    {
                        var record = {
                            uuid: rs.rows.item(i).uuid,
                            name: rs.rows.item(i).name,
                            category: rs.rows.item(i).category,
                            pos: rs.rows.item(i).pos
                        }
                        records.push(record)
                    }
                }
                );

    return records;
}

function setPos(uuid, pos)
{
    db.transaction(
                function(tx){
                    tx.executeSql('UPDATE library SET pos=? WHERE uuid=?;', [pos, uuid]);
                }
                );
}

function insertRecord(uuid, name, category){
    db.transaction(
                function(tx){
                    tx.executeSql('INSERT INTO library VALUES(?, ?, ?, -1);', [uuid, name, category]);
                }
                );
}

function removeRecord(uuid){
    db.transaction(
                function(tx){
                    tx.executeSql('DELETE FROM library WHERE uuid=?;', [uuid]);
                }
                );
}

function insertIcon(name, data){
    removeIcon(name);
    db.transaction(
                function(tx){
                    tx.executeSql('INSERT INTO icons VALUES(?, ?);', [name, data]);
                }
                );
}

function removeIcon(name){
    db.transaction(
                function(tx){
                    tx.executeSql('DELETE FROM icons WHERE name=?;', [name]);
                }
                );
}

function getIcon(name){
    var icon = ""

    db.transaction(
                function(tx){
                    var rs = tx.executeSql('SELECT data FROM icons WHERE name=?;', [name]);
                    if (rs.rows.length > 0)
                        icon = rs.rows.item(0).data
                }
                );

    return icon;
}
