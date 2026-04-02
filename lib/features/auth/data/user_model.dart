class UserModel {
  final int id;
  final String username;
  final String email;
  final String group;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.group,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Parsing angka yang jauh lebih aman (Anti Null-Crash)
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,

      // Parsing string yang jauh lebih aman
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      group: json['group']?.toString() ?? 'guru',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, 'group': group};
  }
}
