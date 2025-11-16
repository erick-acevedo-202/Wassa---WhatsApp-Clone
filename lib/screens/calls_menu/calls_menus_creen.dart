import 'package:flutter/material.dart';

class CallsMenusCreen extends StatefulWidget {
  CallsMenusCreen({super.key});

  @override
  State<CallsMenusCreen> createState() => _CallsMenusCreenState();
}

class _CallsMenusCreenState extends State<CallsMenusCreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('calls')));
  }
}
