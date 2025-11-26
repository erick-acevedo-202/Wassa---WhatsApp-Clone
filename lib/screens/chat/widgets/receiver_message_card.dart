import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/screens/chat/widgets/display_asset.dart';

class ReceiverMessageCard extends StatelessWidget {
  const ReceiverMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    this.onRightSwipe,
    this.repliedText,
    this.username,
    this.repliedMessageType,
  }) : super(key: key);
  final String message;
  final String date;
  final MessageEnum type;
  final GestureDragUpdateCallback? onRightSwipe;
  final String? repliedText;
  final String? username;
  final MessageEnum? repliedMessageType;

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Theme.of(context).cardColor,
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
                      ? Text(message)
                      : DisplayAsset(message: message, type: type),
                ),
                Positioned(
                  bottom: 2,
                  right: 10,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
