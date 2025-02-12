import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/data_access_layer/EducationInstitutionService.dart';
import 'package:solid_cv/data_access_layer/IEducationInstitutionService.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class EducationInstitutionBll extends IEducationInstitutionBll {
  final IEducationInstitutionService _educationInstitutionService = EducationInstitutionService();

  @override
  Future<List<EducationInstitution>> getMyEducationInstitutions() {
    return _educationInstitutionService.getMyEducationInstitutions();
  }
  
  @override
  void addEducationInstitution(EducationInstitution educationInstitution) {
    _educationInstitutionService.addEducationInstitution(educationInstitution);
  }
  
  @override
  Future<EducationInstitution> getEducationInstitution(int id) {
    return _educationInstitutionService.getEducationInstitution(id);
  }

  

}