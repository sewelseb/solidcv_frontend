import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';

abstract class IIPFSService {
  Future<String> saveWorkExperience(ExperienceRecord experienceRecord, Company company);
}