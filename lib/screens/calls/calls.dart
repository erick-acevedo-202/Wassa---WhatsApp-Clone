import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

var tokenG;
var flag = true;
String? name = "";

class CallsUsers extends ConsumerStatefulWidget {
  const CallsUsers({super.key});

  @override
  ConsumerState<CallsUsers> createState() => _CallsUsersState();
}

class _CallsUsersState extends ConsumerState<CallsUsers> {
  bool _executed = false;

  Future<bool> requestPermission(Permission permission) async {
    var status = await permission.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      openAppSettings(); // llevar al usuario a ajustes
      return false;
    }

    return status.isGranted;
  }

  Future<void> getName() async {
    name = await ref.read(authControllerProvider).getUserNameById();
  }

  Future<void> getPermissions() async {
    if (Platform.isIOS) return;

    await requestPermission(Permission.camera);
    await requestPermission(Permission.microphone);
    await requestPermission(Permission.bluetoothConnect);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_executed) return;
    _executed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = ModalRoute.of(context)!.settings.arguments as String;
      tokenG = token;

      await getPermissions();
      await getName();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MeetingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _executed = false;
    super.dispose();
  }
}

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    implements HMSUpdateListener {
  late HMSSDK hmsSDK;

  bool micOn = true;
  bool camOn = true;

  Map<String, HMSPeer> peersMap = {};
  Map<String, HMSVideoTrack?> videoTracks = {};

  @override
  void initState() {
    super.initState();
    initHMSSDK();
  }

  void initHMSSDK() async {
    hmsSDK = HMSSDK();
    await hmsSDK.build();
    hmsSDK.addUpdateListener(listener: this);
    hmsSDK.join(
      config: HMSConfig(
        authToken: tokenG,
        userName: name!,
      ),
    );
  }

  @override
  void dispose() {
    hmsSDK.removeUpdateListener(listener: this);
    super.dispose();
  }

  @override
  void onJoin({required HMSRoom room}) {
    setState(() {
      peersMap.clear();
      for (var p in room.peers ?? []) {
        peersMap[p.peerId] = p;
        videoTracks[p.peerId] = p.videoTrack;
      }
    });
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    setState(() {
      if (update == HMSPeerUpdate.peerJoined) {
        peersMap[peer.peerId] = peer;
        videoTracks[peer.peerId] = peer.videoTrack;
      } else if (update == HMSPeerUpdate.peerLeft) {
        peersMap.remove(peer.peerId);
        videoTracks.remove(peer.peerId);
      } else {
        // para otros updates simplemente actualiza la referencia
        peersMap[peer.peerId] = peer;
      }
    });
  }

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {
    setState(() {
      for (var p in addedPeers) {
        peersMap[p.peerId] = p; // upsert - evita duplicados
        videoTracks[p.peerId] = p.videoTrack;
      }
      for (var p in removedPeers) {
        peersMap.remove(p.peerId);
        videoTracks.remove(p.peerId);
      }
    });
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (track.kind != HMSTrackKind.kHMSTrackKindVideo) return;
    setState(() {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        videoTracks[peer.peerId] = null;
      } else {
        videoTracks[peer.peerId] = track as HMSVideoTrack;
      }
    });
  }

  Widget peerTile(Key key, HMSVideoTrack? videoTrack, HMSPeer peer) {
    final initial =
        (peer.name != null && peer.name.trim().isNotEmpty) ? peer.name : 'U';

    return Container(
      key: key,
      decoration: BoxDecoration(border: Border.all(color: Colors.white12)),
      child: (videoTrack != null && !videoTrack.isMute)
          ? HMSVideoView(track: videoTrack)
          : Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade700,
                child: Text(
                  initial,
                  style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int count = peersMap.length;

    int crossAxis;
    double mainHeight;

    if (count == 1) {
      crossAxis = 1;
      mainHeight = MediaQuery.of(context).size.height; // pantalla completa
    } else if (count == 2) {
      crossAxis = 1;
      mainHeight = MediaQuery.of(context).size.height / 2; // mitad y mitad
    } else {
      crossAxis = 2; // grid normal
      mainHeight = MediaQuery.of(context).size.height / 2.5;
    }
    return WillPopScope(
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
              Container(
                  height: MediaQuery.of(context).size.height,
                  child: GridView.builder(
                    itemCount: count,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      mainAxisExtent: mainHeight,
                    ),
                    itemBuilder: (context, index) {
                      final peer = peersMap.values.toList()[index];
                      final track = videoTracks[peer.peerId];
                      return peerTile(
                        Key(peer.peerId),
                        track,
                        peer,
                      );
                    },
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          setState(() => micOn = !micOn);
                          hmsSDK.toggleMicMuteState();
                        },
                        elevation: 2.0,
                        fillColor: Colors.grey.shade800,
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                        child: Icon(
                          micOn ? Icons.mic : Icons.mic_off,
                          size: 25.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 25),
                      RawMaterialButton(
                        onPressed: () {
                          setState(() => camOn = !camOn);
                          hmsSDK.toggleCameraMuteState();
                        },
                        elevation: 2.0,
                        fillColor: Colors.grey.shade800,
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                        child: Icon(
                          camOn ? Icons.videocam : Icons.videocam_off,
                          size: 25.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 25),
                      RawMaterialButton(
                        onPressed: () {
                          hmsSDK.leave();
                          flag = false;
                          Navigator.of(context)
                            ..pop()
                            ..pop();
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
