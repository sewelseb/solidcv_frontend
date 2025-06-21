import 'dart:typed_data';

import 'package:solid_cv/models/Company.dart';

abstract class ICompanyService {
  Future<List<Company>> getCompanies();
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company, Uint8List? imageBytes, String? imageExt);
  Future<void> updateCompany(
      Company company, Uint8List? imageBytes, String? imageExt, int id);
  Future<Company> deleteCompany(int id);

  Future<List<Company>> getMyCompanies();

  void saveWalletAddressForCurrentUser(Company company, String ethereumAddress);

  Future<List<Company>> getAllCompanies();

  Future<Company?> fetchCompanyByWallet(String ethereumAddress);
}
