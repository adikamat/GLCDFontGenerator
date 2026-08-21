import QtQuick

Item {
    id: root

    required property int glyphRow
    required property int glyphColumn
    required property int code
    required property string description
    required property string byteArray
    required property int index

    // To be called after setting glyphCode property
    function generateGlyphDisplay() {
        glyphImg.glyphCode = byteArray.split(",").map(Number)
        glyphImg.drawGlyphMap()
    }

    height: childrenRect.height

    Row {
        spacing: 5
        GLCDGlyphDrawer {
            id: glyphImg

            rows: root.glyphRow
            columns: root.glyphColumn
            cBWidth: 10
            cBHeight: 10
            enabled: false
        }

        Column {
            spacing: 5
            Text {
                text: root.code.toString()//String.fromCharCode(root.code)
                font.pixelSize: 20
            }
            Text {
                text: root.description
                font.pixelSize: 14
            }
        }
    }
}
