class JobOffer {
  final int id;
  final String title;
  final String description;
  final String company;
  final String location;
  final double salary;

  var isActive;

  var createdAt;

  JobOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.salary,
    this.isActive = true,
    this.createdAt,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      company: json['company'],
      location: json['location'],
      salary: json['salary'].toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
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
    };
  }
}