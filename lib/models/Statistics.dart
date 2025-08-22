class Statistics {
  final int users;
  final int companies;
  final int institutions;
  final int jobOffers;

  Statistics({
    required this.users,
    required this.companies,
    required this.institutions,
    required this.jobOffers,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      users: json['users'] ?? 0,
      companies: json['companies'] ?? 0,
      institutions: json['institutions'] ?? 0,
      jobOffers: json['jobOffers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users,
      'companies': companies,
      'institutions': institutions,
      'jobOffers': jobOffers,
    };
  }
}
