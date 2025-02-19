

import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';

abstract class IEducationInstitutionBll {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution);

  Future<EducationInstitution> getEducationInstitution(int id);

  setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress, String privateKey, String password);

  void createCertificate(EducationInstitution educationInstitution, User user, Certificate certificate, String password);
}