import 'dart:convert';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Company.dart';

import 'package:http/http.dart' as http;
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

class CompanyService extends ICompanyService {
  @override
  Future<Company> createCompany(Company company) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().createCompanyApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
          'name': company.name, 
          'addressNumber': company.addressNumber,
          'addressStreet': company.addressStreet,
          'addressCity': company.addressCity,
          'addressZipCode': company.addressZipCode,
          'addressCountry': company.addressCountry,
          'phoneNumber': company.phoneNumber,
          'email': company.email,
        }
      ),
    );

    if(response.statusCode == 200) {
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
      Uri.parse(BackenConnection().url+BackenConnection().getCompanyApi+id.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if(response.statusCode == 200) {
      Company company = Company.fromJson(jsonDecode(response.body));
      return company;
    } else {
      throw Exception('Getting company failure');
    }
  }
  
  @override
  Future<Company> updateCompany(Company company) {
    // TODO: implement updateCompany
    throw UnimplementedError();
  }
  
  @override
  Future<List<Company>> getMyCompanies() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getMyCompaniesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if(response.statusCode == 200) {
      List<dynamic> companies = jsonDecode(response.body);
      return companies.map((company) => Company.fromJson(company)).toList();
    } else {
      throw Exception('Getting companies failure');
    }
  }

  @override
  void addEmployee(User user, ExperienceRecord experienceRecord, int id) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().addEmployeeApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, dynamic>{
          'userId': user.id,
          'experienceRecord': experienceRecord.toJson(),
          'companyId': id,
        }
      ),
    );

    if(response.statusCode != 200) {
      throw Exception('Adding employee failure');
    }
  }
  
  @override
  void saveWalletAddressForCurrentUser(Company company,String ethereumAddress) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().saveCompanyWalletAddressApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
          'address': ethereumAddress,
          'companyId': company.id.toString(),
        }
      ),
    );

    if(response.statusCode != 200) {
      throw Exception('Saving wallet address failure');
    }
  }

  @override
  Future<List<Company>> getAllCompanies() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getAllCompaniesForAdmin),
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
}
