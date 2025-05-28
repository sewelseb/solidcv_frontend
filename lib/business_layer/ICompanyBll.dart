import 'package:image_picker/image_picker.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

abstract class ICompanyBll {
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company, XFile? image);
  Future<void> updateCompany(Company company, XFile? image, int id);
  Future<Company> deleteCompany(int id);

  Future<List<Company>> getMyCompanies();

  addEmployee(User user, ExperienceRecord experienceRecord, int id, String password);

  setEthereumAddress(Company company, String ethereumAddress, String privateKey, String password);

  Future<List<Company>> getAllCompanies();

  addEmployeeEvents(User user,WorkEvent event,int companyId,String password);
}