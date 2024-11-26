class User {
  String? id;
  String? name;
  String? email;
  String? password;
  String? role;
  String? token;

  User({this.id, this.name, this.email, this.password, this.role, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      token: json['token'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}