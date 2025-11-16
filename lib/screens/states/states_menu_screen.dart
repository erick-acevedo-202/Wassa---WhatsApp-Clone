import 'package:flutter/material.dart';

class StatesMenuScreen extends StatefulWidget {
  StatesMenuScreen({super.key});

  @override
  State<StatesMenuScreen> createState() => _StatesMenuScreenState();
}

class _StatesMenuScreenState extends State<StatesMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('states')));
  }
}
