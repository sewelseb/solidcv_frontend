import 'package:image_picker/image_picker.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

abstract class IEducationInstitutionService {
  Future<List<EducationInstitution>> getMyEducationInstitutions();

  void addEducationInstitution(EducationInstitution educationInstitution, XFile? image);

  Future<EducationInstitution> getEducationInstitution(int id);

  void setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress);

  Future<List<EducationInstitution>> getAllInstitutions();

}