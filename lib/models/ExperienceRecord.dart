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

  int? startDateAsTimestamp;
  int? endDateAsTimestamp;

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
    var experienceRecord = ExperienceRecord(
      id: json['id'].toString(),
      title: json['title'],
      company: json['company'],
      location: json['location'],
      description: json['description'],
      ethereumToken: json['ethereumToken'],
    );
    if (json['startDate'] is int) {
      experienceRecord.startDateAsTimestamp = json['startDate'];
      experienceRecord.startDate = _formatTimestamp(json['startDate']);
    } else {
      experienceRecord.startDate = json['startDate'];
      experienceRecord.startDateAsTimestamp = _parseTimestamp(json['startDate']);
    }

    if (json['endDate'] is int) {
      experienceRecord.endDateAsTimestamp = json['endDate'];
      experienceRecord.endDate = _formatTimestamp(json['endDate']);
    } else {
      experienceRecord.endDate = json['endDate'];
      experienceRecord.endDateAsTimestamp = _parseTimestamp(json['endDate']);
    }
    return experienceRecord;
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
      'startDateAsTimestamp': startDateAsTimestamp,
      'endDateAsTimestamp': endDateAsTimestamp,
    };
  }

  static ExperienceRecord fromIPFSExperience(IPFSWorkExperience experience) {
    var experienceRecord = ExperienceRecord(
      title: experience.jobTitle,
      company: experience.companyName,
      location: experience.location,
      startDate: _formatTimestamp(experience.startDate),
      endDate: _formatTimestamp(experience.endDate),
      description: experience.description,
    );

    experienceRecord.startDateAsTimestamp = experience.startDate;
    experienceRecord.endDateAsTimestamp = experience.endDate;

    return experienceRecord;
  }

  static String _formatTimestamp(int? timestamp) {
  if (timestamp == null) return 'Ongoing';

  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000); // ✅ FIX
  return '${date.day}/${date.month}/${date.year}';
}

  static int? _parseTimestamp(String? date) {
    if (date == 'Ongoing') return null;

    List<String> dateParts = date!.split('/');
    return DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0])).millisecondsSinceEpoch;
  }

  static int? _parseTimestampFromSelector(String? date) {
  if (date == null) return null;

  DateTime parsedDate = DateTime.parse(date);
  return parsedDate.millisecondsSinceEpoch ~/ 1000; 
}


  void setTimeStampsFromSelector() {
    startDateAsTimestamp = _parseTimestampFromSelector(startDate);
    endDateAsTimestamp = _parseTimestampFromSelector(endDate);
  }
}