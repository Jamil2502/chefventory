class User {
  final String _userId;
  String _username;
  String _email;
  final String _role;
  static int _idCounter = 1000;

  User({required String username, required String email, required String role})
    : _userId = 'user_${++_idCounter}',
      _username = username,
      _email = email,
      _role = role;

  String get userId => _userId;
  String get username => _username;
  String get email => _email;
  String get role => _role;

  void updateUsername(String newUsername) => _username = newUsername;
  void updateEmail(String newEmail) => _email = newEmail;

  bool canManageInventory() => _role == 'admin';
  bool canViewAnalytics() => _role == 'admin';
  bool canProcessOrders() => true;
  bool canViewStock() => true;
}
