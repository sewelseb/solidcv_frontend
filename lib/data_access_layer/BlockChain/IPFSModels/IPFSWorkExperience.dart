import 'package:intl/intl.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';

class IPFSWorkExperience {
  String? id;
  String? jobTitle;
  String? companyName;
  String? companyId;
  String? companyBlockCahinWalletAddress;
  String? location;
  int? startDate;
  int? endDate;
  String? description;
  int objectVersion = 1;

  IPFSWorkExperience({
    this.id,
    this.jobTitle,
    this.companyName,
    this.companyId,
    this.companyBlockCahinWalletAddress,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
  });

  IPFSWorkExperience.fromExperienceRecord(ExperienceRecord experienceRecord, Company company) {
    id = '${DateTime.now().millisecondsSinceEpoch}_${1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 1000)}';
    jobTitle = experienceRecord.title;
    companyName = company.name;
    companyId = company.id.toString();
    companyBlockCahinWalletAddress = company.ethereumAddress;
    location = experienceRecord.location;
    startDate = DateFormat('dd/MM/yyyy').parse(experienceRecord.startDate!).millisecondsSinceEpoch * 1000;
    if (experienceRecord.endDate != null && experienceRecord.endDate!.isNotEmpty && experienceRecord.endDate != '') {
      endDate =  DateFormat('dd/MM/yyyy').parse(experienceRecord.endDate!).millisecondsSinceEpoch*1000;
    } 
    description = experienceRecord.description;
  }

  toJson() {
    return {
      "id": id,
      "jobTitle": jobTitle,
      "companyName": companyName,
      "companyId": companyId,
      "companyBlockCahinWalletAddress": companyBlockCahinWalletAddress,
      "location": location,
      "startDate": startDate,
      "endDate": endDate,
      "description": description,
      "objectVersion": objectVersion,
    };
  }
}