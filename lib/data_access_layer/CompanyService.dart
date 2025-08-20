import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:http/http.dart' as http;
import 'package:solid_cv/models/User.dart';

class CompanyService extends ICompanyService {
@override
Future<Company> createCompany(Company company, Uint8List? imageBytes, String? imageExt) async {
  String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

  final response = await http.post(
    Uri.parse(BackenConnection().url + BackenConnection().createCompanyApi),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
    },
    body: jsonEncode({
      'name': company.name,
      'addressNumber': company.addressNumber,
      'addressStreet': company.addressStreet,
      'addressCity': company.addressCity,
      'addressZipCode': company.addressZipCode,
      'addressCountry': company.addressCountry,
      'phoneNumber': company.phoneNumber,
      'email': company.email,
      if (imageBase64 != null) 'profilePicture': imageBase64,
      if (imageBase64 != null) 'profilePictureExtention': imageExt,
    }),
  );

  if (response.statusCode == 200) {
    Company company = Company.fromJson(jsonDecode(response.body));
    return company;
  } else {
    throw Exception('Creating company failure');
  }
}

  @override
  Future<Company> deleteCompany(int id) {
    // TODO: implement deleteCompany
    throw UnimplementedError();
  }

  @override
  Future<List<Company>> getCompanies() {
    // TODO: implement getCompanies
    throw UnimplementedError();
  }

  @override
  Future<Company> getCompany(int id) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getCompanyApi +
          id.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Company company = Company.fromJson(jsonDecode(response.body));
      return company;
    } else {
      throw Exception('Getting company failure');
    }
  }

  @override
  Future<void> updateCompany(Company company,Uint8List? imageBytes,String? imageExt,int id) async {
    String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().updateCompany +
          id.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'name': company.name,
        'addressNumber': company.addressNumber,
        'addressStreet': company.addressStreet,
        'addressCity': company.addressCity,
        'addressZipCode': company.addressZipCode,
        'addressCountry': company.addressCountry,
        'phoneNumber': company.phoneNumber,
        'email': company.email,
        if (imageBase64 != null) 'profilePicture': imageBase64,
        if (imageBase64 != null) 'profilePictureExtention': imageExt,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error updating company information');
    }
  }

  @override
  Future<List<Company>> getMyCompanies() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getMyCompaniesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> companies = jsonDecode(response.body);
      return companies.map((company) => Company.fromJson(company)).toList();
    } else {
      throw Exception('Getting companies failure');
    }
  }

  @override
  void saveWalletAddressForCurrentUser(
      Company company, String ethereumAddress) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().saveCompanyWalletAddressApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
        'address': ethereumAddress,
        'companyId': company.id.toString(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Saving wallet address failure');
    }
  }

  @override
  Future<List<Company>> getAllCompanies() async {
    final response = await http.get(
      Uri.parse(
          BackenConnection().url + BackenConnection().getAllCompaniesForAdmin),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch companies');
    }
  }

  @override
  Future<Company?> fetchCompanyByWallet(String ethereumAddress) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getCompanyByEthereumAddress +
          ethereumAddress),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Company.fromJson(data);
    }
    return null;
  }

  @override
  Future<List<User>> getCompanyAdministrators(int companyId) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getCompanyAdministratorsApi +
          companyId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      return [];
    }
  }
  
  @override
  addCompanyAdministrator(int companyId, int userId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().addCompanyAdministratorApi),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'companyId': companyId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to add company administrator');
    }
  }
  
  @override
  removeCompanyAdministrator(int companyId, int userId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().removeCompanyAdministratorApi),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'companyId': companyId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to remove company administrator');
    }
  }
  
  @override
  Future<bool> verifyCompany(int companyId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().verifyCompanyApi),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'companyId': companyId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to verify company');
    }
  }
  
  @override
  Future<bool> unverifyCompany(int companyId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().unverifyCompanyApi),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'companyId': companyId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to unverify company');
    }
  }

}
