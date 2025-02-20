import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';
import 'package:web3dart/web3dart.dart';

abstract class IBlockchainWalletBll {
  Future<bool> saveWalletAddressForCurrentUser(String address);

  Future<String> createWorkExperienceToken(ExperienceRecord experienceRecord, int companyId, int userId, String password);

  Future<List<ExperienceRecord>> getWorkExperiencesForCurrentUser();

  createCertificateToken(Certificate certificate, User user, EducationInstitution educationInstitution, String password);

  Future<List<Certificate>> getCertificatesForCurrentUser();

  Future<Wallet> createANewWalletAddressForCurrentUser(String password);

}