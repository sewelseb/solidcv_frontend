import 'package:solid_cv/models/ExperienceRecord.dart';

abstract class IBlockchainWalletBll {
  Future<bool> saveWalletAddressForCurrentUser(String address);

  Future<String> createWorkExperienceToken(ExperienceRecord experienceRecord, int companyId, int userId, String password);

}