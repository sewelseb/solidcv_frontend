import 'dart:typed_data';

import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';

abstract class IEducationInstitutionService {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt);

  Future<EducationInstitution> getEducationInstitution(int id);

  void setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress);

  Future<List<EducationInstitution>> getAllInstitutions();

  Future<EducationInstitution?> getEducationInstitutionByWallet(String ethereumAddress);

  Future<void> updateEducationInstitution(EducationInstitution educationInstitution, Uint8List? imageBytes, String? imageExt, int id);
  
  Future<bool> verifyEducationInstitution(int institutionId);
  
  Future<bool> unverifyEducationInstitution(int institutionId);

  Future<List<User>> getEducationInstitutionAdministrators(int educationInstitutionId);

  Future<void> addEducationInstitutionAdministrator(int educationInstitutionId, int userId);

  Future<void> removeEducationInstitutionAdministrator(int educationInstitutionId, int userId);
}