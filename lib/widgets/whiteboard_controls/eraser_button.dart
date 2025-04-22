// lib/widgets/whiteboard_controls/eraser_button.dart
import 'package:flutter/material.dart';

class EraserButton extends StatelessWidget {
  final bool isSelected;
  final double currentSize;
  final Function() onPressed;
  final Function(double) onSizeChanged;

  const EraserButton({
    Key? key,
    required this.isSelected,
    required this.currentSize,
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
            Icons.auto_fix_high,
            color: isSelected ? Colors.black : Colors.grey,
          ),
          onPressed: onPressed,
        ),
        if (isSelected)
          Slider(
            value: currentSize,
            min: 5.0,
            max: 30.0,
            divisions: 5,
            label: currentSize.round().toString(),
            onChanged: (value) => onSizeChanged(value),
          ),
      ],
    );
  }
}