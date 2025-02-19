class EducationInstitution {
  final int? id;
  final String? name;
  final String? addressNumber;
  final String? addressStreet;
  final String? addressCity;
  final String? addressZipCode;
  final String? addressCountry;
  final String? phoneNumber;
  final String? email;
  String? ethereumAddress;

  EducationInstitution({
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
  });

  factory EducationInstitution.fromJson(Map<String, dynamic> json) {
    return EducationInstitution(
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
}