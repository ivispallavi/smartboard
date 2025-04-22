// lib/widgets/whiteboard_controls/extend_canvas_button.dart
import 'package:flutter/material.dart';

class ExtendCanvasButton extends StatelessWidget {
  final Function() onPressed;

  const ExtendCanvasButton({
    Key? key, 
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_box_outlined),
      onPressed: onPressed,
      tooltip: 'Extend Canvas',
    );
  }
}