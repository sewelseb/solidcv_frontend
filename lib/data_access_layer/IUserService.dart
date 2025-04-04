import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';

abstract class IUserService {
  Future<User> getUser(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);

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
}