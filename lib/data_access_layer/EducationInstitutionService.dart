import 'dart:convert';
import 'dart:typed_data';

import 'package:solid_cv/data_access_layer/IEducationInstitutionService.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/BulkCertificateData.dart';

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
void addEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt) async {
  String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

  final response = await http.post(
    Uri.parse(BackenConnection().url +
        BackenConnection().addEducationInstitutionApi),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
    },
    body: jsonEncode({
      'name': educationInstitution.name,
      'addressNumber': educationInstitution.addressNumber,
      'addressStreet': educationInstitution.addressStreet,
      'addressCity': educationInstitution.addressCity,
      'addressZipCode': educationInstitution.addressZipCode,
      'addressCountry': educationInstitution.addressCountry,
      'phoneNumber': educationInstitution.phoneNumber,
      'email': educationInstitution.email,
      if (imageBase64 != null) 'profilePicture': imageBase64,
      if (imageBase64 != null) 'profilePictureExtention': imageExt,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Adding institution failure');
  }
}

  @override
  Future<EducationInstitution> getEducationInstitution(int id) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getEducationInstitutionApi +
          id.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return EducationInstitution.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Getting company failure');
    }
  }

  @override
  void setEthereumAddress(
      EducationInstitution educationInstitution, String ethereumAddress) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().setEthereumAddressForTeachingInstitutionApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
        'id': educationInstitution.id.toString(),
        'ethereumAddress': ethereumAddress,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Setting Base Blochchain address failure');
    }
  }

  @override
  Future<List<EducationInstitution>> getAllInstitutions() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getAllEducationInstitutionsForAdmin),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded
          .map((json) => EducationInstitution.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch institutions');
    }
  }

  @override
  Future<EducationInstitution?> getEducationInstitutionByWallet(
      String ethereumAddress) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getEducationInstitutionByEthereumAddress +
          ethereumAddress),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return EducationInstitution.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> updateEducationInstitution(
      EducationInstitution educationInstitution,
      Uint8List? imageBytes,
      String? imageExt,
      int id) async {
    String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().updateEducationInstitution +
          id.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'name': educationInstitution.name,
        'addressNumber': educationInstitution.addressNumber,
        'addressStreet': educationInstitution.addressStreet,
        'addressCity': educationInstitution.addressCity,
        'addressZipCode': educationInstitution.addressZipCode,
        'addressCountry': educationInstitution.addressCountry,
        'phoneNumber': educationInstitution.phoneNumber,
        'email': educationInstitution.email,
        if (imageBase64 != null) 'profilePicture': imageBase64,
        if (imageBase64 != null) 'profilePictureExtention': imageExt,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error updating education institution informations');
    }
  }
  
  @override
  Future<bool> verifyEducationInstitution(int institutionId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().verifyEducationInstitutionApi),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'institutionId': institutionId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to verify education institution');
    }
  }
  
  @override
  Future<bool> unverifyEducationInstitution(int institutionId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().unverifyEducationInstitutionApi),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'institutionId': institutionId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to unverify education institution');
    }
  }
  
  @override
  Future<BulkCertificateResponse> createBulkCertificates(int institutionId, List<BulkCertificateData> certificates) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url + '/api/institutions/$institutionId/bulk-certificates'),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'institutionId': institutionId,
        'certificates': certificates.map((cert) => cert.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return BulkCertificateResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to create bulk certificates: ${response.body}');
    }
  }
}
