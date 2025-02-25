import 'dart:convert';
import 'dart:async';


import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/SearchTherms.dart';
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
  Future<User> getUser(String id) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getUserApi+id),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting user failure');
    }
  }

  @override
  Future<User> updateUser(User user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<List<User>> searchUsers(SearchTherms searchTherms) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().searchUsersApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
          'searchTherms': searchTherms.term
        }
      ),
    );

    if (response.statusCode == 200) {
      List<User> users = (jsonDecode(response.body) as List).map((i) => User.fromJson(i)).toList();
      return users;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Search failure');
    }
  }
  
  @override
  void saveWalletAddressForCurrentUser(String address) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url+BackenConnection().saveWalletAddressApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{
          'address': address
        }
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Saving wallet address failure');
    }
  }
  
  @override
  Future<User> getCurrentUser() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getCurrentUserApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting current user failure');
    }
  }

  @override
  void addManuallyAddedWorkExperience(ExperienceRecord newExperience) async {
    var response = await http.post(Uri.parse(BackenConnection().url+BackenConnection().addManuallyAddedWorkExperienceApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(newExperience.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Adding manually added work experience failure');
    }
  }
  
  @override
  Future<List<ExperienceRecord>> getMyManuallyAddedWorkExperiences() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getMyManuallyAddedWorkExperiencesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<ExperienceRecord> experiences = (jsonDecode(response.body) as List).map((i) => ExperienceRecord.fromJson(i)).toList();
      return experiences;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting manually added work experiences failure');
    }
  }

  @override
  void addMyCertificateManually(Certificate certificate) async {
    var response = await http.post(Uri.parse(BackenConnection().url+BackenConnection().addMyCertificateManuallyApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(certificate.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Adding manually added certificate failure');
    }
  }
  
  @override
  Future<List<Certificate>> getMyManuallyAddedCertificates() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getMyManuallyAddedCertificatesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<Certificate> certificates = (jsonDecode(response.body) as List).map((i) => Certificate.fromJson(i)).toList();
      return certificates;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting manually added certificates failure');
    }
  }

}