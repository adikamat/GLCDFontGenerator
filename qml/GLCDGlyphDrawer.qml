import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: root

    signal clearGrid

    property int rows: 8
    property int columns: 5
    property list<int> colData: []

    property int cBWidth: 30
    property int cBHeight: 30

    function addColumns(numCols: int) {
        for(let i=0; i < numCols; i++) {
            colData.push(0);
        }
    }

    function clearColumnData() {
        for(let i=0; i < colData.length; i++) {
            colData[i] = 0;
        }
    }

    function drawGlyphMap() {
        for(let i=0; i < colData.length; i++) {
            let currColNum = colData[i]
            for(let rI=0; rI < root.rows; rI++) {
                var gridIndex = i + (rI * root.columns)
                if(currColNum & (0x01 << rI)) {
                    // bit is set
                    glyphGrid.itemAt(gridIndex).checked = true
                } else {
                    glyphGrid.itemAt(gridIndex).checked = false
                }
            }
        }
    }

    color: "darkgrey"
    width: childrenRect.width
    height: childrenRect.height

    Grid {
        rows: root.rows
        columns: root.columns
        rowSpacing: 1
        columnSpacing: 1

        Repeater {
            id: glyphGrid

            model: root.rows * root.columns
            delegate: CheckBox {
                id: cb
                property int rowIndex: index / root.columns
                property int colIndex: index % root.columns
                width: root.cBWidth
                height: root.cBHeight
                checkable: true

                indicator: Rectangle {
                    radius: 2
                    color: cb.checked ? "black" : "white"
                    width: root.cBWidth - 3
                    height: root.cBHeight - 3
                }

                onToggled: {
                    if(checked) {
                        root.colData[colIndex] = root.colData[colIndex] + (2**rowIndex)
                    } else {
                        root.colData[colIndex] = root.colData[colIndex] - (2**rowIndex)
                    }
                    //console.log("In Toggle, index", colIndex, ". Value", root.colData[colIndex])
                }
                Connections {
                    target: root
                    ignoreUnknownSignals: true
                    function onClearGrid() {
                        cb.checked = false
                    }
                }

                //Component.onCompleted: console.log("Index:[", rowIndex, colIndex, "]")
            }
        }
    }

    Component.onCompleted: {
        root.addColumns(root.columns)
        // root.colData[0] = 60; root.colData[1] = 66; root.colData[2] = 66;
        // root.colData[3] = 66; root.colData[4] = 60;
        // root.drawGlyphMap()
    }

}
