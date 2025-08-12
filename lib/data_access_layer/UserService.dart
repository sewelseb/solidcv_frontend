import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:file_picker/src/platform_file.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/Skill.dart';
import 'package:solid_cv/models/User.dart';
import 'package:http/http.dart' as http;

class UserService extends IUserService {
  @override
  Future<User> createUser(User user) async {
    if (user.email == null || user.password == null) {
      throw Exception('email and password can\'t be null');
    }

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
    if (user.email == null || user.password == null) {
      throw Exception('email and password can\'t be null');
    }

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
      final data = jsonDecode(response.body);
      throw Exception(data['message']);
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
  Future<List<ManualExperience>> getUsersManuallyAddedExperiences(String userId) async {
    var response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getUsersManuallyAddedExperiences+ userId),
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
      throw Exception('Getting manually added work experiences for a user failure');
    }
  }

  @override
  void deleteManualExperience(int manualExperienceId) async{
    final response = await http.delete(
      Uri.parse(BackenConnection().url +
          BackenConnection().deleteManualExperience + manualExperienceId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Deleting manually added work experience failure');
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
  void deleteManualyAddedCertificate(int manualExperienceId) async {
    final response = await http.delete(
      Uri.parse(BackenConnection().url +
          BackenConnection().deleteManualyAddedCertificate + manualExperienceId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Deleting manually added certificate failure');
    }
  }

    @override
  Future<List<Certificate>> getUsersManuallyAddedCertificates(String userId) async {
    var response = await http.get(
      Uri.parse(BackenConnection().url +
          BackenConnection().getUsersManuallyAddedCertificates + userId),
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
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        "success": true,
        "message": data['message'] ?? "Your email has been verified!",
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": data['error'] ?? 'Error verifying email',
      };
    }
  }

  @override
  Future<String> resendEmailVerification(String email) async {
    final response = await http.post(
      Uri.parse(
          BackenConnection().url + BackenConnection().resendEmailVerification),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse(
          BackenConnection().url + BackenConnection().requestPasswordReset),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ??
          'Failed to request password reset');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'password': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Failed to reset password');
    }
  }

  @override
  Future<String> uploadCV(PlatformFile file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(BackenConnection().url + BackenConnection().uploadCvApi),
    );
    request.headers['X-Auth-Token'] = await APIConnectionHelper.getJwtToken();
    
    // Handle both bytes and path cases
    if (file.bytes != null) {
      // Web platform - use bytes
      request.files.add(http.MultipartFile.fromBytes(
        'cv',
        file.bytes!,
        filename: file.name,
      ));
    } else if (file.path != null) {
      // Mobile/Desktop platform - use path
      request.files.add(await http.MultipartFile.fromPath(
        'cv',
        file.path!,
        filename: file.name,
      ));
    } else {
      throw Exception('No file data available');
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      // Parse the response to get the actual file path/URL from server
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      
      // Return the server's response (could be file path, URL, or success message)
      return jsonResponse['filePath'] ?? jsonResponse['message'] ?? 'CV uploaded successfully';
    } else {
      final responseData = await response.stream.bytesToString();
      final errorMessage = jsonDecode(responseData)['error'] ?? 'Failed to upload CV';
      throw Exception(errorMessage);
    }
  }
  
  @override
  void updateManuallyAddedExperience(ManualExperience updatedExperience) async {
    final response = await http.put(
      Uri.parse(BackenConnection().url + BackenConnection().updateExperienceApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(updatedExperience.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update experience');
    }
  }
  
  @override
  void updateManuallyAddedCertificate(Certificate updatedCertificate) async {
    final response = await http.put(
      Uri.parse(BackenConnection().url + BackenConnection().updateCertificateApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(updatedCertificate.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update certificate');
    }
  }
  
  @override
  void deleteSkill(int id) async {
    final response = await http.delete(
      Uri.parse('${BackenConnection().url}${BackenConnection().deleteSkillApi}$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to delete skill');
    }
  }

}
