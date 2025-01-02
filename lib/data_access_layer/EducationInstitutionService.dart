import 'dart:convert';

import 'package:solid_cv/data_access_layer/IEducationInstitutionService.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';

import 'package:http/http.dart' as http;

class EducationInstitutionService extends IEducationInstitutionService {
  @override
  Future<List<EducationInstitution>> getMyEducationInstitutions() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getMyEducationInstitutionsApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> companies = jsonDecode(response.body);
      return companies
          .map((company) => EducationInstitution.fromJson(company))
          .toList();
    } else {
      throw Exception('Getting companies failure');
    }
  }
  
  @override
  void addEducationInstitution(EducationInstitution educationInstitution) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().addEducationInstitutionApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
        'name': educationInstitution.name,
        'addressNumber': educationInstitution.addressNumber,
        'addressStreet': educationInstitution.addressStreet,
        'addressCity': educationInstitution.addressCity,
        'addressZipCode': educationInstitution.addressZipCode,
        'addressCountry': educationInstitution.addressCountry,
        'phoneNumber': educationInstitution.phoneNumber,
        'email': educationInstitution.email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Adding company failure');
    }
  }
}
