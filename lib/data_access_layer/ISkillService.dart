import 'package:solid_cv/models/Question.dart';

abstract class ISkillService {
  Future<Question> getAQuestionsForSkill(int skillId);

  void sendAnswerToAI(Question question);

  Future<String> getFeedbacksOnSkills(int skillId);

}