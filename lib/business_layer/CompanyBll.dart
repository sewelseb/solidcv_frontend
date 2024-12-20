import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/data_access_layer/CompanyService.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/models/Company.dart';

class CompanyBll extends ICompanyBll {
  final ICompanyService _companyService = CompanyService();

  @override
  Future<Company> createCompany(Company company) {
    return _companyService.createCompany(company);
  }

  @override
  Future<Company> deleteCompany(int id) {
    // TODO: implement deleteCompany
    throw UnimplementedError();
  }

  @override
  Future<List<Company>> getCompanies() {
    // TODO: implement getCompanies
    throw UnimplementedError();
  }

  @override
  Future<Company> getCompany(int id) {
    // TODO: implement getCompany
    throw UnimplementedError();
  }

  @override
  Future<Company> updateCompany(Company company) {
    // TODO: implement updateCompany
    throw UnimplementedError();
  }
  
  @override
  Future<List<Company>> getMyCompanies() {
    return _companyService.getMyCompanies();
  }

  
}