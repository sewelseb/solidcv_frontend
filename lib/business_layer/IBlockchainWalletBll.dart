import 'package:solid_cv/models/ExperienceRecord.dart';

abstract class IBlockchainWalletBll {
  Future<bool> saveWalletAddressForCurrentUser(String address);

  Future<bool> createWorkExperienceToken(ExperienceRecord experienceRecord, int companyId, int userId, String password);

}