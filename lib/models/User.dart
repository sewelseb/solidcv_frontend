import 'package:solid_cv/config/BackenConnection.dart';

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;
  String? biography;
  String? linkedin;
  String? profilePicture;
  String? cv;
  List<String>? roles;
  String? token;
  String? ethereumAddress;
  bool? isVerified;
  bool? isFirstConfigurationDone;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.phoneNumber,
    this.biography,
    this.linkedin,
    this.profilePicture,
    this.cv,
    this.roles,
    this.token,
    this.ethereumAddress,
    this.isVerified,
    this.isFirstConfigurationDone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      biography: json['biography'],
      linkedin: json['linkedin'],
      profilePicture: json['profilePicture'],
      cv: json['cv'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      token: json['token'],
      ethereumAddress: json['ethereumAddress'],
      isVerified: json['isVerified'],
      isFirstConfigurationDone: json['firstConfigurationDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'biography': biography,
      'linkedin': linkedin,
      'profilePicture': profilePicture,
      'cv': cv,
      'roles': roles,
      'token': token,
      'ethereumAddress': ethereumAddress,
    };
  }

  String? getEasyName() {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else {
      return email;
    }
  }

    String getProfilePicture() {
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      return BackenConnection().url +
          BackenConnection().userProfilePicFolder +
          (profilePicture as String);
    }
    return '${BackenConnection().url}${BackenConnection().imageAssetFolder}user.png';
  }
}