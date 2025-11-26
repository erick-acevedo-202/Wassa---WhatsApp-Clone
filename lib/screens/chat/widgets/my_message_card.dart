import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/screens/chat/widgets/display_asset.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final GestureDragUpdateCallback? onLeftSwipe;
  final String? repliedText;
  final String? username;
  final MessageEnum? repliedMessageType;
  final bool isSeen;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    this.onLeftSwipe,
    this.repliedText,
    this.username,
    this.repliedMessageType,
    required this.isSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
        onLeftSwipe: onLeftSwipe,
        child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 45,
              ),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Theme.of(context).primaryColor,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 30,
                        top: 5,
                        bottom: 20,
                      ),
                      child: type == MessageEnum.text
                          ? Text(
                              message,
                              style: TextStyle(color: Colors.white),
                            )
                          : DisplayAsset(message: message, type: type),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Row(
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            isSeen ? Icons.done_all : Icons.done,
                            size: 20,
                            color: isSeen ? Colors.blue : Colors.white60,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
