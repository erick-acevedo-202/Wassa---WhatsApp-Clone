import 'package:flutter/material.dart';
import 'package:wasaaaaa/models/callDAO.dart';

class IncomingCallNotification extends StatelessWidget {
  final CallDAO call;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallNotification({
    super.key,
    required this.call,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      top: 40,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.95),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Incoming call",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "From: ${call.callerId}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                    ),
                    onPressed: onDecline,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),

                  // Accept
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                    ),
                    onPressed: onAccept,
                    child: const Icon(Icons.call, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
