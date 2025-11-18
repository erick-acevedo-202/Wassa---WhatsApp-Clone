import 'package:flutter/material.dart';

class StatesAddScreen extends StatefulWidget {
  const StatesAddScreen({super.key});

  @override
  State<StatesAddScreen> createState() => _StatesAddScreenState();
}

class _StatesAddScreenState extends State<StatesAddScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar historia'),
      ),
      body: SafeArea(child: Column()),
    );
  }
}
