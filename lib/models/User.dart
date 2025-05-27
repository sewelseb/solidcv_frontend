

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
   List<String>? roles;
  String? token;
  String? ethereumAddress;

  User({this.id, this.firstName, this.lastName, this.email, this.password, this.roles, this.token, this.ethereumAddress});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      roles: json['roles'] != null
          ? List<String>.from(json['roles']) // ✅ conversion
          : null,
      token: json['token'],
      ethereumAddress: json['ethereumAddress'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'roles': roles,
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