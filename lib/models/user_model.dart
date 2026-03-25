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
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      group: json['group'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'group': group,
    };
  }
}
