import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/SearchTherms.dart';
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
}