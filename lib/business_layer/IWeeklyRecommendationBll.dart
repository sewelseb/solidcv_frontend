import 'package:solid_cv/models/WeeklyRecommendation.dart';
import 'package:solid_cv/models/CourseQuestion.dart';
import 'package:solid_cv/models/QuizSubmission.dart';

abstract class IWeeklyRecommendationBll {
  Future<WeeklyRecommendation> getCurrentWeekRecommendations();
  Future<WeeklyProgress> getWeeklyProgress();
  Future<bool> markCourseAsCompleted(int courseId);
  Future<bool> registerForEvent(int eventId);
  Future<bool> unregisterFromEvent(int eventId);
  Future<List<WeeklyRecommendation>> getRecommendationHistory({int? limit});
  Future<WeeklyRecommendation> getRecommendationsForWeek(String weekStartDate);
  Future<RecommendedCourse> getAiGeneratedCourse(int courseId);
  Future<List<CourseQuestion>> getCourseQuestions(int courseId);
  Future<QuizResult> submitCourseQuiz(int courseId, Map<int, int> answers);
}
