import 'package:flutter/material.dart';

/// Shows a dialog to select a canvas color
Future<Color?> showCanvasColorPicker({
  required BuildContext context,
  required Color currentColor,
}) {
  final List<Color> canvasColors = [
    const Color.fromARGB(255, 7, 87, 4),
    Colors.black,
    Colors.blue[50]!,
    Colors.green[50]!,
  ];

  return showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Canvas Color'),
      content: Container(
        width: 300,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: canvasColors.map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, color); // Return the selected color
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: color == currentColor 
                        ? Colors.blue 
                        : Colors.grey,
                    width: color == currentColor ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: color == currentColor
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}