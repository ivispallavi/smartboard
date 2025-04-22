// graph_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class GraphService {
  // AI parsing and plotting logic
  static List<DrawingPoint> plotEquation(
    String equation, 
    double width, 
    double height, 
    Offset origin,
    Color color,
    double strokeWidth
  ) {
    List<DrawingPoint> points = [];
    
    // Parse equation using a simple format for now
    // Will be enhanced with AI capabilities
    
    try {
      // Create coordinate system with origin at the center
      double xMin = -5.0;
      double xMax = 5.0;
      double yMin = -5.0;
      double yMax = 5.0;
      
      // Scale factors
      double xScale = width / (xMax - xMin);
      double yScale = height / (yMax - yMin);
      
      // Draw x and y axes
      // X-axis
      points.add(DrawingPoint(
        Offset(origin.dx - width/2, origin.dy),
        Colors.black,
        1.0
      ));
      points.add(DrawingPoint(
        Offset(origin.dx + width/2, origin.dy),
        Colors.black,
        1.0
      ));
      points.add(DrawingPoint.endStroke());
      
      // Y-axis
      points.add(DrawingPoint(
        Offset(origin.dx, origin.dy - height/2),
        Colors.black,
        1.0
      ));
      points.add(DrawingPoint(
        Offset(origin.dx, origin.dy + height/2),
        Colors.black,
        1.0
      ));
      points.add(DrawingPoint.endStroke());
      
      // Plot equation
      Offset? prevPoint;
      
      // Generate 200 points for smooth curve
      for (int i = 0; i <= 200; i++) {
        double x = xMin + i * (xMax - xMin) / 200;
        
        // Evaluate y = f(x) based on the equation
        double y = _evaluateEquation(equation, x);
        
        // Convert to screen coordinates
        Offset screenPoint = Offset(
          origin.dx + x * xScale,
          origin.dy - y * yScale, // Flipped because screen y grows downward
        );
        
        if (i > 0 && prevPoint != null) {
          points.add(DrawingPoint(prevPoint, color, strokeWidth));
          points.add(DrawingPoint(screenPoint, color, strokeWidth));
        }
        
        prevPoint = screenPoint;
      }
      
      // End the stroke
      points.add(DrawingPoint.endStroke());
      
    } catch (e) {
      print('Error plotting equation: $e');
    }
    
    return points;
  }
  
  // Simple equation parser and evaluator
  static double _evaluateEquation(String equation, double x) {
    // This is a placeholder for the AI parsing logic
    // For now, we'll implement a few basic equations
    
    equation = equation.toLowerCase().trim();
    
    if (equation == 'x^2' || equation == 'x²') {
      return x * x;
    } else if (equation == 'sin(x)') {
      return sin(x);
    } else if (equation == 'cos(x)') {
      return cos(x);
    } else if (equation == 'tan(x)') {
      return tan(x);
    } else if (equation == 'x') {
      return x;
    } else if (equation == '1/x') {
      return x != 0 ? 1/x : double.infinity;
    } else {
      // Default to a parabola
      return x * x;
    }
  }
  
  // In the future, integrate with an AI service for more complex equation parsing
  static Future<List<DrawingPoint>> plotWithAI(
    String equation,
    double width,
    double height,
    Offset origin,
    Color color,
    double strokeWidth
  ) async {
    // This would connect to an AI service to parse more complex equations
    // For now, use the simple parser
    return plotEquation(equation, width, height, origin, color, strokeWidth);
  }
}