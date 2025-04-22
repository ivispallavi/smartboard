// lib/widgets/whiteboard_controls/undo_redo_buttons.dart
import 'package:flutter/material.dart';

class UndoRedoButtons extends StatelessWidget {
  final Function() onUndo;
  final Function() onRedo;
  final bool canUndo;
  final bool canRedo;

  const UndoRedoButtons({
    Key? key,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: canUndo ? onUndo : null,
          color: canUndo ? Colors.black : Colors.grey,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: canRedo ? onRedo : null,
          color: canRedo ? Colors.black : Colors.grey,
        ),
      ],
    );
  }
}