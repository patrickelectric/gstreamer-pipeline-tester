import QtQuick 2.7
import QtQuick.Controls 2.3
import QtMultimedia 5.8

ApplicationWindow {
    id: window
    title: "Gstreamer Pipline Test"
    visible: true
    height: 600
    width: 800

    Video {
        id: video
        anchors.fill: parent
        source: `gst-pipeline: videotestsrc pattern=ball ! video/x-raw,width=640,height=480 ! videoconvert ! autovideosink`
        autoPlay: true
        onStatusChanged: {
            print(`status: ${status}`)
        }
    }

    Timer {
        running: video.status == MediaPlayer.InvalidMedia; repeat: true; interval: 200;
        onTriggered: {
            video.play()
        }
    }
}