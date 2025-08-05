import 'package:solid_cv/models/Company.dart';

class JobOffer {
  final int? id;
  final int? companyId;
  final String? title;
  final String? description;
  final Company? company;
  final String location;
  final double? salary;

  bool? isActive;

  int? createdAt;
  String? requirements;
  String? benefits;
  String jobType;
  String experienceLevel;

  JobOffer({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.salary,
    this.isActive = true,
    this.createdAt, 
    this.requirements,
    this.benefits,
    required this.jobType,
    required this.experienceLevel,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      id: json['id'],
      companyId: json['companyId'],
      title: json['title'],
      description: json['description'],
      company: Company.fromJson(json['company']),
      location: json['location'],
      salary: json['salary'] is double
          ? json['salary']
          : json['salary'] is int
              ? (json['salary'] as int).toDouble()
              : json['salary'] is String
                  ? double.tryParse(json['salary'])
                  : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
      requirements: json['requirements'],
      benefits: json['benefits'],
      jobType: json['jobType'],
      experienceLevel: json['experienceLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'salary': salary,
      'isActive': isActive,
      'createdAt': createdAt,
      'requirements': requirements,
      'benefits': benefits,
      'jobType': jobType,
      'experienceLevel': experienceLevel,
      'companyId': companyId,
    };
  }
}