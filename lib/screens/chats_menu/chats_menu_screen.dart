import 'package:flutter/material.dart';
import 'package:wasaaaaa/components/value_listener.dart';

class ChatsMenuScreen extends StatefulWidget {
  ChatsMenuScreen({super.key});

  @override
  State<ChatsMenuScreen> createState() => _ChatsMenuScreenState();
}

class _ChatsMenuScreenState extends State<ChatsMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wasaaaa'),
        actions: [
          ValueListenableBuilder(
            valueListenable: ValueListener.isLightTheme,
            builder: (context, value, child) {
              return value
                  ? IconButton(
                      icon: Icon(Icons.nightlight),
                      onPressed: () {
                        ValueListener.isLightTheme.value = false;
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.sunny),
                      onPressed: () {
                        ValueListener.isLightTheme.value = true;
                      },
                    );
            },
          ),
        ],
      ),
      body: Center(child: Text('chats')),
    );
  }
}
