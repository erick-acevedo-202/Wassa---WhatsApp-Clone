import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/components/utils.dart';
import 'package:wasaaaaa/screens/chat/chat_controller.dart';

class ChatFieldWidget extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroup;
  const ChatFieldWidget(
      {super.key, required this.receiverUserId, required this.isGroup});

  @override
  ConsumerState<ChatFieldWidget> createState() => _ChatFieldWidgetState();
}

class _ChatFieldWidgetState extends ConsumerState<ChatFieldWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;
  bool showEmojis = false;
  FocusNode focusNode = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecordingInit = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
    _soundRecorder = FlutterSoundRecorder();
    _initRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
    _soundRecorder!.closeRecorder();
    isRecordingInit = false;
  }

  Future<void> _initRecorder() async {
    try {
      // Solicitar permiso ANTES de abrir el recorder
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          showSnackBar(
              context: context,
              content:
                  'Wassa necesita permiso del micrófono para grabar audio');
        }
        return;
      }

      await _soundRecorder!.openRecorder();
      if (mounted) {
        setState(() {
          isRecordingInit = true;
        });
      }
    } catch (e) {
      debugPrint("Error inicializando recorder: $e");
    }
  }

  Future<void> openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException(
          "Wassa no tiene permiso para grabar Audio");
    }
    await _soundRecorder!.openRecorder();
    isRecordingInit = true;
  }

  void showEmojiKeyboard() => focusNode.requestFocus();
  void hideEmojiKeyboard() => focusNode.unfocus();

  void toggleEmojisContainer() {
    setState(() {
      showEmojis = !showEmojis;
    });

    print('TOGGLE EMOJI FUNTION: ${showEmojis == true ? 1 : 0}');

    if (showEmojis) {
      showEmojiKeyboard();
    } else {
      hideEmojiKeyboard();
    }
  }

  void sendTextMessage() async {
    if (_hasText) {
      ref.read(chatControllerProvider).sendTextMessage(
          context,
          _messageController.text.trim(),
          widget.receiverUserId,
          widget.isGroup);
      debugPrint("Enviar texto: ${_messageController.text}");
      _messageController.text = '';
      _messageController.clear();
    } else {
      if (!isRecordingInit) {
        debugPrint("Recorder no inicializado todavía");
        return;
      }
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
        context, file, widget.receiverUserId, messageEnum, widget.isGroup);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      ref.read(chatControllerProvider).sendGIFMessage(context, gif.url,
          widget.receiverUserId, MessageEnum.gif, widget.isGroup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        //padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //color: const Color.fromARGB(255, 206, 208, 210),
        children: [
          Row(
            children: [
              // Campo de texto
              Expanded(
                child: TextFormField(
                  focusNode: focusNode,
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Mensaje",
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: IconButton(
                        onPressed: () {
                          print('TOGGLE EMOJI: ${showEmojis == true ? 1 : 0}');
                          toggleEmojisContainer();
                        },
                        icon: Icon(Icons.insert_emoticon)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              selectGIF();
                            },
                            icon: Icon(Icons.gif)),
                        IconButton(
                            onPressed: () {
                              print("ATACHT FILE");
                              selectVideo();
                            },
                            icon: Icon(Icons.attach_file)),
                        IconButton(
                            onPressed: () {
                              selectImage();
                            },
                            icon: Icon(Icons.camera_alt)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // BTN Microfono / Send
              GestureDetector(
                onLongPressStart: (_) {
                  if (!_hasText) {
                    HapticFeedback
                        .heavyImpact(); // vibración al mantener presionado
                    debugPrint("Grabando audio...");
                    //LOGICA DE GRABACIÓN DE VOZ
                  }
                },
                onLongPressEnd: (_) {
                  if (!_hasText) {
                    debugPrint("Audio enviado");
                    // Finalizar grabación y enviar
                  }
                },
                onTap: sendTextMessage,
                child: CircleAvatar(
                  radius: 24,
                  child: Icon(
                    _hasText
                        ? Icons.send
                        : isRecording
                            ? Icons.cancel_outlined
                            : Icons.mic,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          showEmojis
              ? SizedBox(
                  height: 310,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      setState(() {
                        _messageController.text =
                            _messageController.text + emoji.emoji;
                      });
                      if (!showEmojis) {
                        setState(() {
                          showEmojis = true;
                        });
                      }
                    },
                  ),
                )
              : SizedBox()
        ]);
  }
}
