import QtQuick
import QtQuick.Controls.Basic

import GLCDByteArrayGenerator

Window {
    id: root

    width: 1280
    height: 768
    visible: true
    title: qsTr("GLCD Byte Array Generator")
    color: "darkgrey"

    ListView {
        id: availableGlyphsList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 200

        model: GlyphData{}

        delegate: GlyphDelegate {
            id: entry
            glyphRow: glyphRows.value
            glyphColumn: glyphCols.value
            Component.onCompleted: entry.generateGlyphDisplay()
        }
    }

    Rectangle {
        id: separator
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: availableGlyphsList.right
        width: 2
        color: "black"
    }

    GLCDGlyphDrawer {
        id: glyphDrawer

        anchors.left: separator.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        rows: glyphRows.value
        columns: glyphCols.value
    }

    Column {
        id: controls
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 10

        GridSizeControl {
            id: glyphRows

            labelTxt: "Rows:"
            from: 0
            to: 40
            value: 8
            onValueModified: {
                glyphDrawer.clearColumnData()
            }
        }

        GridSizeControl {
            id: glyphCols

            labelTxt: "Columns:"
            from: 0
            to: 40
            value: 5
            onValueModified: {
                if(value < glyphDrawer.colData.length) {
                    glyphDrawer.colData.length = value
                } else {
                    let newCount = value - glyphDrawer.colData.length
                    glyphDrawer.addColumns(newCount)
                }
                glyphDrawer.clearColumnData()
            }
        }

        TextEdit  {
            id: byteArray
            width: 200
            height: 48
            enabled: false
        }

        Row {
            spacing: 5
            Button {
                text: "Generate"
                onClicked: {
                    let str = ""
                    for(let i=0; i<glyphDrawer.colData.length; i++) {
                        str = str + "0x" + glyphDrawer.colData[i].toString(16).padStart(2, '0') + ","
                    }
                    str = str.slice(0, -1)
                    byteArray.text = str
                }
            }
            Button {
                text: "Copy To Clipboard"
                onClicked: {
                    byteArray.selectAll();
                    byteArray.copy();
                }
            }
        }
        Row {
            spacing: 5
            Button {
                text: "Clear"
                onClicked: {
                    glyphDrawer.clearGrid()
                    glyphDrawer.clearColumnData()
                    byteArray.text = ""
                }
            }
            Button {
                text: "Save"
                onClicked: {
                    savePopup.open()
                    // console.log(glyphDrawer.colData.join())
                    // availableGlyphsList.model.addNewData("A".charCodeAt(0), glyphDrawer.colData.join(), "Character A")
                }
            }
        }
    }

    GlyphSaveDialog {
        id: savePopup

        anchors.centerIn: parent
        onSaveData: function (charCode, desc) {
            availableGlyphsList.model.addNewData(charCode, glyphDrawer.colData.join(), desc)
        }
    }
}
