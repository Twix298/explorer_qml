import QtQuick 2.11
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.2 as Controls

Controls.ApplicationWindow {
    id: root
    property var currentPathModel: DirectoryModel.getCurrentPath()
    property int cutIndex: - 1
    property var cutDir: ""
    property var cutFile: ""
    property bool isCut: false
    property int typeView: 0    // 0 - таблица, 1 - список, 2 - значки

    Connections {
        target: DirectoryModel
        onDirectoryChanged: {
            currentPathModel =  DirectoryModel.getCurrentPath();
        }
    }
    width: 640
    height: 480
    visible: true
    color: "#2F343F"
    title: qsTr("Explorer")

    menuBar: MainMenu {
        id: mainMenu
    }

    Rectangle {
        id:title
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height * 0.2
        width: parent.width
        color: "#2F343F"

        Row {
            id: rowH1
            height:title.height * 0.33
            width: title.width
            anchors.top: mainMenu.bottom
            spacing: 10
            Image {
                id: imageDisk
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/image/diskImage.png"
                height: parent.height - 15
                width: parent.height - 15
            }
            TextInput {
                id: inputField
                anchors.verticalCenter: parent.verticalCenter
                width: 200
                height: rowH1.height
                text: currentPathModel
                font.pixelSize: 16
            }
        }


        Row {
            id: mainRow
            anchors.top: rowH1.bottom
            width: parent.width
            height: title.height * 0.33
            spacing: 2
            CustomButton {
                id: buttonReverse
                image: "qrc:/image/leftArroy.png"
                btnHeight: 25
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    DirectoryModel.reverse();
                    inputField.text = DirectoryModel.getCurrentPath();
                }
            }
            CustomButton {
                id: buttonHome
                image: "qrc:/image/homeImage.png"
                btnHeight: 25
                anchors.left: buttonReverse.right

                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    DirectoryModel.moveToHomeDir();
                    inputField.text = DirectoryModel.getCurrentPath();
                }
            }
            CustomButton {
                id: buttonReload
                text: "Обновить"
                btnHeight: 25
                anchors.left: buttonHome.right

                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    DirectoryModel.updateModel();
                    inputField.text = DirectoryModel.getCurrentPath();
                }
            }
            CustomButton {
                id: buttonTerminal
                text: "Терминал"
                btnHeight: 25
                anchors.left: buttonReload.right

                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    FileManager.runTerminal(DirectoryModel.getCurrentPath());
                }
            }
            CustomButton {
                id: buttonList
                image: "qrc:/image/tableView.png"
                btnHeight: 25
                anchors.right: buttonTable.left
                highlighted: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    buttonList.highlighted = true;
                    buttonTable.highlighted = false;
                    buttonIcons.highlighted = false;
                    listView.visible = true;
                    gridView.visible = false;
                    pictureGridView.visible = false
                    typeView = 0;
                }
            }
            CustomButton {
                id: buttonTable
                image: "qrc:/image/listView.png"
                btnHeight: 25
                anchors.right: buttonIcons.left
                highlighted: false
                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    buttonList.highlighted = false;
                    buttonTable.highlighted = true;
                    buttonIcons.highlighted = false;
                    listView.visible = false;
                    gridView.visible = true;
                    pictureGridView.visible = false
                    typeView = 1;
                }
            }
            CustomButton {
                id: buttonIcons
                image: "qrc:/image/picturedView.png"
                anchors.right: parent.right
                highlighted: false
                btnHeight: 25
                anchors.verticalCenter: parent.verticalCenter
                onClicked:  {
                    buttonList.highlighted = false;
                    buttonTable.highlighted = false;
                    buttonIcons.highlighted = true;
                    listView.visible = false;
                    gridView.visible = false;
                    pictureGridView.visible = true
                    typeView = 2;
                }
            }
        }
    }


    Menu {
        id:contextMenuEmpty
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: contextMenu.contentItem.highlighted ? "white" : "transparent"
        }
        MenuItem {
            text: "Обновить"
        }
        MenuItem {
            text: "Вставить"
            onTriggered: {
                FileManager.pasteAsync(DirectoryModel.getCurrentPath());
                console.log(cutDir + "/" + cutFile)
                if(isCut) {
                    FileManager.removeAsync(cutDir + "/" + cutFile);
                    cutIndex = -1;
                    cutFile = "";
                    cutDir = "";
                    isCut = false;
                }
                DirectoryModel.updateModel();
            }
        }
    }


    Menu {
        id: contextMenu
        MenuItem {
            text: "Копировать"
            onTriggered: {
                if(typeView === 0) {
                    console.log(listView.curIndex);
                    console.log(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(listView.curIndex));
                    FileManager.copyAsync(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(listView.curIndex));
                }
                else if(typeView === 1) {
                    console.log(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(gridView.curIndex));
                    FileManager.copyAsync(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(gridView.curIndex));
                }
                else if(typeView === 2) {
                    console.log(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(pictureGridView.curIndex));
                    FileManager.copyAsync(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(pictureGridView.curIndex));
                }


                DirectoryModel.updateModel();
            }
        }
        MenuItem {
            text: "Вставить"
            onTriggered: {
                FileManager.pasteAsync(DirectoryModel.getCurrentPath());
                console.log(cutDir + "/" + cutFile)
                if(isCut) {
                    FileManager.removeAsync(cutDir + "/" + cutFile);
                    cutIndex = -1;
                    cutFile = "";
                    cutDir = "";
                    isCut = false;
                }
                DirectoryModel.updateModel();
            }
        }
        MenuItem {
            text: "Вырезать"
            onTriggered:  {
                if(typeView === 0) {
                    FileManager.cutAsync(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(listView.curIndex));
                    cutIndex = listView.curIndex;
                    cutFile = DirectoryModel.getCurrentNameFile(listView.curIndex);

                }
                else if(typeView === 1) {
                    FileManager.cutAsync(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(gridView.curIndex));
                    cutIndex = gridView.curIndex;
                    cutFile = DirectoryModel.getCurrentNameFile(gridView.curIndex);
                }
                else if(typeView === 2) {
                    FileManager.cutAsync(DirectoryModel.getCurrentPath(), DirectoryModel.getCurrentNameFile(pictureGridView.curIndex));
                    cutIndex = pictureGridView.curIndex;
                    cutFile = DirectoryModel.getCurrentNameFile(pictureGridView.curIndex);
                }

                DirectoryModel.updateModel();
                cutDir = DirectoryModel.getCurrentPath();
                isCut = true;
            }
        }
        MenuItem {
            text: "Удалить"
            onTriggered: {
                if(typeView === 0) {
                    FileManager.removeAsync(DirectoryModel.getCurrentPath() + "/" + DirectoryModel.getCurrentNameFile(listView.curIndex));
                }
                else if(typeView === 1) {
                    FileManager.removeAsync(DirectoryModel.getCurrentPath() + "/" + DirectoryModel.getCurrentNameFile(gridView.curIndex));
                }
                else if(typeView === 2) {
                    FileManager.removeAsync(DirectoryModel.getCurrentPath() + "/" + DirectoryModel.getCurrentNameFile(pictureGridView.curIndex));
                }

                DirectoryModel.updateModel();
            }
        }

    }

    Rectangle {
        height: parent.height * 0.7
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: parent.height * 0.3
        color: "white"
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                console.log("Single rect")
                if (mouse.button === Qt.RightButton) {
                    contextMenuEmpty.popup();
                }
            }
        }
        ListView {
            id: listView
            property int curIndex: -1
            anchors.fill: parent
            implicitHeight: parent.height
            implicitWidth: parent.width
            model: DirectoryModel
            visible: true

            ScrollBar.vertical: ScrollBar{}

            delegate: Rectangle {
                id: rect
                width: listView.width
                height: 50
                opacity: (index === cutIndex && cutDir === DirectoryModel.getCurrentPath()) ? 0.5 : 1
                color: index % 2 === 0 ? "lightgray" : "white"
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        console.log("Single click")
                        listView.curIndex = index;
                        if (mouse.button === Qt.RightButton) {
                            contextMenu.popup();
                        }
                    }

                    onDoubleClicked: {
                        DirectoryModel.moveForward(model.name);
                    }
                }
                Rectangle {
                    id: rowName
                    width: listView.width * 0.4
                    height: parent.height
                    anchors.left: rect.left
                    anchors.leftMargin: 5
                    color:  "transparent"
                    enabled: false
                    Image{
                        id:typeImage
                        width: rect.height * 0.5
                        height:  rect.height * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.type === "directory" ? "qrc:/image/directory.png" : "qrc:/image/file.png"
                    }

                    Text {
                        id: name
                        width: rowName.width - typeImage.width - 20
                        anchors.left: typeImage.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.name
                        elide: Text.ElideRight
                    }
                }

                Text {
                    id: type
                    width: listView.width * 0.2
                    anchors.left: rowName.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.type
                }

                Text {
                    id: size
                    width: listView.width * 0.2
                    anchors.left: type.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.size
                }

                Text {
                    width: listView.width * 0.2
                    anchors.left: size.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.lastchange
                }
            }
        }

        GridView {
            id: gridView
            property int curIndex: -1
            anchors.fill: parent
            cellWidth: 200
            cellHeight: 30
            model: DirectoryModel
            visible: false
            flow: GridView.FlowTopToBottom
            layoutDirection: GridView.LeftToRigh
            ScrollBar.horizontal: ScrollBar{}
            delegate: Item {
                width: gridView.cellWidth
                height: gridView.cellHeight

                Rectangle {
                    id:gridItem
                    width: parent.width
                    height: parent.height
                    opacity: (index === cutIndex && cutDir === DirectoryModel.getCurrentPath()) ? 0.5 : 1
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: {
                            console.log("index gridView = ", index)
                            gridView.curIndex = index;
                            if (mouse.button === Qt.RightButton) {
                                contextMenu.popup();
                            }
                        }

                        onDoubleClicked: {
                            DirectoryModel.moveForward(model.name);
                        }
                    }
                    Image {
                        id:tImage
                        width: gridItem.height * 0.5
                        height:  gridItem.height * 0.5
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.type === "directory" ? "qrc:/image/directory.png" : "qrc:/image/file.png"
                    }

                    Text {
                        anchors.left: tImage.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: gridItem.verticalCenter
                        text: model.name
                        elide: Text.ElideRight
                    }
                }
            }
        }

        GridView {
            id: pictureGridView
            property int curIndex: -1
            anchors.fill: parent
            cellWidth: 100
            cellHeight: 100
            height: parent.height * 0.65
            width: parent.width
            visible: false
            ScrollBar.vertical: ScrollBar{}
            model: DirectoryModel

            delegate: Item {
                width: pictureGridView.cellWidth
                height: pictureGridView.cellHeight

                Rectangle {
                    width: parent.width
                    height: parent.height
                    opacity: (index === cutIndex && cutDir === DirectoryModel.getCurrentPath()) ? 0.5 : 1
                    color: "white"
                    Image {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        source: model.type === "directory" ? "qrc:/image/directory.png" : "qrc:/image/file.png"
                    }

                    Text {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                            leftMargin: 10
                            rightMargin: 10
                            topMargin: 5
                            bottomMargin: 5
                        }
                        text: model.name
                        elide: Text.ElideRight | Text.ElideLeft
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onDoubleClicked: {
                        DirectoryModel.moveForward(model.name);
                    }
                    onClicked: {
                        console.log("index gridView = ", index)
                        pictureGridView.curIndex = index;
                        if (mouse.button === Qt.RightButton) {
                            contextMenu.popup();
                        }
                    }
                }
            }
        }
    }
}
