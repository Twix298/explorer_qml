import QtQuick 2.11
import QtQuick.Controls 2.2
import DirectoryViewer 1.0

ListView {
    id: listView
    property var directoryModel
    anchors.fill: parent
    height: parent.height * 0.8
    width: parent.width
    anchors.top: parent
//    anchors.topMargin: mainRow.height
    anchors.left: parent
    visible: true
    model: directoryModel
    ScrollBar.vertical: ScrollBar{}
    delegate: Item {
        width: parent.width
        height: 50

        Rectangle {
            id: rect
            width: parent.width
            height: 50
            color: "white"
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    console.log("Single click")
                    if (mouse.button === Qt.RightButton) {
                        contextMenu.popup();
                    }
                }

                onDoubleClicked: {
                    directoryModel.moveForward(model.name)
                }
            }

            Text {
                id: name
                width: listView.width * 0.4
                anchors.left: rect
                text: model.name
            }

            Text {
                id: type
                width: listView.width * 0.2
                anchors.left: name.right
                text: model.type
            }

            Text {
                id: size
                width: listView.width * 0.2
                anchors.left: type.right
                text: model.size
            }

            Text {
                width: listView.width * 0.2
                anchors.left: size.right
                text: model.lastchange
            }
        }
    }
}
