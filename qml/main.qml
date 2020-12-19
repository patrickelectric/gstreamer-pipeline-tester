import QtQuick 2.7
import QtQuick.Controls 2.3
import QtMultimedia 5.8
import QtQuick.Layouts 1.12
import QtQuick.Window 2.2
import Helper 1.0

ApplicationWindow {
    id: window
    title: "Gstreamer Pipline Tester"
    visible: true
    height: 600
    width: 800

    ColumnLayout {
        anchors.fill: parent
        Video {
            id: video
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: `gst-pipeline: ${textInput.text}`
            autoPlay: true
            fillMode: VideoOutput.Stretch
            onStatusChanged: {
                print(`status: ${status}`)
            }
        }

        TextArea {
            id: textInput
            text: `videotestsrc pattern=ball ! video/x-raw,width=640,height=480 ! videoconvert ! autovideosink`
            Layout.fillWidth: true
        }
    }

    Connections {
        target: Helper
        onPipelineBlockDiagramChanged: {
            pipelineBlock.source = `file://${Helper.pipelineBlockDiagram}`
        }
    }

    Item {
        id: imageFrame
        property var originalHeight: undefined
        property var originalWidth: undefined

        onScaleChanged: {
            const oldWidth = width
            const oldHeight = height
            width = originalWidth * scale
            height = originalHeight * scale
            x = x + (oldWidth - width) / 2
            y = y + (oldHeight - height) / 2
        }

        Image {
            id: pipelineBlock
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            antialiasing: true
            asynchronous: true
            onStatusChanged: {
                if (status != Image.Ready) {
                    return
                }

                width = sourceSize.width
                height = sourceSize.height
                imageFrame.width = width
                imageFrame.height = height
                imageFrame.originalHeight = height
                imageFrame.originalWidth = width
            }

            MouseArea {
                id: dragArea
                hoverEnabled: true
                anchors.fill: pipelineBlock
                drag.target: imageFrame
                property var bigW: dragArea.width * imageFrame.scale
                drag.minimumX: imageFrame.parent.width / 2 - imageFrame.width
                drag.maximumX: imageFrame.parent.width / 2
                drag.minimumY: imageFrame.parent.height / 2 - imageFrame.height
                drag.maximumY: imageFrame.parent.height / 2
                onDoubleClicked: {
                    imageFrame.state = "popup"
                }
                onWheel: {
                    var scaleBefore = imageFrame.scale;
                    imageFrame.scale += imageFrame.scale * wheel.angleDelta.y / 120 / 10;
                }
            }
        }

        states: [
            State {
                name: "default"
                ParentChange {
                    target: imageFrame
                    parent: window
                    x: 0
                    y: 0
                    width: window.width
                    height: window.height / 5
                }
            },
            State {
                name: "popup"
                ParentChange {
                    target: imageFrame
                    parent: windowItem
                    x: 0
                    y: 0
                    width: videoWindow.width
                    height: videoWindow.height
                }
            }
        ]
    }

    Window {
        id: videoWindow
        width: 600
        height: 400
        visible: imageFrame.state == "popup"

        Item {
            id: windowItem
            anchors.fill: parent
        }

        onClosing: {
            imageFrame.state = "default"
        }

    }

    Timer {
        running: video.status == MediaPlayer.InvalidMedia; repeat: true; interval: 200;
        onTriggered: {
            video.play()
        }
    }
}