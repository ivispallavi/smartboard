// lib/models/drawing_point.dart
import 'package:flutter/material.dart';

enum DrawingMode { pen, eraser, none }

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isDeleted;
  final bool isEndOfStroke;

  DrawingPoint(
    this.offset,
    this.color,
    this.strokeWidth, {
    this.isDeleted = false,
    this.isEndOfStroke = false,
  });

  factory DrawingPoint.endStroke() {
    return DrawingPoint(
      Offset.zero,
      Colors.transparent,
      0,
      isEndOfStroke: true,
    );
  }
}
