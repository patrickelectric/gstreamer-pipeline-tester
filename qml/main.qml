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
        width: parent.width
        height: parent.height / 5
        Image {
            id: pipelineBlock
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            antialiasing: true

            PinchArea {
                anchors.fill: parent
                pinch.target: imageFrame
                pinch.minimumRotation: -360
                pinch.maximumRotation: 360
                pinch.minimumScale: 0.1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis
                onPinchStarted: setFrameColor();
                property real zRestore: 0
                onSmartZoom: {
                    if (pinch.scale > 0) {
                        imageFrame.rotation = 0;
                        imageFrame.scale = Math.min(imageFrame.parent.width, imageFrame.parent.height) / Math.max(image.sourceSize.width, image.sourceSize.height) * 0.85
                        imageFrame.x = flick.contentX + (flick.width - imageFrame.width) / 2
                        imageFrame.y = flick.contentY + (flick.height - imageFrame.height) / 2
                    } else {
                        imageFrame.rotation = pinch.previousAngle
                        imageFrame.scale = pinch.previousScale
                        imageFrame.x = pinch.previousCenter.x - imageFrame.width / 2
                        imageFrame.y = pinch.previousCenter.y - imageFrame.height / 2
                    }
                }

                MouseArea {
                    id: dragArea
                    hoverEnabled: true
                    anchors.fill: parent
                    drag.target: imageFrame
                    onDoubleClicked: {
                        imageFrame.state = "popup"
                    }
                    onWheel: {
                        if (wheel.modifiers & Qt.ControlModifier) {
                            imageFrame.rotation += wheel.angleDelta.y / 120 * 5;
                            if (Math.abs(imageFrame.rotation) < 4)
                                imageFrame.rotation = 0;
                        } else {
                            imageFrame.rotation += wheel.angleDelta.x / 120;
                            if (Math.abs(imageFrame.rotation) < 0.6)
                                imageFrame.rotation = 0;
                            var scaleBefore = imageFrame.scale;
                            imageFrame.scale += imageFrame.scale * wheel.angleDelta.y / 120 / 10;
                        }
                    }
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