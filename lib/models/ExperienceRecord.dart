class ExperienceRecord {
  final String? id;
  final String? title;
  final String? company;
  final String? location;
  final String? startDate;
  final String? endDate;
  final String? description;

  ExperienceRecord({
    this.id,
    this.title,
    this.company,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
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
    };
  }
}