import 'package:flutter/material.dart';

class EnhancedGraphDialog extends StatefulWidget {
  final Function(String, bool) onPlotRequested;
  
  const EnhancedGraphDialog({
    Key? key,
    required this.onPlotRequested,
  }) : super(key: key);

  @override
  _EnhancedGraphDialogState createState() => _EnhancedGraphDialogState();
}

class _EnhancedGraphDialogState extends State<EnhancedGraphDialog> {
  final TextEditingController _equationController = TextEditingController();
  final List<String> _exampleEquations = [
    'x^2',
    'sin(x)',
    'cos(x)',
    'tan(x)',
    '2*x+1',
    'x^3-3*x',
    'sqrt(x)'
  ];
  
  bool _useAI = true;
  bool _isProcessing = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }
  
  // Method to check if equation is valid
  bool _validateEquation(String equation) {
    if (equation.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an equation';
      });
      return false;
    }
    
    // Basic validation - check for containing 'x'
    if (!equation.contains('x')) {
      setState(() {
        _errorMessage = 'Equation should contain variable x';
      });
      return false;
    }
    
    setState(() {
      _errorMessage = null;
    });
    return true;
  }
  
  // Method to suggest equation improvements
  String _suggestImprovement(String equation) {
    String improved = equation.trim();
    
    // Replace ² with ^2
    improved = improved.replaceAll('²', '^2');
    improved = improved.replaceAll('³', '^3');
    
    // Add multiplication where needed
    improved = improved.replaceAll('(x)', '(x)');
    
    // Replace common errors
    if (improved == 'sinx') improved = 'sin(x)';
    if (improved == 'cosx') improved = 'cos(x)';
    if (improved == 'tanx') improved = 'tan(x)';
    
    return improved;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.functions, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('AI Graph Plotter'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _equationController,
              decoration: InputDecoration(
                labelText: 'Enter equation (e.g., x^2, sin(x))',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
                hintText: 'Try: 2*x^2+3*x-4',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _equationController.clear(),
                ),
              ),
              onChanged: (value) {
                // Auto-suggest improvements
                String improved = _suggestImprovement(value);
                if (improved != value) {
                  _equationController.text = improved;
                  _equationController.selection = TextSelection.fromPosition(
                    TextPosition(offset: improved.length)
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Toggle for AI mode
            SwitchListTile(
              title: const Text('Use AI-powered plotting'),
              subtitle: const Text('For complex equations'),
              value: _useAI,
              onChanged: (value) {
                setState(() {
                  _useAI = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            const Text('Example Equations:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exampleEquations.map((eq) => 
                ActionChip(
                  label: Text(eq),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  onPressed: () {
                    _equationController.text = eq;
                  },
                )
              ).toList(),
            ),
            
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing 
            ? null 
            : () {
                final equation = _equationController.text.trim();
                if (_validateEquation(equation)) {
                  setState(() {
                    _isProcessing = true;
                  });
                  
                  // Wait a moment to simulate AI processing
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
                      widget.onPlotRequested(equation, _useAI);
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
          child: const Text('Plot Graph'),
        ),
      ],
    );
  }
}