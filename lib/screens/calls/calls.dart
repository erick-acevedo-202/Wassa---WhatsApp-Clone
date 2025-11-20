import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MaterialApp(home: CallsUsers()));

class CallsUsers extends StatelessWidget {
  const CallsUsers({super.key});

  Future<bool> getPermissions() async {
    if (Platform.isIOS) return true;
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.bluetoothConnect.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
    while ((await Permission.bluetoothConnect.isDenied)) {
      await Permission.bluetoothConnect.request();
    }
    return true;
  }

// UI to render join screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            // Function to push to meeting page
            onPressed: () async {
              await getPermissions();
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const MeetingPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Text(
                'Join',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    implements HMSUpdateListener {
  //SDK
  late HMSSDK hmsSDK;

  // Variables required for joining a room
  String authToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2OTFlODcxZDE0NWNiNGU4NDQ5YjFiNzYiLCJyb2xlIjoiaG9zdCIsInJvb21faWQiOiI2OTFlYTViOWE0OGNhNjFjNDY0N2UwZTQiLCJ1c2VyX2lkIjoiZTFjZDMxODgtY2RkMy00MTdlLTljMGYtNDI5NTFlZGYyNTIxIiwiZXhwIjoxNzYzNzA2NDEyLCJqdGkiOiIyYzYzNDE2OS1hZjhkLTQ1MzYtYTA3NC1iMzYyZGU2ZjZmOWEiLCJpYXQiOjE3NjM2MjAwMTIsImlzcyI6IjY5MWU4NzFkMTQ1Y2I0ZTg0NDliMWI3NCIsIm5iZiI6MTc2MzYyMDAxMiwic3ViIjoiYXBpIn0.plcCO-s5CmzDocj0Jmm6FMPFlzXiaTT5zhI8IZm812w";
  String userName = "test_user";

  // Variables required for rendering video and peer info
  HMSPeer? localPeer, remotePeer;
  HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;

  // Initialize variables and join room

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {
    if (mounted) {
      setState(() {
        // Maneja peers añadidos
        for (var peer in addedPeers) {
          if (!peer.isLocal) {
            remotePeer =
                peer; // o agrega a una lista si quieres múltiples peers
          }
        }

        // Maneja peers removidos
        for (var peer in removedPeers) {
          if (!peer.isLocal) {
            remotePeer = null; // o elimina de la lista de peers
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initHMSSDK();
  }

  void initHMSSDK() async {
    hmsSDK = HMSSDK();
    await hmsSDK.build(); // ensure to await while invoking the `build` method
    hmsSDK.addUpdateListener(listener: this);
    hmsSDK.join(config: HMSConfig(authToken: authToken, userName: userName));
  }

  // Clear all variables
  @override
  void dispose() {
    remotePeer = null;
    remotePeerVideoTrack = null;
    localPeer = null;
    localPeerVideoTrack = null;
    super.dispose();
  }

  // Called when peer joined the room - get current state of room by using HMSRoom obj
  @override
  void onJoin({required HMSRoom room}) {
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        localPeer = peer;
        if (peer.videoTrack != null) {
          localPeerVideoTrack = peer.videoTrack;
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  // Called when there's a peer update - use to update local & remote peer variables
  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (!peer.isLocal) {
          if (mounted) {
            setState(() {
              remotePeer = peer;
            });
          }
        }
        break;
      case HMSPeerUpdate.peerLeft:
        if (!peer.isLocal) {
          if (mounted) {
            setState(() {
              remotePeer = null;
            });
          }
        }
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        return;
      default:
        if (mounted) {
          setState(() {
            localPeer = null;
          });
        }
    }
  }

  // Called when there's a track update - use to update local & remote track variables
  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      switch (trackUpdate) {
        case HMSTrackUpdate.trackRemoved:
          if (mounted) {
            setState(() {
              peer.isLocal
                  ? localPeerVideoTrack = null
                  : remotePeerVideoTrack = null;
            });
          }
          return;
        default:
          if (mounted) {
            setState(() {
              peer.isLocal
                  ? localPeerVideoTrack = track as HMSVideoTrack
                  : remotePeerVideoTrack = track as HMSVideoTrack;
            });
          }
      }
    }
  }

  // More callbacks - no need to implement for quickstart
  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onHMSError({required HMSException error}) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  // Widget to render a single video tile
  Widget peerTile(Key key, HMSVideoTrack? videoTrack, HMSPeer? peer) {
    return Container(
      key: key,
      child: (videoTrack != null && !(videoTrack.isMute))
          // Actual widget to render video
          ? HMSVideoView(
              track: videoTrack,
            )
          : Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(4),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blue,
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: Text(
                  peer?.name.substring(0, 1) ?? "D",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }

  // Widget to render grid of peer tiles and a end button
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Used to call "leave room" upon clicking back button [in android]
      onWillPop: () async {
        hmsSDK.leave();
        Navigator.pop(context);
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Grid of peer tiles
              Container(
                height: MediaQuery.of(context).size.height,
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: (remotePeerVideoTrack == null)
                          ? MediaQuery.of(context).size.height
                          : MediaQuery.of(context).size.height / 2,
                      crossAxisCount: 1),
                  children: [
                    if (remotePeerVideoTrack != null && remotePeer != null)
                      peerTile(
                          Key(remotePeerVideoTrack?.trackId ?? "" "mainVideo"),
                          remotePeerVideoTrack,
                          remotePeer),
                    peerTile(
                        Key(localPeerVideoTrack?.trackId ?? "" "mainVideo"),
                        localPeerVideoTrack,
                        localPeer)
                  ],
                ),
              ),
              // End button to leave the room
              Align(
                alignment: Alignment.bottomCenter,
                child: RawMaterialButton(
                  onPressed: () {
                    hmsSDK.leave();
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Colors.red,
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.call_end,
                    size: 25.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
