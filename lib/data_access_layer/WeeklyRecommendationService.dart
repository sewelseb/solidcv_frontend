import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/IWeeklyRecommendationService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/WeeklyRecommendation.dart';
import 'package:solid_cv/models/CourseQuestion.dart';
import 'package:solid_cv/models/QuizSubmission.dart';

class WeeklyRecommendationService extends IWeeklyRecommendationService {
  @override
  Future<WeeklyRecommendation> getCurrentWeekRecommendations() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getCurrentWeekRecommendationsApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return WeeklyRecommendation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load current week recommendations');
    }
  }

  @override
  Future<WeeklyProgress> getWeeklyProgress() async {
    final response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getWeeklyProgressApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return WeeklyProgress.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weekly progress');
    }
  }

  @override
  Future<bool> markCourseAsCompleted(int courseId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().markCourseCompletedApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, int>{
        'courseId': courseId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 409) {
      // Course already completed
      return true;
    } else {
  throw Exception('Failed to mark course as completed');
    }
  }

  @override
  Future<bool> registerForEvent(int eventId) async {
    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().registerForEventApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(<String, int>{
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 409) {
      // Already registered for event
      return true;
    } else {
      throw Exception('Failed to register for event');
    }
  }

  @override
  Future<bool> unregisterFromEvent(int eventId) async {
    final response = await http.delete(
      Uri.parse(BackenConnection().url + BackenConnection().unregisterFromEventApi + eventId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to unregister from event');
    }
  }

  @override
  Future<List<WeeklyRecommendation>> getRecommendationHistory({int? limit}) async {
    String url = BackenConnection().url + BackenConnection().getRecommendationHistoryApi;
    if (limit != null) {
      url += '?limit=$limit';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((recommendation) => WeeklyRecommendation.fromJson(recommendation)).toList();
    } else {
      throw Exception('Failed to load recommendation history');
    }
  }

  @override
  Future<WeeklyRecommendation> getRecommendationsForWeek(String weekStartDate) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getRecommendationsForWeekApi + weekStartDate),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return WeeklyRecommendation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load recommendations for week');
    }
  }

  @override
  Future<RecommendedCourse> getAiGeneratedCourse(int courseId) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getAiGeneratedCourseApi + courseId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200) {
      return RecommendedCourse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load AI-generated course content');
    }
  }

  @override
  Future<List<CourseQuestion>> getCourseQuestions(int courseId) async {
    final response = await http.get(
      Uri.parse(BackenConnection().url + BackenConnection().getCourseQuestionsApi + courseId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CourseQuestion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load course questions');
    }
  }
  
  @override
  Future<QuizResult> submitCourseQuiz(int courseId, Map<int, int> answers) async {
    // Convert answers map to list of QuizAnswer objects
    List<QuizAnswer> answersList = answers.entries
        .map((entry) => QuizAnswer(
              questionId: entry.key,
              selectedOptionId: entry.value,
            ))
        .toList();

    QuizSubmission submission = QuizSubmission(
      courseId: courseId,
      answers: answersList,
    );

    final response = await http.post(
      Uri.parse(BackenConnection().url + BackenConnection().submitCourseQuizApi + courseId.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(submission.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return QuizResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit quiz');
    }
  }
}
