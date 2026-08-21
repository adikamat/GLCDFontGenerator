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

    // Helper function to strip out the 'file://' prefix
    function urlToLocalPath(urlStr) {
        if (urlStr.startsWith("file:///")) {
            // Windows/Unix standard cleaning
            return urlStr.replace("file:///", "")
        } else if (urlStr.startsWith("file://")) {
            return urlStr.replace("file://", "")
        }
        return urlStr
    }

    function showGlyphCode() {
        let str = ""
        for(let i=0; i<glyphDrawer.glyphCode.length; i++) {
            str = str + "0x" + glyphDrawer.glyphCode[i].toString(16).padStart(2, '0') + ","
        }
        str = str.slice(0, -1)
        byteArray.text = str
    }

    ListView {
        id: availableGlyphsList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 200
        spacing: 10

        model: GlyphData{}

        delegate: GlyphDelegate {
            id: entry
            glyphRow: glyphRows.value
            glyphColumn: glyphCols.value

            width: availableGlyphsList.width

            Component.onCompleted: entry.generateGlyphDisplay()

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    availableGlyphsList.currentIndex = index
                }
            }
        }

        onCurrentIndexChanged: {
            // Load glyph
            glyphDrawer.glyphCode = availableGlyphsList.currentItem.byteArray.split(",").map(Number)
            glyphDrawer.drawGlyphMap()
            root.showGlyphCode()
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

    DropArea {
        id: dropArea
        anchors.fill: parent

        // 1. Optional: Filter or accept the drag event when it enters the region
        onEntered: (drag) => {
                       if (drag.hasUrls) {
                           drag.acceptProposedAction()
                       }
                   }

        // 2. Handle the actual drop action
        onDropped: (drop) => {
                       if (drop.hasUrls) {
                           // Loop through all dropped file URLs
                           for (var i = 0; i < drop.urls.length; i++) {
                               let rawUrl = drop.urls[i].toString()

                               // Convert URL format (file:///path/to/file) to a standard local file path
                               let localPath = urlToLocalPath(rawUrl)

                               console.log("Dropped File Path:", localPath)
                               if(localPath.endsWith(".json")) {
                                   let loaded = availableGlyphsList.model.loadModelFromFile(localPath)
                                   console.log("File load", loaded)
                               } else {
                                   console.warn("Only JSON files supported")
                               }
                           }

                           drop.acceptProposedAction()
                       }
                   }
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
                glyphDrawer.clearGlyphCode()
            }
        }

        GridSizeControl {
            id: glyphCols

            labelTxt: "Columns:"
            from: 0
            to: 40
            value: 5
            onValueModified: {
                if(value < glyphDrawer.glyphCode.length) {
                    glyphDrawer.glyphCode.length = value
                } else {
                    let newCount = value - glyphDrawer.glyphCode.length
                    glyphDrawer.addColumns(newCount)
                }
                glyphDrawer.clearGlyphCode()
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
                    root.showGlyphCode()
                }
            }
            Button {
                text: "Copy To Clipboard"
                onClicked: {
                    byteArray.selectAll();
                    byteArray.copy();
                }
            }
            Button {
                text: "Clear"
                onClicked: {
                    glyphDrawer.clearGrid()
                    glyphDrawer.clearGlyphCode()
                    byteArray.text = ""
                }
            }
        }
        Row {
            spacing: 5
            Button {
                text: "Save"
                onClicked: {
                    savePopup.open()
                    // console.log(glyphDrawer.glyphCode.join())
                    // availableGlyphsList.model.addNewData("A".charCodeAt(0), glyphDrawer.glyphCode.join(), "Character A")
                }
            }
            Button {
                text: "Export"
                onClicked: {
                    exportPopup.open()
                }
            }
        }
    }

    GlyphSaveDialog {
        id: savePopup

        anchors.centerIn: parent
        onSaveData: function (charCode, desc) {
            availableGlyphsList.model.addNewData(charCode, glyphDrawer.glyphCode.join(), desc)
        }
    }

    GlyphsExportDialog {
        id: exportPopup

        anchors.centerIn: parent
        onExportData: function (filename) {
            availableGlyphsList.model.exportModelToJson(glyphRows.value, glyphCols.value, filename + ".json");
        }
    }
}
