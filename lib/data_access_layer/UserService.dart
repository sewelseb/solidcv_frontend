import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';
import 'package:http/http.dart' as http;

class UserService extends IUserService {
  @override
  Future<User> createUser(User user) async {
    if (user.email == null || user.password == null)
      throw Exception('email and password can\'t be null');

    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().registerApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'email': user.email,
        'password': user.password,
      }),
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
    if (user.email == null || user.password == null)
      throw Exception('email and password can\'t be null');

    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().loginApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String?>{'email': user.email, 'password': user.password}),
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
      Uri.parse(BackenConnection().url + BackenConnection().getUserApi + id),
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
  Future<List<User>> searchUsers(SearchTherms searchTherms) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().searchUsersApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{'searchTherms': searchTherms.term}),
    );

    if (response.statusCode == 200) {
      List<User> users = (jsonDecode(response.body) as List)
          .map((i) => User.fromJson(i))
          .toList();
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
      Uri.parse(
          BackenConnection().url + BackenConnection().saveWalletAddressApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{'address': address}),
    );

    if (response.statusCode != 200) {
      throw Exception('Saving wallet address failure');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getCurrentUserApi),
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
    var response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().addManuallyAddedWorkExperienceApi),
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
  void addManualExperience(ManualExperience newExperience) async {
    var response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().addManuallyAddedWorkExperienceApi),
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
  void addManuallyPromotion(Promotion promotion, int experienceId) async {
    var response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().addManuallyPromotion +
          experienceId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'newTitle': promotion.newTitle,
        'date': promotion.date,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Adding manually added work experience failure');
    }
  }

  @override
  Future<List<ExperienceRecord>> getMyManuallyAddedWorkExperiences() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getMyManuallyAddedWorkExperiencesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<ExperienceRecord> experiences = (jsonDecode(response.body) as List)
          .map((i) => ExperienceRecord.fromJson(i))
          .toList();
      return experiences;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting manually added work experiences failure');
    }
  }

  @override
  Future<List<ManualExperience>> getMyManuallyAddedExperiences() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getMyManuallyAddedWorkExperiencesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<ManualExperience> experiences = (jsonDecode(response.body) as List)
          .map((i) => ManualExperience.fromJson(i))
          .toList();
      return experiences;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting manually added work experiences failure');
    }
  }

  @override
  void addMyCertificateManually(Certificate certificate) async {
    var response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().addMyCertificateManuallyApi),
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
      Uri.parse(BackenConnection().url +
          BackenConnection().getMyManuallyAddedCertificatesApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<Certificate> certificates = (jsonDecode(response.body) as List)
          .map((i) => Certificate.fromJson(i))
          .toList();
      return certificates;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting manually added certificates failure');
    }
  }

  @override
  void addSkill(String skillName) async {
    var response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().addSkillApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, String?>{'name': skillName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Adding skill failure');
    }
  }

  @override
  Future<List<Skill>> getMySkills() async {
    var response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getMySkillsApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<Skill> skills = (jsonDecode(response.body) as List)
          .map((i) => Skill.fromJson(i))
          .toList();
      return skills;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting skills failure');
    }
  }

  @override
  Future<Skill> getSkill(String skillId) async {
    var response = await http.get(
      Uri.parse(
          BackenConnection().url + BackenConnection().getSkillApi + skillId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      Skill skill = Skill.fromJson(jsonDecode(response.body));
      return skill;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting skill failure');
    }
  }

  @override
  Future<List<Skill>> getSkillsFromUser(String userId) async {
    var response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getSkillsFromUserApi +
          userId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<Skill> skills = (jsonDecode(response.body) as List)
          .map((i) => Skill.fromJson(i))
          .toList();
      return skills;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting skills from user failure');
    }
  }

  @override
  Future<String> getFeedbacksOnProfile(String text, String userId) async {
    var response = await http.post(
      Uri.parse(
          BackenConnection().url + BackenConnection().getFeedbacksOnProfileApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(
          <String, String?>{'jobDescription': text, 'userId': userId}),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Getting feedbacks on profile failure');
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    var response = await http.get(
      Uri.parse(
          BackenConnection().url + BackenConnection().getAllUsersForAdmin),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  @override
  Future<String> getMyExportedCv() async {
    final response = await http.get(
        Uri.parse(BackenConnection().url + BackenConnection().getMyExportedCv),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Auth-Token': await APIConnectionHelper.getJwtToken()
        });

    if (response.statusCode == 200) {
      var myCv = jsonDecode(response.body)["cv"];
      return myCv;
    } else {
      print(response.body);
      throw Exception('Failure in getting cv');
    }
  }

  @override
  Future<void> updateUser(
      User user, Uint8List? imageBytes, String? imageExt, int id) async {
    String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

    final response = await http.post(
      Uri.parse(BackenConnection().url +
          BackenConnection().updateUser +
          id.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'phoneNumber': user.phoneNumber,
        'biography': user.biography,
        'linkedin': user.linkedin,
        if (imageBase64 != null) 'profilePicture': imageBase64,
        if (imageBase64 != null) 'profilePictureExtention': imageExt,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error updating user information');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await http.get(
      Uri.parse(
          BackenConnection().url + BackenConnection().verifyEmail + token),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Error verifying email');
    }
  }
}
