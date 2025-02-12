import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSWorkExperience.dart';

class ExperienceRecord {
  String? id;
  String? title;
  String? company;
  String? location;
  String? startDate;
  String? endDate;
  String? description;
  String? ethereumToken;

  ExperienceRecord({
    this.id,
    this.title,
    this.company,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
    this.ethereumToken,
  });

  factory ExperienceRecord.fromJson(Map<String, dynamic> json) {
    return ExperienceRecord(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      ethereumToken: json['ethereumToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'ethereumToken': ethereumToken,
    };
  }

  static ExperienceRecord fromIPFSExperience(IPFSWorkExperience experience) {
    return ExperienceRecord(
      title: experience.jobTitle,
      company: experience.companyName,
      location: experience.location,
      startDate: experience.startDate.toString(),
      endDate: experience.endDate.toString(),
      description: experience.description,
    );
  }
}