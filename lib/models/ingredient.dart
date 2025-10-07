class Ingredient {
  String _ingredientId;
  String _name;
  double _currentStock; 
  String _unit; 
  DateTime? _expiryDate;
  double _alertThreshold; 
  DateTime _lastUpdated; 
  static int _idCounter = 1000;

  Ingredient({
    required String name,
    required double initialStock,
    required String unit,
    DateTime? expiryDate,
  }) : _ingredientId = 'ing_${++_idCounter}',
        _name = name,
        _currentStock = initialStock,
        _unit = unit,
        _expiryDate = expiryDate,
        _alertThreshold = 0, 
        _lastUpdated = DateTime.now();

  String get ingredientId => _ingredientId;
  String get name => _name;
  double get currentStock => _currentStock;
  String get unit => _unit;
  DateTime? get expiryDate => _expiryDate;
  double get alertThreshold => _alertThreshold;
  DateTime get lastUpdated => _lastUpdated;

  bool consumeStock(double amount) {
    if (amount > 0 && amount <= _currentStock) {
      _currentStock -= amount;
      _lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  bool addStock(double amount) {
    if (amount > 0) {
      _currentStock += amount;
      _lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  void updateAlertThreshold(double threshold) {
    if (threshold >= 0) {
      _alertThreshold = threshold;
    }
  }

  bool updateExpiryDate(DateTime? newExpiryDate) {
    _expiryDate = newExpiryDate;
    return true;
  }

  bool isLowStock() => _currentStock <= _alertThreshold;
  
  bool isExpiringSoon([int daysAhead = 7]) {
    if (_expiryDate == null) return false;
    final alertDate = DateTime.now().add(Duration(days: daysAhead));
    return _expiryDate!.isBefore(alertDate);
  }

  bool isExpired() {
    if (_expiryDate == null) return false;
    return _expiryDate!.isBefore(DateTime.now());
  }

  factory Ingredient.fromFirestore(Map<String, dynamic> data, String id) {
    return Ingredient(
      name: data['name'] ?? '',
      initialStock: (data['currentStock'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? 'g',
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate'])
          : null,
    )
    .._ingredientId = data['ingredientId'] ?? id
    .._alertThreshold = (data['alertThreshold'] as num?)?.toDouble() ?? 0.0
    .._lastUpdated = data['lastUpdated'] != null
        ? DateTime.parse(data['lastUpdated'])
        : DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': _ingredientId,
      'name': _name,
      'currentStock': _currentStock,
      'unit': _unit,
      'expiryDate': _expiryDate?.toIso8601String(),
      'alertThreshold': _alertThreshold,
      'lastUpdated': _lastUpdated.toIso8601String(),
    };
  }
}