import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.chat, Icons.new_label, Icons.call];
    final List<BottomNavigationBarItem> icons2 = icons
        .map((icon) => BottomNavigationBarItem(icon: Icon(icon), label: 'ola'))
        .toList();
    /*
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icons[index],
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
            ),
          );
        }),
      ),
    );
*/

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.blueGrey, width: 0.5)),
      ),
      child: BottomNavigationBar(
        items: icons2,
        currentIndex: selectedIndex,
        onTap: onTap,
      ),
    );
  }
}
