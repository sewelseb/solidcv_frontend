import 'package:solid_cv/models/WeeklyRecommendation.dart';

abstract class IWeeklyRecommendationBll {
  Future<WeeklyRecommendation> getCurrentWeekRecommendations();
  Future<WeeklyProgress> getWeeklyProgress();
  Future<bool> markCourseAsCompleted(int courseId);
  Future<bool> registerForEvent(int eventId);
  Future<bool> unregisterFromEvent(int eventId);
  Future<List<WeeklyRecommendation>> getRecommendationHistory({int? limit});
  Future<WeeklyRecommendation> getRecommendationsForWeek(String weekStartDate);
  Future<RecommendedCourse> getAiGeneratedCourse(int courseId);
}
