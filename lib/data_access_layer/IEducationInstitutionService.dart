import 'package:solid_cv/models/EducationInstitution.dart';

abstract class IEducationInstitutionService {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution);

  Future<EducationInstitution> getEducationInstitution(int id);

  void setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress);

}