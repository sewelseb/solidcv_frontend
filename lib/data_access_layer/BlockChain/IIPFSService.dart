import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSWorkExperience.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';

abstract class IIPFSService {
  Future<String> saveWorkExperience(ExperienceRecord experienceRecord, Company company);

  Future<IPFSWorkExperience> getWorkExperience(String ipfsHash);
}