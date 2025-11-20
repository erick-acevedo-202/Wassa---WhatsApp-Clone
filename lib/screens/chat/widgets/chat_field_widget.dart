import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/screens/chat/chat_controller.dart';

class ChatFieldWidget extends ConsumerStatefulWidget {
  final String receiverUserId;
  const ChatFieldWidget({super.key, required this.receiverUserId});

  @override
  ConsumerState<ChatFieldWidget> createState() => _ChatFieldWidgetState();
}

class _ChatFieldWidgetState extends ConsumerState<ChatFieldWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  void sendTextMessage() async {
    if (_hasText) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, _messageController.text.trim(), widget.receiverUserId);
      debugPrint("Enviar texto: ${_messageController.text}");
      _messageController.text = '';
      _messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      //color: const Color.fromARGB(255, 206, 208, 210),
      child: Row(
        children: [
          // Campo de texto
          Expanded(
            child: TextFormField(
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
                prefixIcon: const Icon(Icons.insert_emoticon),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          print("ATACHT FILE");
                        },
                        icon: Icon(Icons.attach_file)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt)),
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
                _hasText ? Icons.send : Icons.mic,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
