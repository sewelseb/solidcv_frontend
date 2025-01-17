import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';

class UserBll extends IUserBLL {
  final IUserService _userService = UserService();


  @override
  Future<User> createUser(User user) {
    return _userService.createUser(user);
  }

  @override
  Future<User> getUser(String id) {
    // TODO: implement getUser
    throw UnimplementedError();
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

}