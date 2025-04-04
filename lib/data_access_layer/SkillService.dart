import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/ISkillService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Question.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class SkillService extends ISkillService {
  @override
  Future<Question> getAQuestionsForSkill(int skillId) async {
    var response = await http.get(Uri.parse(BackenConnection().url+BackenConnection().getAQuestionsForSkillApi+skillId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      Question question = Question.fromJson(jsonDecode(response.body));
      return question;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load question');
    }
  }
  
  @override
  void sendAnswerToAI(Question question) async {
    var response = await http.post(Uri.parse(BackenConnection().url+BackenConnection().sendAnswerToAI),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(question.toJson()),
    );

    if (response.statusCode == 200) {
      // Successfully sent answer to AI
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to send answer to AI');
    }
  }
  
  @override
  Future<String> getFeedbacksOnSkills(int skillId) async {
    var response = await http.get(Uri.parse(BackenConnection().url+BackenConnection().getFeedbacksOnSkillsApi+skillId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load feedbacks');
    }
  }

}