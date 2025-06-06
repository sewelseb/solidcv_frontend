import 'dart:typed_data';

import 'package:solid_cv/models/EducationInstitution.dart';

abstract class IEducationInstitutionService {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt);

  Future<EducationInstitution> getEducationInstitution(int id);

  void setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress);

  Future<List<EducationInstitution>> getAllInstitutions();

  Future<EducationInstitution?> getEducationInstitutionByWallet(String ethereumAddress);

  Future<void> updateEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt, int id);
}