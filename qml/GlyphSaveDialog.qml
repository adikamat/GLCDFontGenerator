import QtQuick
import QtQuick.Controls.Basic

Popup {
    id: root

    signal saveData(charCode: int, desc: string)

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    Column {
        spacing: 10

        Row {
            spacing: 10
            Text {
                text: "Enter character code:"
            }
            TextInput {
                id: charCode

                width: 50
                height: 32
                // Char code is uint16_t type
                validator: IntValidator {
                    bottom: 0
                    top: 65536
                }
            }
        }
        Row {
            spacing: 10
            Text {
                text: "Enter description:"
            }
            TextInput {
                id: desc

                width: 100
                height: 32
            }
        }
        Row {
            spacing: 5
            Button {
                text: "Accept"
                onClicked: {
                    root.saveData(charCode.text, desc.text)
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
