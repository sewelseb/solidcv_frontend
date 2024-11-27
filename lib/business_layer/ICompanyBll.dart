import 'package:solid_cv/models/Company.dart';

abstract class ICompanyBll {
  Future<List<Company>> getCompanies();
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company);
  Future<Company> updateCompany(Company company);
  Future<Company> deleteCompany(int id);
}