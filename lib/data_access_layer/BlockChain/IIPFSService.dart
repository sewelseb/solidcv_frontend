import 'package:solid_cv/models/ExperienceRecord.dart';

abstract class IIPFSService {
  saveWorkExperience(ExperienceRecord experienceRecord, int companyId);
}