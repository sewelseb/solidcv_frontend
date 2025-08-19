import 'dart:typed_data';

import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/User.dart';

abstract class ICompanyBll {
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company, Uint8List? imageBytes, String? imageExt);
  Future<void> updateCompany(Company company, Uint8List? imageBytes, String? imageExt, int id);
  Future<Company> deleteCompany(int id);

  Future<List<Company>> getMyCompanies();

  setEthereumAddress(Company company, String ethereumAddress, String privateKey, String password);

  Future<List<Company>> getAllCompanies();

  addEmployeeEvents(User user,WorkEvent event,int companyId,String password);

  Future<Company?> fetchCompanyByWallet(String ethereumAddress);

  Future<List<User>> getCompanyAdministrators(int companyId);

  addCompanyAdministrator(int companyId, int userId);

  removeCompanyAdministrator(int companyId, int userId);
  
  Future<bool> verifyCompany(int companyId);
  
  Future<bool> unverifyCompany(int companyId);
}