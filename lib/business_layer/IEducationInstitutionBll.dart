

import 'dart:typed_data';

import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';

abstract class IEducationInstitutionBll {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt);

  Future<EducationInstitution> getEducationInstitution(int id);

  setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress, String privateKey, String password);

  void createCertificate(EducationInstitution educationInstitution, User user, Certificate certificate, String password);

  Future<List<EducationInstitution>> getAllInstitutions();

  Future<EducationInstitution?> getEducationInstitutionByWallet(String ethereumAddress);

  Future<void> updateEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt, int id);
}
