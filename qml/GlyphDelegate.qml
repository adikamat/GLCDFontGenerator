import QtQuick

Row {
    id: root

    required property int glyphRow
    required property int glyphColumn
    required property int code
    required property string description
    required property string byteArray

    // To be called after setting colData property
    function generateGlyphDisplay() {
        glyphImg.colData = byteArray.split(",").map(Number)
        glyphImg.drawGlyphMap()
    }

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
            text: String.fromCharCode(root.code)
            font.pixelSize: 20
        }
        Text {
            text: root.description
            font.pixelSize: 14
        }
    }
}
