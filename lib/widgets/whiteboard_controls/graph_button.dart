// graph_button.dart
import 'package:flutter/material.dart';

class GraphButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSelected;

  const GraphButton({
    Key? key,
    required this.onPressed,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.functions,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      onPressed: onPressed,
      tooltip: 'Plot Graph',
    );
  }
}