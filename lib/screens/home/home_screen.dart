import 'package:flutter/material.dart';
import 'package:wasaaaaa/screens/calls_menu/calls_menus_creen.dart';
import 'package:wasaaaaa/screens/chats_menu/chats_menu_screen.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';
import 'package:wasaaaaa/screens/states/states_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedScreen = 0;

  final List<Widget> _screens = [
    ChatsMenuScreen(),
    StatesMenuScreen(),
    CallsMenusCreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedScreen = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedScreen, children: _screens),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedScreen,
        onTap: _onTap,
      ),
    );
  }
}
