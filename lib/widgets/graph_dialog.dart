// graph_dialog.dart
import 'package:flutter/material.dart';

class GraphDialog extends StatefulWidget {
  final Function(String) onPlotRequested;
  
  const GraphDialog({
    Key? key,
    required this.onPlotRequested,
  }) : super(key: key);

  @override
  _GraphDialogState createState() => _GraphDialogState();
}

class _GraphDialogState extends State<GraphDialog> {
  final TextEditingController _equationController = TextEditingController();
  final List<String> _exampleEquations = [
    'x^2',
    'sin(x)',
    'cos(x)',
    'tan(x)',
    'x',
    '1/x'
  ];
  
  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Plot Graph'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _equationController,
            decoration: const InputDecoration(
              labelText: 'Enter equation (e.g., x^2, sin(x))',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Example Equations:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _exampleEquations.map((eq) => 
              ActionChip(
                label: Text(eq),
                onPressed: () {
                  _equationController.text = eq;
                },
              )
            ).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_equationController.text.isNotEmpty) {
              widget.onPlotRequested(_equationController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Plot'),
        ),
      ],
    );
  }
}