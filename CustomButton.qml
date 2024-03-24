import QtQuick 2.0
import QtQuick.Controls 2.2

import "Theme.js" as Theme

Rectangle {
    function getWidth(text) {
        if (text ==="") {
            return imageName.width + 10
        }
        else {
            return btnName.contentWidth + imageName.width + 30
        }
    }

    id: button
    signal clicked

    property alias text: btnName.text
    property string image: ""
    property int btnWidth: 155
    property int btnHeight: 30
    property bool isEnabled: true

    property string colorBorder: enabled === true ? Theme.button.colorBorder : Theme.button.colorBorderDisabled
    property string colorTxt: Theme.button.text.color
    property string colorButtonBot: enabled === true ? Theme.button.color : Theme.button.colorDisabled
    property string colorButtonTop: enabled === true ? Theme.button.color : Theme.button.colorDisabled
    property string colorHighlight: Theme.button.highlightColor
    property bool highlighted : false;
    property string toolTipText: ""

    implicitHeight: btnHeight
    implicitWidth: getWidth(text)

    border.width: 1
    border.color: colorBorder
    enabled: isEnabled

//    anchors.bottom: parent.bottom
//    anchors.right: parent.right
//    anchors.left: parent.left

    gradient: Gradient{
        GradientStop{
            position: 0
            color: highlighted ? colorHighlight : colorButtonBot
        }
        GradientStop{
            position: 1
            color: highlighted ? colorHighlight : colorButtonTop
        }
    }
//    gradient: Gradient{
//        GradientStop{
//            position: 0
//            color: colorButtonBot
//        }
//        GradientStop{
//            position: 1
//            color: colorButtonTop
//        }
//    }

    states: [
        State {
            name: "Hovering"
            PropertyChanges {
                target: button
                color: "red"
            }
        }

    ]

    Row{
        anchors.verticalCenter: parent.verticalCenter
        anchors.centerIn: parent
        spacing: 7

        Image {
            id: imageName
            source: image
            width: button.height - 10
            height: button.height - 10
            anchors.verticalCenter: parent.verticalCenter
//                        anchors.leftMargin: 10
        }

        Text{
            id: btnName
            color: colorTxt
            font.pixelSize: Theme.button.text.size
            font.family: Theme.button.text.font
            anchors.verticalCenter: parent.verticalCenter
//            anchors.rightMargin: 10
            //            anchors.centerIn: parent

            clip: true
        }
    }
    MouseArea{
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: button.clicked()
    }

//    ToolTip {
//        parent: button
//        visible: reviveAllArea.containsMouse
//        text: "Активировать участников"

//    }

}
