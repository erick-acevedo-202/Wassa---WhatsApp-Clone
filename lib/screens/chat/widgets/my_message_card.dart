import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum? type;
  final GestureDragUpdateCallback? onLeftSwipe;
  final String? repliedText;
  final String? username;
  final MessageEnum? repliedMessageType;
  final bool? isSeen;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    this.type,
    this.onLeftSwipe,
    this.repliedText,
    this.username,
    this.repliedMessageType,
    this.isSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying = false; //repliedText.isNotEmpty;
    final isSeen = false;

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
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    /*Padding(
                  padding: type == MessageEnum.text
                      ? const EdgeInsets.only(
                          left: 10,
                          right: 30,
                          top: 5,
                          bottom: 20,
                        )
                      : const EdgeInsets.only(
                          left: 5,
                          top: 5,
                          right: 5,
                          bottom: 25,
                        ),
                  child: Column(
                    children: [
                      /*if (isReplying) ...[
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                                    : Colors.grey[300]!.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                5,
                              ),
                            ),
                          ),*/
                          /*child: DisplayTextImageGIF(
                            message: repliedText,
                            type: repliedMessageType,
                          ),*/
                        ),
                        const SizedBox(height: 8),
                      ],
                      /*DisplayTextImageGIF(
                        message: message,
                        type: type,
                      ),*/
                    ],
                  ),
                ),*/

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
