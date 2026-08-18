import QtQuick
import QtQuick.Controls.Basic

Row {
    id: root

    property alias labelTxt: label.text
    property alias from: spnBox.from
    property alias to: spnBox.to
    property alias value: spnBox.value

    signal valueModified

    spacing: 5
    Text {
        id: label
        text: "Rows:"
    }
    SpinBox {
        id: spnBox
        editable: true
        onValueModified: {
            root.valueModified()
        }
    }
}
