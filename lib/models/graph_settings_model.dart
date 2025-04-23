class GraphSettings {
  final String equation;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final int numPoints;
  final bool showGrid;
  final bool showAxes;
  final bool useAI;
  
  GraphSettings({
    required this.equation,
    this.xMin = -5.0,
    this.xMax = 5.0,
    this.yMin = -5.0,
    this.yMax = 5.0,
    this.numPoints = 300,
    this.showGrid = true,
    this.showAxes = true,
    this.useAI = true,
  });
  
  // Create a copy with modified values
  GraphSettings copyWith({
    String? equation,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    int? numPoints,
    bool? showGrid,
    bool? showAxes,
    bool? useAI,
  }) {
    return GraphSettings(
      equation: equation ?? this.equation,
      xMin: xMin ?? this.xMin,
      xMax: xMax ?? this.xMax,
      yMin: yMin ?? this.yMin,
      yMax: yMax ?? this.yMax,
      numPoints: numPoints ?? this.numPoints,
      showGrid: showGrid ?? this.showGrid,
      showAxes: showAxes ?? this.showAxes,
      useAI: useAI ?? this.useAI,
    );
  }
}