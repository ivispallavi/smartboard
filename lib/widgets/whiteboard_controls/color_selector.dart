// lib/widgets/whiteboard_controls/color_selector.dart
import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const ColorSelector({
    Key? key,
    required this.currentColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];

    return PopupMenuButton<Color>(
      icon: Icon(
        Icons.color_lens,
        color: currentColor,
      ),
      itemBuilder: (context) {
        return colors.map((color) {
          return PopupMenuItem<Color>(
            value: color,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: color == currentColor ? 2 : 0,
                ),
              ),
            ),
          );
        }).toList();
      },
      onSelected: onColorChanged,
    );
  }
}