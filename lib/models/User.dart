

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? role;
  String? token;

  User({this.id, this.firstName, this.lastName, this.email, this.password, this.role, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      token: json['token'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  String? getEasyName() {
    if(firstName != null && lastName != null) {
      return '${firstName!} ${lastName!}';
    } else {
      return email;
    }
  }
}