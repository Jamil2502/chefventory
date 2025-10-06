import 'package:cloud_firestore/cloud_firestore.dart';

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
    double alertThreshold = 0,
    DateTime? lastUpdated,
    String? ingredientId,
  })  : _ingredientId = ingredientId ?? 'ing_${++_idCounter}',
        _name = name,
        _currentStock = initialStock,
        _unit = unit,
        _expiryDate = expiryDate,
        _alertThreshold = alertThreshold,
        _lastUpdated = lastUpdated ?? DateTime.now();

  // Getters
  String get ingredientId => _ingredientId;
  String get name => _name;
  double get currentStock => _currentStock;
  String get unit => _unit;
  DateTime? get expiryDate => _expiryDate;
  double get alertThreshold => _alertThreshold;
  DateTime get lastUpdated => _lastUpdated;

  // Stock management
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

  // Alert threshold management
  void updateAlertThreshold(double threshold) {
    if (threshold >= 0) {
      _alertThreshold = threshold;
    }
  }

  // Expiry management
  bool updateExpiryDate(DateTime? newExpiryDate) {
    _expiryDate = newExpiryDate;
    return true;
  }

  // Stock and expiry checks
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

  // Serialization for Firestore
  Map<String, dynamic> toMap() {
    return {
      'ingredientId': _ingredientId,
      'name': _name,
      'currentStock': _currentStock,
      'unit': _unit,
      'expiryDate': _expiryDate != null ? Timestamp.fromDate(_expiryDate!) : null,
      'alertThreshold': _alertThreshold,
      'lastUpdated': Timestamp.fromDate(_lastUpdated),
    };
  }

  // Deserialization from Firestore
  static Ingredient fromMap(String id, Map<String, dynamic> data) {
    return Ingredient(
      ingredientId: data['ingredientId'] ?? id,
      name: data['name'] ?? '',
      initialStock: (data['currentStock'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] is Timestamp
              ? (data['expiryDate'] as Timestamp).toDate()
              : DateTime.tryParse(data['expiryDate'].toString()))
          : null,
      alertThreshold: (data['alertThreshold'] ?? 0).toDouble(),
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] is Timestamp
              ? (data['lastUpdated'] as Timestamp).toDate()
              : DateTime.tryParse(data['lastUpdated'].toString()))
          : null,
    );
  }
}