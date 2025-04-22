import 'dart:math';
import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class MathParser {
  // This class will simulate AI-powered parsing of mathematical expressions
  
  // Tokenize the equation
  static List<String> _tokenize(String equation) {
    equation = equation.replaceAll(' ', '');
    
    List<String> tokens = [];
    String currentToken = '';
    
    for (int i = 0; i < equation.length; i++) {
      String char = equation[i];
      
      if (char == '+' || char == '-' || char == '*' || char == '/' || 
          char == '(' || char == ')' || char == '^') {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken);
          currentToken = '';
        }
        tokens.add(char);
      } else {
        currentToken += char;
      }
    }
    
    if (currentToken.isNotEmpty) {
      tokens.add(currentToken);
    }
    
    return tokens;
  }
  
  // Evaluate a mathematical expression
  static double evaluate(String expression, double x) {
    // Replace x with the actual value
    expression = expression.replaceAll('x', x.toString());
    
    // Handle special functions
    expression = _handleSpecialFunctions(expression);
    
    try {
      // Use a recursive descent parser or a library for more complex parsing
      // For demonstration, we'll use a simplified approach
      return _evaluateExpression(expression);
    } catch (e) {
      print('Error evaluating expression: $e');
      return 0;
    }
  }
  
  // Handle special mathematical functions
  static String _handleSpecialFunctions(String expression) {
    // Replace sin(value) with the result
    expression = _replaceFunction(expression, 'sin', sin);
    
    // Replace cos(value) with the result
    expression = _replaceFunction(expression, 'cos', cos);
    
    // Replace tan(value) with the result
    expression = _replaceFunction(expression, 'tan', tan);
    
    // Replace sqrt(value) with the result
    expression = _replaceFunction(expression, 'sqrt', sqrt);
    
    // Replace abs(value) with the result
    expression = _replaceFunction(expression, 'abs', (x) => x.abs());
    
    // Handle exponents
    expression = _handleExponents(expression);
    
    return expression;
  }
  
  // Replace function calls with their values
  static String _replaceFunction(String expression, String funcName, Function func) {
    RegExp regex = RegExp('$funcName\\(([^\\(\\)]+)\\)');
    Iterable<Match> matches = regex.allMatches(expression);
    
    String result = expression;
    for (Match match in matches) {
      String argument = match.group(1)!;
      double value = _evaluateExpression(argument);
      double funcResult = func(value);
      result = result.replaceFirst(match.group(0)!, funcResult.toString());
    }
    
    return result;
  }
  
  // Handle exponent expressions (e.g., 2^3)
  static String _handleExponents(String expression) {
    RegExp regex = RegExp('(\\d+\\.?\\d*)\\^(\\d+\\.?\\d*)');
    Iterable<Match> matches = regex.allMatches(expression);
    
    String result = expression;
    for (Match match in matches) {
      double base = double.parse(match.group(1)!);
      double exponent = double.parse(match.group(2)!);
      double value = pow(base, exponent).toDouble();
      result = result.replaceFirst(match.group(0)!, value.toString());
    }
    
    return result;
  }
  
  // Simple expression evaluator
  static double _evaluateExpression(String expression) {
    // This is a simplified evaluator; in a real app, you'd use a proper parsing library
    // or integrate with an AI service
    try {
      return double.parse(expression);
    } catch (e) {
      // If it's not a simple number, try to evaluate it as an arithmetic expression
      if (expression.contains('+')) {
        List<String> parts = expression.split('+');
        return parts.map((p) => _evaluateExpression(p)).reduce((a, b) => a + b);
      } else if (expression.contains('-')) {
        // Be careful with negative numbers
        int lastIndex = expression.lastIndexOf('-');
        if (lastIndex == 0) {
          return -_evaluateExpression(expression.substring(1));
        }
        String left = expression.substring(0, lastIndex);
        String right = expression.substring(lastIndex + 1);
        return _evaluateExpression(left) - _evaluateExpression(right);
      } else if (expression.contains('*')) {
        List<String> parts = expression.split('*');
        return parts.map((p) => _evaluateExpression(p)).reduce((a, b) => a * b);
      } else if (expression.contains('/')) {
        List<String> parts = expression.split('/');
        return parts.map((p) => _evaluateExpression(p)).reduce((a, b) => a / b);
      }
    }
    
    // Default return
    return 0;
  }
}

class AIGraphService {
  // Plot an equation using the AI-powered math parser
  static List<DrawingPoint> plotEquation(
    String equation,
    double width,
    double height,
    Offset origin,
    Color color,
    double strokeWidth
  ) {
    List<DrawingPoint> points = [];
    
    try {
      // Define the coordinate system
      double xMin = -5.0;
      double xMax = 5.0;
      double yMin = -5.0;
      double yMax = 5.0;
      
      // Scale factors
      double xScale = width / (xMax - xMin);
      double yScale = height / (yMax - yMin);
      
      // Draw coordinate axes
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
      
      // Draw tick marks on x-axis
      for (int i = -5; i <= 5; i++) {
        if (i == 0) continue; // Skip origin
        
        double x = origin.dx + i * xScale;
        
        // Tick mark
        points.add(DrawingPoint(
          Offset(x, origin.dy - 5),
          Colors.black,
          1.0
        ));
        points.add(DrawingPoint(
          Offset(x, origin.dy + 5),
          Colors.black,
          1.0
        ));
        points.add(DrawingPoint.endStroke());
        
        // Label
        // (In a real implementation, you'd use canvas.drawText here)
      }
      
      // Draw tick marks on y-axis
      for (int i = -5; i <= 5; i++) {
        if (i == 0) continue; // Skip origin
        
        double y = origin.dy - i * yScale;
        
        // Tick mark
        points.add(DrawingPoint(
          Offset(origin.dx - 5, y),
          Colors.black,
          1.0
        ));
        points.add(DrawingPoint(
          Offset(origin.dx + 5, y),
          Colors.black,
          1.0
        ));
        points.add(DrawingPoint.endStroke());
        
        // Label would go here in a real implementation
      }
      
      // Plot the equation
      Offset? prevPoint;
      bool prevPointValid = false;
      
      // Use more points for a smoother curve
      for (int i = 0; i <= 300; i++) {
        double x = xMin + i * (xMax - xMin) / 300;
        
        // Evaluate using our AI math parser
        double y;
        try {
          y = MathParser.evaluate(equation, x);
          
          // Check if the result is within reasonable bounds
          if (y.isNaN || y.isInfinite || y.abs() > 100) {
            prevPointValid = false;
            continue;
          }
          
          // Convert to screen coordinates
          Offset screenPoint = Offset(
            origin.dx + x * xScale,
            origin.dy - y * yScale, // Flip y since screen coordinates grow downward
          );
          
          // Add points to draw line segments
          if (prevPointValid && prevPoint != null) {
            points.add(DrawingPoint(prevPoint, color, strokeWidth));
            points.add(DrawingPoint(screenPoint, color, strokeWidth));
            points.add(DrawingPoint.endStroke());
          }
          
          prevPoint = screenPoint;
          prevPointValid = true;
        } catch (e) {
          prevPointValid = false;
        }
      }
      
    } catch (e) {
      print('Error plotting equation: $e');
    }
    
    return points;
  }
}