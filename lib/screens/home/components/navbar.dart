import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.chat, Icons.timelapse, Icons.call];
    final names = ['Chats', 'Estados', 'Llamadas'];
    final routes = ["/chats", "/states", "/calls"]; // rutas correspondientes

    final List<BottomNavigationBarItem> items =
        icons.asMap().entries.map((entry) {
      final index = entry.key;
      final icon = entry.value;
      return BottomNavigationBarItem(
        icon: Icon(icon),
        label: names[index],
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.blueGrey, width: 0.5)),
      ),
      child: BottomNavigationBar(
        items: items,
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index != selectedIndex) {
            // Navega al screen correspondiente
            Navigator.pushNamedAndRemoveUntil(
              context,
              routes[index],
              (route) => false,
            );
          }
          onTap(index);
        },
      ),
    );
  }
}
