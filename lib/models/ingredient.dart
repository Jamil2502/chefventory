class Ingredient {
  final String ingredientId;
  final String name;
  double currentStock;
  final String unit;
  double alertThreshold;
  final DateTime? expiryDate;
  DateTime? lastUpdated;

  Ingredient({
    required this.ingredientId,
    required this.name,
    required this.currentStock,
    required this.unit,
    required this.alertThreshold,
    required this.expiryDate,
    required this.lastUpdated,
  });

  factory Ingredient.fromMap(String id, Map<String, dynamic> map) {
    // Accepts both DateTime and String dates
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d);
      // Firestore Timestamp or int msSinceEpoch
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      if (d.toString().contains('Timestamp')) {
        return (d as dynamic).toDate();
      }
      return null;
    }

    return Ingredient(
      ingredientId: id,
      name: map['name'] ?? '',
      currentStock: (map['currentStock'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
      alertThreshold: (map['alertThreshold'] as num?)?.toDouble() ?? 0,
      expiryDate: parseDate(map['expiryDate']),
      lastUpdated: parseDate(map['lastUpdated']),
    );
  }

  bool isLowStock() => currentStock <= alertThreshold;

  bool isExpired() =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool isExpiringSoon([int days = 3]) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final soon = now.add(Duration(days: days));
    return expiryDate!.isAfter(now) && expiryDate!.isBefore(soon);
  }
}
