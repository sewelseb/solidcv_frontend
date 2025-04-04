import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/data_access_layer/ISkillService.dart';
import 'package:solid_cv/data_access_layer/SkillService.dart';
import 'package:solid_cv/models/Question.dart';

class SkillBll extends ISkillBll {
  ISkillService _skillService = SkillService();

  @override
  Future<Question> getAQuestionsForSkill(int SkillId) {
    return _skillService.getAQuestionsForSkill(SkillId);
  }
  
  @override
  sendAnswerToAI(Question question) {
    _skillService.sendAnswerToAI(question);
  }
  
  @override
  Future<String> getFeedbacksOnSkills(int skillId) {
    return _skillService.getFeedbacksOnSkills(skillId);
  }
}