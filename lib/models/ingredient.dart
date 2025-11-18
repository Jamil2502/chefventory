import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String _ingredientId;
  final String _name;
  double _currentStock;
  final String _unit;
  DateTime? _expiryDate;
  double _alertThreshold;
  DateTime _lastUpdated;
  static int _idCounter = 1000;

  // Update the counter if we load an ID that's higher than current counter
  static void updateCounterIfNeeded(String ingredientId) {
    // Parse ID like 'ing_1234' to extract number
    if (ingredientId.startsWith('ing_')) {
      try {
        final idNum = int.parse(ingredientId.substring(4));
        if (idNum >= _idCounter) {
          _idCounter = idNum;
        }
      } catch (_) {}
    }
  }

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

  // Create an Ingredient from Firestore / map data and an explicit id
  Ingredient._fromData({
    required String ingredientId,
    required String name,
    required double currentStock,
    required String unit,
    DateTime? expiryDate,
    double alertThreshold = 0,
    DateTime? lastUpdated,
  }) : _ingredientId = ingredientId,
       _name = name,
       _currentStock = currentStock,
       _unit = unit,
       _expiryDate = expiryDate,
       _alertThreshold = alertThreshold,
       _lastUpdated = lastUpdated ?? DateTime.now();

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

  Map<String, dynamic> toMap() {
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

  factory Ingredient.fromMap(String id, Map<String, dynamic> map) {
    // IMPORTANT: Update static counter when loading from Firestore
    // This prevents duplicate IDs when app restarts
    updateCounterIfNeeded(id);

    DateTime? expiry;
    if (map['expiryDate'] != null) {
      final v = map['expiryDate'];
      if (v is DateTime) expiry = v;
      else if (v is String) expiry = DateTime.tryParse(v);
      else if (v is Timestamp) expiry = v.toDate();
    }

    double currentStock = 0;
    if (map['currentStock'] is num) currentStock = (map['currentStock'] as num).toDouble();
    else if (map['currentStock'] is String) currentStock = double.tryParse(map['currentStock']) ?? 0;

    double alert = 0;
    if (map['alertThreshold'] is num) alert = (map['alertThreshold'] as num).toDouble();
    else if (map['alertThreshold'] is String) alert = double.tryParse(map['alertThreshold']) ?? 0;

    DateTime? lastUpdated;
    if (map['lastUpdated'] != null) {
      final lu = map['lastUpdated'];
      if (lu is DateTime) lastUpdated = lu;
      else if (lu is String) lastUpdated = DateTime.tryParse(lu);
      else if (lu is Timestamp) lastUpdated = lu.toDate();
    }

    return Ingredient._fromData(
      ingredientId: id,
      name: map['name'] ?? '',
      currentStock: currentStock,
      unit: map['unit'] ?? '',
      expiryDate: expiry,
      alertThreshold: alert,
      lastUpdated: lastUpdated,
    );
  }
}
