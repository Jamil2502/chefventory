class Ingredient {
  final String _ingredientId;
  final String _name;
  double _currentStock;
  final String _unit;
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
}
