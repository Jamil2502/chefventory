class UserModel {
  final String id;
  final String email;
  final String role; // 'admin' or 'staff'
  final String? restaurantId;
  final String? restaurantName;
  final String? adminEmail; // For staff users
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.restaurantId,
    this.restaurantName,
    this.adminEmail,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      restaurantId: data['restaurantId'],
      restaurantName: data['restaurantName'],
      adminEmail: data['adminEmail'],
      isVerified: data['isVerified'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'adminEmail': adminEmail,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
