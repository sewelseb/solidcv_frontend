

import 'package:solid_cv/models/EducationInstitution.dart';

abstract class IEducationInstitutionBll {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution);

  Future<EducationInstitution> getEducationInstitution(int id);
}