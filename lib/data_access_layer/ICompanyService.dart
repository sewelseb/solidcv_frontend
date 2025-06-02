import 'package:image_picker/image_picker.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

abstract class ICompanyService {
  Future<List<Company>> getCompanies();
  Future<Company> getCompany(int id);
  Future<Company> createCompany(Company company, XFile? image);
  Future<void> updateCompany(Company company, XFile? image, int id);
  Future<Company> deleteCompany(int id);

  Future<List<Company>> getMyCompanies();

  void addEmployee(User user, ExperienceRecord experienceRecord, int id);

  void saveWalletAddressForCurrentUser(Company company, String ethereumAddress);

  Future<List<Company>> getAllCompanies();

  Future<Company?> fetchCompanyByWallet(String ethereumAddress);
}