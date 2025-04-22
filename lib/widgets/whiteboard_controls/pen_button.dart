// lib/widgets/whiteboard_controls/pen_button.dart
import 'package:flutter/material.dart';

class PenButton extends StatelessWidget {
  final bool isSelected;
  final double currentSize;
  final Color currentColor;
  final Function() onPressed;
  final Function(double) onSizeChanged;

  const PenButton({
    Key? key,
    required this.isSelected,
    required this.currentSize,
    required this.currentColor,
    required this.onPressed,
    required this.onSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: isSelected ? currentColor : Colors.grey,
          ),
          onPressed: onPressed,
        ),
        if (isSelected)
          Slider(
            value: currentSize,
            min: 1.0,
            max: 10.0,
            divisions: 9,
            label: currentSize.round().toString(),
            onChanged: (value) => onSizeChanged(value),
          ),
      ],
    );
  }
}