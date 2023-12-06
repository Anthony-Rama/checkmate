class UserModel {
  final String id;
  final String email;
  final String password;

  UserModel({required this.id, required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
}
