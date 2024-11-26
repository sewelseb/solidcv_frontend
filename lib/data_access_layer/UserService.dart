import 'dart:convert';
import 'dart:async';


import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/models/User.dart';
import 'package:http/http.dart' as http;

class UserService extends IUserService {
  @override
  Future<User> createUser(User user) async {
    if(user.email == null || user.password == null) throw Exception('email and password can\'t be null');

    final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().registerApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
          'email': user.email, 
          'password': user.password,
        }
      ),
    );

    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Registering failure');
    }
  }

   @override
  Future<User> login(User user) async {
    if(user.email == null || user.password == null) throw Exception('email and password can\'t be null');

     final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().loginApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
          'email': user.email, 
          'password': user.password
        }
      ),
    );

    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response);
      throw Exception('Login failure');
      
    }
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

}