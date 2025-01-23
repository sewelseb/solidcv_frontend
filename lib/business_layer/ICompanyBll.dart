import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

abstract class ICompanyBll {
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company);
  Future<Company> updateCompany(Company company);
  Future<Company> deleteCompany(int id);

  Future<List<Company>> getMyCompanies();

  addEmployee(User user, ExperienceRecord experienceRecord, int id, String password);

  setEthereumAddress(Company company, String ethereumAddress, String privateKey, String password);
}