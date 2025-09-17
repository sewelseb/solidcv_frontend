class Statistics {
  final int users;
  final int companies;
  final int institutions;
  final int jobOffers;
  final int courseFollowed;
  final int answeredQuestions;



  Statistics({
    required this.users,
    required this.companies,
    required this.institutions,
    required this.jobOffers,
    required this.courseFollowed,
    required this.answeredQuestions,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      users: json['users'] ?? 0,
      companies: json['companies'] ?? 0,
      institutions: json['institutions'] ?? 0,
      jobOffers: json['jobOffers'] ?? 0,
      courseFollowed: json['courseFollowed'] ?? 0,
      answeredQuestions: json['answeredQuestions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users,
      'companies': companies,
      'institutions': institutions,
      'jobOffers': jobOffers,
      'courseFollowed': courseFollowed,
      'answeredQuestions': answeredQuestions,
    };
  }
}
