import 'package:solid_cv/models/User.dart';

abstract class IUserService {
  Future<User> getUser(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);

  Future<User> login(User user);
}