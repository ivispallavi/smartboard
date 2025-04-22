// lib/widgets/whiteboard_controls/whiteboard_toolbar.dart
import 'package:flutter/material.dart';
import 'pen_button.dart';
import 'eraser_button.dart';
import 'color_selector.dart';
import 'undo_redo_buttons.dart';
import 'clear_button.dart';
import 'extend_canvas_button.dart';

enum DrawingMode {
  pen,
  eraser,
  none,
}

class WhiteboardToolbar extends StatelessWidget {
  final DrawingMode currentMode;
  final double penSize;
  final double eraserSize;
  final Color currentColor;
  final bool canUndo;
  final bool canRedo;
  final Function(DrawingMode) onModeChanged;
  final Function(double) onPenSizeChanged;
  final Function(double) onEraserSizeChanged;
  final Function(Color) onColorChanged;
  final Function() onUndo;
  final Function() onRedo;
  final Function() onClear;
  final Function() onExtendCanvas;

  const WhiteboardToolbar({
    Key? key,
    required this.currentMode,
    required this.penSize,
    required this.eraserSize,
    required this.currentColor,
    required this.canUndo,
    required this.canRedo,
    required this.onModeChanged,
    required this.onPenSizeChanged,
    required this.onEraserSizeChanged,
    required this.onColorChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onExtendCanvas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PenButton(
                isSelected: currentMode == DrawingMode.pen,
                currentSize: penSize,
                currentColor: currentColor,
                onPressed: () => onModeChanged(DrawingMode.pen),
                onSizeChanged: onPenSizeChanged,
              ),
              EraserButton(
                isSelected: currentMode == DrawingMode.eraser,
                currentSize: eraserSize,
                onPressed: () => onModeChanged(DrawingMode.eraser),
                onSizeChanged: onEraserSizeChanged,
              ),
              ColorSelector(
                currentColor: currentColor,
                onColorChanged: onColorChanged,
              ),
              UndoRedoButtons(
                onUndo: onUndo,
                onRedo: onRedo,
                canUndo: canUndo,
                canRedo: canRedo,
              ),
              ClearButton(
                onPressed: onClear,
              ),
              ExtendCanvasButton(
                onPressed: onExtendCanvas,
              ),
            ],
          ),
        ],
      ),
    );
  }
}