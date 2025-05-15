import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
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
  Future<User> updateUser(User user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<User> login(User user) {
    return _userService.login(user);
  }

  @override
  Future<List<User>> searchUsers(SearchTherms searchTherms) {
    return _userService.searchUsers(searchTherms);
  }

  @override
  Future<User> getCurrentUser() {
    return _userService.getCurrentUser();
  }

  @override
  void addManuallyAddedWorkExperience(ExperienceRecord newExperience) {
    _userService.addManuallyAddedWorkExperience(newExperience);
  }

  @override
  Future<List<ExperienceRecord>> getMyManuallyAddedWorkExperiences() {
    return _userService.getMyManuallyAddedWorkExperiences();
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
}
