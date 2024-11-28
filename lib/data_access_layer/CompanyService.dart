import 'dart:convert';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Company.dart';

import 'package:http/http.dart' as http;

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
  Future<Company> getCompany(int id) {
    // TODO: implement getCompany
    throw UnimplementedError();
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
}
