import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';
import 'package:web3dart/web3dart.dart';

abstract class IBlockchainWalletBll {
  Future<bool> saveWalletAddressForCurrentUser(String address);

  createCertificateToken(Certificate certificate, User user, EducationInstitution educationInstitution, String password);

  Future<List<Certificate>> getCertificatesForCurrentUser();

  Future<Wallet> createANewWalletAddressForCurrentUser(String password);

  Future<List<Certificate>> getCertificates(String ethereumAddress);

  Future<String> createWorkEventToken(WorkEvent event, int companyId, int userId, String password);

  Future<List<CleanExperience>> getEventsForCurrentUser();

  Future<WorkEvent> getExperienceEventsFromIpfs(dynamic nft);
  
Future<List<CleanExperience>> getEventsForUser(String ethereumAddress);
}