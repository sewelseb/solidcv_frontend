import 'package:solid_cv/models/Question.dart';

abstract class ISkillBll {
  Future<Question> getAQuestionsForSkill(int SkillId);

  sendAnswerToAI(Question question);

  Future<String> getFeedbacksOnSkills(int skillId);

}