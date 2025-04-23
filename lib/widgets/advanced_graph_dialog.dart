import 'package:flutter/material.dart';
import '../models/graph_settings_model.dart';
import '../services/nlp_graph_service.dart';

class AdvancedGraphDialog extends StatefulWidget {
  final Function(GraphSettings) onPlotRequested;
  
  const AdvancedGraphDialog({
    Key? key,
    required this.onPlotRequested,
  }) : super(key: key);

  @override
  _AdvancedGraphDialogState createState() => _AdvancedGraphDialogState();
}

class _AdvancedGraphDialogState extends State<AdvancedGraphDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _equationController = TextEditingController();
  final TextEditingController _nlpInputController = TextEditingController();
  
  GraphSettings _settings = GraphSettings(equation: 'x^2');
  bool _showAdvanced = false;
  bool _processingNLP = false;
  String? _errorMessage;
  String? _suggestion;
  
  // For tab controller
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _equationController.dispose();
    _nlpInputController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  void _toggleAdvanced() {
    setState(() {
      _showAdvanced = !_showAdvanced;
    });
  }
  
  void _processNaturalLanguage() async {
    final text = _nlpInputController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _processingNLP = true;
      _suggestion = null;
    });
    
    // Process the natural language input
    try {
      final equation = await NLPGraphService.extractEquationFromText(text);
      
      if (equation != null) {
        setState(() {
          _suggestion = equation;
          _processingNLP = false;
        });
      } else {
        setState(() {
          _suggestion = null;
          _processingNLP = false;
          _errorMessage = "Couldn't extract an equation from text. Try being more specific.";
        });
      }
    } catch (e) {
      setState(() {
        _processingNLP = false;
        _errorMessage = "An error occurred while processing your request.";
      });
    }
  }
  
  void _applyNLPSuggestion() {
    if (_suggestion != null) {
      _equationController.text = _suggestion!;
      _tabController.animateTo(0); // Switch to equation tab
      setState(() {
        _settings = _settings.copyWith(equation: _suggestion);
        _suggestion = null;
      });
    }
  }
  
  Widget _buildEquationTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
              prefixIcon: const Icon(Icons.functions),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _equationController.clear(),
              ),
            ),
            onChanged: (value) {
              // Improve the equation as the user types
              String improved = NLPGraphService.improveEquation(value);
              if (improved != value) {
                _equationController.text = improved;
                _equationController.selection = TextSelection.fromPosition(
                  TextPosition(offset: improved.length)
                );
              }
              
              setState(() {
                _settings = _settings.copyWith(equation: improved);
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Equation presets
          const Text('Common Equations:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildEquationChip('x^2', 'Parabola'),
              _buildEquationChip('sin(x)', 'Sine'),
              _buildEquationChip('cos(x)', 'Cosine'),
              _buildEquationChip('x^3', 'Cubic'),
              _buildEquationChip('sqrt(x)', 'Square Root'),
              _buildEquationChip('1/x', 'Reciprocal'),
              _buildEquationChip('abs(x)', 'Absolute'),
            ],
          ),
          
          // Advanced options toggle
          const SizedBox(height: 16),
          InkWell(
            onTap: _toggleAdvanced,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showAdvanced 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  _showAdvanced ? 'Hide Advanced Options' : 'Show Advanced Options',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Advanced options
          if (_showAdvanced)
            _buildAdvancedOptions(),
        ],
      ),
    );
  }
  
  Widget _buildNaturalLanguageTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nlpInputController,
            decoration: const InputDecoration(
              labelText: 'Describe the graph you want to plot',
              border: OutlineInputBorder(),
              hintText: 'E.g., "Plot a parabola" or "Draw y = sin(x)"',
              prefixIcon: Icon(Icons.psychology),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Process with AI'),
              onPressed: _processingNLP ? null : _processNaturalLanguage,
            ),
          ),
          
          if (_processingNLP)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          if (_suggestion != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Suggestion:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Equation: $_suggestion',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: ElevatedButton(
                          onPressed: _applyNLPSuggestion,
                          child: const Text('Use This Equation'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          if (_errorMessage != null && _suggestion == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            
          const SizedBox(height: 16),
          const Text(
            'Examples to try:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildExampleNLPChip('Plot a parabola'),
          _buildExampleNLPChip('Draw y = sin(x)'),
          _buildExampleNLPChip('Graph a cubic function'),
          _buildExampleNLPChip('Plot a line with slope 2'),
        ],
      ),
    );
  }
  
  Widget _buildAdvancedOptions() {
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // X range
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'X Min',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _settings.xMin.toString()),
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(
                      xMin: double.tryParse(value) ?? _settings.xMin
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'X Max',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _settings.xMax.toString()),
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(
                      xMax: double.tryParse(value) ?? _settings.xMax
                    );
                  });
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Y range
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Y Min',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _settings.yMin.toString()),
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(
                      yMin: double.tryParse(value) ?? _settings.yMin
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Y Max',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _settings.yMax.toString()),
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(
                      yMax: double.tryParse(value) ?? _settings.yMax
                    );
                  });
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Display options
        SwitchListTile(
          title: const Text('Show Grid'),
          value: _settings.showGrid,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(showGrid: value);
            });
          },
        ),
        
        SwitchListTile(
          title: const Text('Show Axes'),
          value: _settings.showAxes,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(showAxes: value);
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildEquationChip(String equation, String label) {
    return ActionChip(
      avatar: const Icon(Icons.functions, size: 16),
      label: Text(label),
      backgroundColor: Colors.blue.withOpacity(0.1),
      onPressed: () {
        _equationController.text = equation;
        setState(() {
          _settings = _settings.copyWith(equation: equation);
        });
      },
    );
  }
  
  Widget _buildExampleNLPChip(String text) {
    return ActionChip(
      avatar: const Icon(Icons.psychology, size: 16),
      label: Text(text),
      backgroundColor: Colors.green.withOpacity(0.1),
      onPressed: () {
        _nlpInputController.text = text;
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.auto_graph, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('AI Graph Plotter'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help information
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Graph Plotting Help'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Supported functions:'),
                        SizedBox(height: 8),
                        Text('• Basic: x^2, 2*x+1'),
                        Text('• Trig: sin(x), cos(x), tan(x)'),
                        Text('• Other: sqrt(x), abs(x)'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tab bar for equation vs natural language
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.functions),
                  text: 'Equation',
                ),
                Tab(
                  icon: Icon(Icons.psychology),
                  text: 'Natural Language',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tab content
            SizedBox(
              height: _showAdvanced ? 450 : 250,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEquationTab(),
                  _buildNaturalLanguageTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.auto_graph),
          label: const Text('Plot Graph'),
          onPressed: () {
            if (_tabController.index == 0) {
              // Using equation tab
              final equation = _equationController.text.trim();
              if (equation.isNotEmpty) {
                _settings = _settings.copyWith(equation: equation);
                widget.onPlotRequested(_settings);
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _errorMessage = 'Please enter an equation';
                });
              }
            } else {
              // Using NLP tab
              if (_suggestion != null) {
                _settings = _settings.copyWith(equation: _suggestion!);
                widget.onPlotRequested(_settings);
                Navigator.of(context).pop();
              } else {
                // Prompt user to process with AI first
                setState(() {
                  _errorMessage = 'Please process your text with AI first';
                });
              }
            }
          },
        ),
      ],
    );
  }
}