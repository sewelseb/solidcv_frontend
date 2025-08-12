
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';

class ManualExperience {
  final int? id;
  final String? title;
  final String? company;
  final String? description;
  final String? location;
  final int? startDateAsTimestamp;
  final int? endDateAsTimestamp;
  final List<Promotion>? promotions;

  ManualExperience({
     this.id,
    required this.title,
    required this.company,
    required this.startDateAsTimestamp,
    required this.promotions,
    this.description,
    this.location,
    this.endDateAsTimestamp,
  });

  factory ManualExperience.fromJson(Map<String, dynamic> json) {
    return ManualExperience(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      description: json['description'],
      location: json['location'],
      startDateAsTimestamp: json['startDate'],
      endDateAsTimestamp: json['endDate'],
       promotions: (json['promotions'] != null && json['promotions'] is List)
        ? (json['promotions'] as List<dynamic>)
            .map((p) => Promotion.fromJson(p))
            .toList()
        : [], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'description': description,
      'location': location,
      'startDate': startDateAsTimestamp,
      'endDate': endDateAsTimestamp,
      'promotions': promotions?.map((p) => p.toJson()).toList(),
    };
  }
}
