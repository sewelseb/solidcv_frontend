import 'package:solid_cv/config/BackenConnection.dart';

class Company {
  final int? id;
  final String? name;
  final String? addressNumber;
  final String? addressStreet;
  final String? addressCity;
  final String? addressZipCode;
  final String? addressCountry;
  final String? phoneNumber;
  final String? email;
  final String? ethereumAddress;
  final String? profilePicture;

  Company({
    this.id,
    required this.name,
    required this.addressNumber,
    required this.addressStreet,
    required this.addressCity,
    required this.addressZipCode,
    required this.addressCountry,
    required this.phoneNumber,
    required this.email,
    this.ethereumAddress,
    this.profilePicture,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      addressNumber: json['addressNumber'],
      addressStreet: json['addressStreet'],
      addressCity: json['addressCity'],
      addressZipCode: json['addressZipCode'],
      addressCountry: json['addressCountry'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      ethereumAddress: json['ethereumAddress'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addressNumber': addressNumber,
      'addressStreet': addressStreet,
      'addressCity': addressCity,
      'addressZipCode': addressZipCode,
      'addressCountry': addressCountry,
      'phoneNumber': phoneNumber,
      'email': email,
      'ethereumAddress': ethereumAddress,
      'profilePicture': profilePicture,
    };
  }

  getFullAddress() {
    return getSafeAdressNumber() + ' ' + getSafeAdressStreet() + ' ' + getSafeAdressCity() + ' ' + getSafeAdressZipCode() + ' ' + getSafeAdressCountry();
  }


  @override
  String toString() {
    return 'Company{id: $id, name: $name, addressNumber: $addressNumber, addressStreet: $addressStreet, addressCity: $addressCity, addressZipCode: $addressZipCode, addressCountry: $addressCountry, phoneNumber: $phoneNumber, email: $email}';
  }

  getSafeAdressNumber() {
    return addressNumber ?? '';
  }

  getSafeAdressStreet() {
    return addressStreet ?? '';
  }

  getSafeAdressCity() {
    return addressCity ?? '';
  }

  getSafeAdressZipCode() {
    return addressZipCode ?? '';
  }

  getSafeAdressCountry() {
    return addressCountry ?? '';
  }

  getSafePhoneNumber() {
    return phoneNumber ?? '';
  }

  String getProfilePicture() {
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      return BackenConnection().url +
          BackenConnection().companyProfilePicFolder +
          (profilePicture as String);
    }
    return "";
  }

}