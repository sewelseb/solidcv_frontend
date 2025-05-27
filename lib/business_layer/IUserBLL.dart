import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';

abstract class IUserBLL {
  Future<User> getUser(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);

  Future<User>  login(User user);

  Future<List<User>> searchUsers(SearchTherms searchTherms);

  Future<User> getCurrentUser();

  void addManuallyAddedWorkExperience(ExperienceRecord newExperience);

  Future<List<ExperienceRecord>> getMyManuallyAddedWorkExperiences();

  addMyCertificateManually(Certificate certificate);

  Future<List<Certificate>> getMyManuallyAddedCertificates();

  addSkill(String skillName);

  Future<List<Skill>> getMySkills();

  Future<Skill> getSkill(String skillId);

  Future<List<Skill>> getSkillsFromUser(String userId);

  Future<String> getFeedbacksOnProfile(String text, String userId);

  void addManualExperience(ManualExperience newExperience);

  Future<List<ManualExperience>> getMyManuallyAddedExperiences();

  
  void addManuallyPromotion(Promotion promotion, int experienceId);
}