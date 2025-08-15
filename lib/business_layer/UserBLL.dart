import 'dart:typed_data';

import 'package:file_picker/src/platform_file.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';
import 'package:solid_cv/models/CareerAdvice.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';

class UserBll extends IUserBLL {
  final IUserService _userService = UserService();

  @override
  Future<User> createUser(User user) {
    return _userService.createUser(user);
  }

  @override
  Future<User> getUser(String id) {
    return _userService.getUser(id);
  }

  @override
  Future<void> updateUser(User user,Uint8List? imageBytes, String? imageExt, int id) {
    return _userService.updateUser(user, imageBytes, imageExt, id);
  }

  @override
  Future<User> login(User user) {
    return _userService.login(user);
  }

  @override
  Future<List<User>> searchUsers(SearchTherms searchTherms) {
    if (searchTherms.term == null  || searchTherms.term!.isEmpty) return Future.value([]);

    return _userService.searchUsers(searchTherms);
  }

  @override
  Future<User> getCurrentUser() {
    return _userService.getCurrentUser();
  }

  @override
  addMyCertificateManually(Certificate certificate) {
    _userService.addMyCertificateManually(certificate);
  }

  @override
  Future<List<Certificate>> getMyManuallyAddedCertificates() {
    return _userService.getMyManuallyAddedCertificates();
  }

  @override
  addSkill(String skillName) {
    _userService.addSkill(skillName);
  }

  @override
  Future<List<Skill>> getMySkills() {
    return _userService.getMySkills();
  }

  @override
  Future<Skill> getSkill(String skillId) {
    return _userService.getSkill(skillId);
  }

  @override
  Future<List<Skill>> getSkillsFromUser(String userId) {
    return _userService.getSkillsFromUser(userId);
  }

  @override
  Future<String> getFeedbacksOnProfile(String text, String userId) {
    return _userService.getFeedbacksOnProfile(text, userId);
  }

  @override
  Future<List<User>> getAllUsers() {
    return _userService.getAllUsers();
  }

  @override
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user.roles?.contains('ROLE_ADMIN') ?? false;
  }

  @override
  void addManualExperience(ManualExperience newExperience) {
    _userService.addManualExperience(newExperience);
  }

  @override
  Future<List<ManualExperience>> getMyManuallyAddedExperiences() {
    return _userService.getMyManuallyAddedExperiences();
  }

  @override
  void addManuallyPromotion(Promotion promotion, int experienceId) {
    _userService.addManuallyPromotion(promotion, experienceId);
  }

  @override
  Future<String> getMyExportedCv() {
    return _userService.getMyExportedCv();
  }

  @override
  Future<List<ManualExperience>> getUsersManuallyAddedExperiences(String userId) {
    return _userService.getUsersManuallyAddedExperiences(userId);
  }
  
  @override
  Future<List<Certificate>> getUsersManuallyAddedCertificates(String userId) {
    return _userService.getUsersManuallyAddedCertificates(userId);
  }
  @override
  Future<Map<String, dynamic>> verifyEmail(String token) {
    return _userService.verifyEmail(token);
  }

  @override
  Future<String> resendEmailVerification(String email) {
    return _userService.resendEmailVerification(email);
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _userService.requestPasswordReset(email);
  }

  @override
  Future<void> resetPassword(String token, String newPassword) {
    return _userService.resetPassword(token, newPassword);
  }

  @override
  void deleteManualExperience(int manualExperienceId) {
    return _userService.deleteManualExperience(manualExperienceId);
  }
  
  @override
  void deleteManualyAddedCertificate(int manualExperienceId) {
    return _userService.deleteManualyAddedCertificate(manualExperienceId);
  }

  @override
  Future<String> uploadCV(PlatformFile file) {
    return _userService.uploadCV(file);
  }

  void updateManuallyAddedExperience(ManualExperience updatedExperience) {
    _userService.updateManuallyAddedExperience(updatedExperience);
  }

  void updateManuallyAddedCertificate(Certificate updatedCertificate) {
    _userService.updateManuallyAddedCertificate(updatedCertificate);
  }
  
  @override
  void deleteSkill(int id) {
    _userService.deleteSkill(id);
  }

  Future<int> getMySkillTestQuestionCount() {
    return _userService.getMySkillTestQuestionCount();
  }
  
  @override
  void setFirstConfigurationDone() {
    _userService.setFirstConfigurationDone();
  }
  
  @override
  Future<bool> hasCompletedCV() {
    return _userService.hasCompletedCV();
  }

  @override
  Future<CareerAdvice> getCareerAdvice(CareerAdviceRequest requestData) {
    return _userService.getCareerAdvice(requestData);
  }
  
  
}