import QtQuick
import QtQuick.Controls.Basic

Popup {
    id: root

    signal exportData(filename: string)

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    Column {
        spacing: 10

        Row {
            spacing: 10
            Text {
                text: "Enter fileName(extension .json is added by default):"
            }
            TextInput {
                id: filename

                width: 50
                height: 32
            }
        }
        Row {
            spacing: 5
            Button {
                text: "Accept"
                onClicked: {
                    root.exportData(filename.text)
                    root.close()
                }
            }
            Button {
                text: "Close"
                onClicked: root.close()
            }
        }
    }
}
