import QtQuick 2.7
import QtQuick.Controls 2.3
import QtMultimedia 5.8
import QtQuick.Layouts 1.12
import Helper 1.0

ApplicationWindow {
    id: window
    title: "Gstreamer Pipline Test"
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

    Image {
        id: pipelineBlock
        width: parent.width
        height: parent.height / 5
        //sourceSize.width: height
        //sourceSize.height: width
        fillMode: Image.PreserveAspectFit
        source: "file:///tmp/gstreamer-pipeline-test/0.00.00.070893169-gst.play.dot.svg"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                print(`touch.`)
            }
        }
    }

    Timer {
        running: video.status == MediaPlayer.InvalidMedia; repeat: true; interval: 200;
        onTriggered: {
            video.play()
        }
    }
}