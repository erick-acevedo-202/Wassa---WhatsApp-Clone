import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class StatesSeeScreen extends StatefulWidget {
  final dynamic state;

  const StatesSeeScreen({required this.state});

  @override
  _StatesSeeScreenState createState() => _StatesSeeScreenState();
}

class _StatesSeeScreenState extends State<StatesSeeScreen> {
  File? downloadedFile;

  @override
  void dispose() {
    /// eliminar archivo temporal al cerrar
    if (downloadedFile != null && downloadedFile!.existsSync()) {
      downloadedFile!.deleteSync();
    }
    super.dispose();
  }

  Future<File> downloadToTempFile(String url) async {
    final resp = await http.get(Uri.parse(url));

    if (resp.statusCode != 200)
      throw Exception("No se pudo descargar el archivo");

    final tempDir = await getTemporaryDirectory();
    final filename = url.split('/').last;
    final file = File("${tempDir.path}/$filename");

    if (await file.exists()) {
      await file.delete();
      print("Archivo eliminado");
    } else {
      print("El archivo no existe");
    }

    return await file.writeAsBytes(resp.bodyBytes);
  }

  Widget _buildContent(String? mediaUrl, String message) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return _buildTextMessage(message);
    }

    final url = mediaUrl;
    print(url);

    if (url.contains(".jpg") ||
        url.contains(".jpeg") ||
        url.contains(".png") ||
        url.contains(".gif")) {
      return _buildImage(url);
    }

    if (url.contains(".mp4") || url.contains(".mov") || url.contains(".avi")) {
      return _buildVideo(url);
    }

    if (url.contains(".mp3") ||
        url.contains(".wav") ||
        url.contains(".m4a") ||
        url.contains(".ogg") ||
        url.contains(".flac")) {
      return _buildAudio(url);
    }

    return _buildTextMessage(message);
  }

  Widget _buildTextMessage(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // -----------------------------
  // IMAGEN
  // -----------------------------
  Widget _buildImage(String url) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: url,
        placeholder: (_, __) => CircularProgressIndicator(),
        errorWidget: (_, __, ___) => Icon(Icons.error),
      ),
    );
  }

  // -----------------------------
  // VIDEO
  // -----------------------------
  Widget _buildVideo(String url) {
    return VideoApp(url: url);
  }

  // -----------------------------
  // AUDIO
  // -----------------------------
  Widget _buildAudio(String url) {
    return FutureBuilder<File>(
      future: downloadToTempFile(url),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        downloadedFile = snapshot.data;

        return AudioApp(file: downloadedFile!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.state.media;
    final message = widget.state.message;

    return Scaffold(
      appBar: AppBar(
        title: Text("estado"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(media, message),
      ),
    );
  }
}

class VideoApp extends StatefulWidget {
  final String url;

  const VideoApp({super.key, required this.url});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.url,
      ),
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.setLooping(true);
    _listener = () {
      if (mounted) setState(() {});
    };
    _controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Video
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Barra de progreso
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(_controller.value.position),
                      ),
                      Slider(
                        value: _controller.value.position.inSeconds.toDouble(),
                        max: _controller.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _controller
                                .seekTo(Duration(seconds: value.toInt()));
                          });
                        },
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
                      ),
                    ],
                  ),
                  // Controles play/pause y stop
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () {
                          setState(() {
                            _controller.pause();
                            _controller.seekTo(Duration.zero);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  /// Formatea la duración como mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }
}

class AudioApp extends StatefulWidget {
  final File file;

  const AudioApp({required this.file});

  @override
  _AudioAppState createState() => _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.setFilePath(widget.file.path);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Barra de progreso y tiempo
        StreamBuilder<Duration?>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = player.duration ?? Duration.zero;

            return Column(
              children: [
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds
                      .clamp(0, duration.inSeconds)
                      .toDouble(),
                  onChanged: (value) {
                    player.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Controles play / pause / stop
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data?.playing ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 50,
                  icon:
                      Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  onPressed: () {
                    isPlaying ? player.pause() : player.play();
                  },
                ),
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () {
                    player.stop();
                  },
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 8),
        const Text("Reproduciendo audio..."),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
