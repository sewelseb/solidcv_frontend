import 'package:solid_cv/business_layer/IWeeklyRecommendationBll.dart';
import 'package:solid_cv/data_access_layer/IWeeklyRecommendationService.dart';
import 'package:solid_cv/data_access_layer/WeeklyRecommendationService.dart';
import 'package:solid_cv/models/WeeklyRecommendation.dart';
import 'package:solid_cv/models/CourseQuestion.dart';
import 'package:solid_cv/models/QuizSubmission.dart';

class WeeklyRecommendationBll extends IWeeklyRecommendationBll {
  final IWeeklyRecommendationService _weeklyRecommendationService = WeeklyRecommendationService();

  @override
  Future<WeeklyRecommendation> getCurrentWeekRecommendations() {
    return _weeklyRecommendationService.getCurrentWeekRecommendations();
  }

  @override
  Future<WeeklyProgress> getWeeklyProgress() {
    return _weeklyRecommendationService.getWeeklyProgress();
  }

  @override
  Future<bool> markCourseAsCompleted(int courseId) {
    return _weeklyRecommendationService.markCourseAsCompleted(courseId);
  }

  @override
  Future<bool> registerForEvent(int eventId) {
    return _weeklyRecommendationService.registerForEvent(eventId);
  }

  @override
  Future<bool> unregisterFromEvent(int eventId) {
    return _weeklyRecommendationService.unregisterFromEvent(eventId);
  }

  @override
  Future<List<WeeklyRecommendation>> getRecommendationHistory({int? limit}) {
    return _weeklyRecommendationService.getRecommendationHistory(limit: limit);
  }

  @override
  Future<WeeklyRecommendation> getRecommendationsForWeek(String weekStartDate) {
    return _weeklyRecommendationService.getRecommendationsForWeek(weekStartDate);
  }

  @override
  Future<RecommendedCourse> getAiGeneratedCourse(int courseId) {
    return _weeklyRecommendationService.getAiGeneratedCourse(courseId);
  }

  @override
  Future<List<CourseQuestion>> getCourseQuestions(int courseId) {
    return _weeklyRecommendationService.getCourseQuestions(courseId);
  }

  @override
  Future<QuizResult> submitCourseQuiz(int courseId, Map<int, int> answers) {
    return _weeklyRecommendationService.submitCourseQuiz(courseId, answers);
  }
}
