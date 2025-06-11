import 'dart:typed_data';

import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';

abstract class IUserService {
  Future<User> getUser(String id);
  Future<User> createUser(User user);
  Future<String> getMyExportedCv();
  Future<User> login(User user);

  Future<List<User>> searchUsers(SearchTherms searchTherms);

  void saveWalletAddressForCurrentUser(String address);

  Future<User> getCurrentUser();

  void addManuallyAddedWorkExperience(ExperienceRecord newExperience);

  Future<List<ExperienceRecord>> getMyManuallyAddedWorkExperiences();

  void addMyCertificateManually(Certificate certificate);

  Future<List<Certificate>> getMyManuallyAddedCertificates();

  void addSkill(String skillName);

  Future<List<Skill>> getMySkills();

  Future<Skill> getSkill(String skillId);

  Future<List<Skill>> getSkillsFromUser(String userId);

  Future<String> getFeedbacksOnProfile(String text, String userId);

  Future<List<User>> getAllUsers();

  void addManuallyPromotion(Promotion promotion, int experienceId);

  void addManualExperience(ManualExperience newExperience);

  Future<List<ManualExperience>> getMyManuallyAddedExperiences();

  Future<void> updateUser(User user,Uint8List? imageBytes, String? imageExt, int id);

  Future<Map<String, dynamic>> verifyEmail(String token);

}