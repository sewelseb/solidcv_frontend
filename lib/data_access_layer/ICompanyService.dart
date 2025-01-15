import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

abstract class ICompanyService {
  Future<List<Company>> getCompanies();
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company);
  Future<Company> updateCompany(Company company);
  Future<Company> deleteCompany(int id);

  Future<List<Company>> getMyCompanies();

  void addEmployee(User user, ExperienceRecord experienceRecord, int id);
}