import 'dart:convert';

import 'package:image_picker/image_picker.dart';
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
  void addEducationInstitution(
      EducationInstitution educationInstitution, XFile? image) async {
    String? imageBytesBaseimage;
    if (image != null) {
      List<int> imageBytes = await image.readAsBytes();
      imageBytesBaseimage = base64Encode(imageBytes);
    }

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
        'profilePicture': imageBytesBaseimage,
        'profilePictureExtention': _getFileExtention(image),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Adding company failure');
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
      throw Exception('Setting ethereum address failure');
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
      EducationInstitution educationInstitution, XFile? image, int id) async {
    {
      String? imageBytesBaseimage;
      if (image != null) {
        List<int> imageBytes = await image.readAsBytes();
        imageBytesBaseimage = base64Encode(imageBytes);
      }

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
          'profilePicture': imageBytesBaseimage,
          'profilePictureExtention': _getFileExtention(image),
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Error updating education institution informations');
      }
    }
  }

  _getFileExtention(XFile? file) {
    if (file == null) return "";

    var stringArray = file.name.split(".");

    return stringArray.last;
  }
}
