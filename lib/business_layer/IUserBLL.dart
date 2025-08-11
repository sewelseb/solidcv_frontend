import 'dart:typed_data';

import 'package:file_picker/src/platform_file.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';

abstract class IUserBLL {
  Future<User> getUser(String id);
  Future<User> createUser(User user);
  Future<void> updateUser(User user,Uint8List? imageBytes, String? imageExt, int id);
  Future<User> login(User user);
  Future<String> getMyExportedCv();
  Future<List<User>> searchUsers(SearchTherms searchTherms);

  Future<User> getCurrentUser();

  addMyCertificateManually(Certificate certificate);

  Future<List<Certificate>> getMyManuallyAddedCertificates();

  addSkill(String skillName);

  Future<List<Skill>> getMySkills();

  Future<Skill> getSkill(String skillId);

  Future<List<Skill>> getSkillsFromUser(String userId);

  Future<String> getFeedbacksOnProfile(String text, String userId);

  Future<List<User>> getAllUsers();

  Future<bool> isAdmin();

  void addManualExperience(ManualExperience newExperience);

  Future<List<ManualExperience>> getMyManuallyAddedExperiences();

  void addManuallyPromotion(Promotion promotion, int experienceId);

  Future<List<ManualExperience>> getUsersManuallyAddedExperiences(String userId);

  Future<List<Certificate>> getUsersManuallyAddedCertificates(String userId);

  Future<Map<String, dynamic>> verifyEmail(String token);

  Future<String> resendEmailVerification(String email);

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword(String token, String newPassword);

  void deleteManualExperience(int manualExperienceId);

  void deleteManualyAddedCertificate(int manualExperienceId);

  Future<String> uploadCV(PlatformFile file);

}
