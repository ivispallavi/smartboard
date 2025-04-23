import 'package:flutter/material.dart';

class GridSettings {
  final double squareSize;
  final double scale;
  final Color color;
  final double lineWidth;

  const GridSettings({
    this.squareSize = 50.0,
    this.scale = 1.0,
    this.color = const Color.fromRGBO(128, 128, 128, 0.5),
    this.lineWidth = 0.5,
  });
}

class GridPainter extends CustomPainter {
  final double squareSize;
  final double gridWidth;
  final double lineWidth;
  final Color lineColor;

  GridPainter({
    required this.squareSize,
    required this.gridWidth,
    this.lineWidth = 0.5,
    this.lineColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke;

    // Only draw grid in the 2/5th width area
    double limitedWidth = gridWidth;

    // Draw vertical lines for the grid
    for (double i = 0; i <= limitedWidth; i += squareSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines for the grid
    for (double i = 0; i <= size.height; i += squareSize) {
      canvas.drawLine(Offset(0, i), Offset(limitedWidth, i), paint);
    }

    // Draw a boundary for the grid
    canvas.drawRect(
      Rect.fromLTWH(0, 0, limitedWidth, size.height),
      paint..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.squareSize != squareSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridWidth != gridWidth;
  }
}

class ImageToggleButton extends StatelessWidget {
  final Function() onToggle;
  final bool isVisible;

  const ImageToggleButton({
    Key? key,
    required this.onToggle,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isVisible ? Icons.image_not_supported : Icons.image),
      onPressed: onToggle,
      tooltip: isVisible ? 'Hide Grid' : 'Show Grid',
      color: Colors.black,
    );
  }
}

class GridWidget extends StatelessWidget {
  final GridSettings settings;
  final Size size;
  final bool isVisible;

  const GridWidget({
    Key? key,
    required this.settings,
    required this.size,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    // Calculate 2/5th of screen width for grid area
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth * 2 / 5;

    return CustomPaint(
      painter: GridPainter(
        squareSize: settings.squareSize * settings.scale,
        gridWidth: gridWidth,
        lineWidth: settings.lineWidth,
        lineColor: settings.color,
      ),
      size: size,
    );
  }
}
