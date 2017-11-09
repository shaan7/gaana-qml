import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtWebEngine 1.3

import org.nemomobile.mpris 1.0

ApplicationWindow {
    visible: true
    width: 1280
    height: 800
    title: webView.title

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                text: "Previous"

                onClicked: webView.runJavaScript("$(\"[Title*='Previous']\").click()");
            }
            ToolButton {
                text: "Play"

                onClicked: webView.runJavaScript("$(\"[Title*='Play']\").click()");
            }
            ToolButton {
                text: "Pause"

                onClicked: webView.runJavaScript("$(\"[Title*='Pause']\").click()");
            }
            ToolButton {
                text: "Next"

                onClicked: webView.runJavaScript("$(\"[Title*='Next']\").click()");
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }

    WebEngineView {
        id: webView
        anchors.fill: parent

        url: "https://gaana.com/discover"
        settings.pluginsEnabled: true
    }

    MprisPlayer {
        id: mprisPlayer

        property string song
        property string artUrl

        serviceName: "gaana.com"

        // Mpris2 Root Interface
        identity: "gaana.com"
        supportedUriSchemes: ["file"]
        supportedMimeTypes: []

        // Mpris2 Player Interface
        canControl: true

        canGoNext: true
        canGoPrevious: true
        canPause: playbackStatus == Mpris.Playing
        canPlay: playbackStatus != Mpris.Playing
        canSeek: false

        playbackStatus: Mpris.Stopped
        loopStatus: Mpris.None
        shuffle: false
        volume: 1

        onPauseRequested: {
            webView.runJavaScript("$(\"[Title*='Pause']\").click()");
            playbackStatus = Mpris.Paused;
        }
        onPlayRequested: {
            webView.runJavaScript("$(\"[Title*='Play']\").click()");
            playbackStatus = Mpris.Playing;
            updateMetadata();
        }
        onPlayPauseRequested: {
            if (playbackStatus === Mpris.Playing) {
                pauseRequested();
            } else {
                playRequested();
            }
        }
        onStopRequested: {
            webView.runJavaScript("$(\"[Title*='Stop']\").click()");
            playbackStatus = Mpris.Stopped;
        }
        onNextRequested: {
            webView.runJavaScript("$(\"[Title*='Next']\").click()");
            updateMetadata();
        }
        onPreviousRequested: {
            webView.runJavaScript("$(\"[Title*='Previous']\").click()");
            updateMetadata();
        }
        onSeekRequested: {
            message.lastMessage = "Seeked requested with offset - " + offset + " microseconds"
            emitSeeked()
        }
        onSetPositionRequested: {
            message.lastMessage = "Position requested to - " + position + " microseconds"
            emitSeeked()
        }

        onArtUrlChanged: {
            var metadata = mprisPlayer.metadata

            metadata[Mpris.metadataToString(Mpris.ArtUrl)] = artUrl // String

            mprisPlayer.metadata = metadata
        }

        onSongChanged: {
            var metadata = mprisPlayer.metadata

            metadata[Mpris.metadataToString(Mpris.Title)] = song // String

            mprisPlayer.metadata = metadata
        }

        function updateMetadata() {
            webView.runJavaScript("$(\"[id*='stitle']\")[0].innerHTML", function(title) {
                song = title;
            });
            webView.runJavaScript("$(\"[class*='player-artwork']\")[0].childNodes[0].childNodes[0].src", function(albumArt) {
                artUrl = albumArt;
            });
        }
    }
}
