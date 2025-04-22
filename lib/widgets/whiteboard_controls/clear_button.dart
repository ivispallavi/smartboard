// lib/widgets/whiteboard_controls/clear_button.dart
import 'package:flutter/material.dart';

class ClearButton extends StatelessWidget {
  final Function() onPressed;

  const ClearButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear Canvas'),
            content: const Text('Are you sure you want to clear the canvas?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        );
      },
    );
  }
}