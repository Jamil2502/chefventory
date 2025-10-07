class RestaurantModel {
  final String id;
  final String name;
  final String adminEmail;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.adminEmail,
    required this.createdAt,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> data, String id) {
    return RestaurantModel(
      id: id,
      name: data['name'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminEmail': adminEmail,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
