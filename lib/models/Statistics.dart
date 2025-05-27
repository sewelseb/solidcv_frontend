class Statistics {
  final int users;
  final int companies;
  final int institutions;

  Statistics({
    required this.users,
    required this.companies,
    required this.institutions,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      users: json['users'] ?? 0,
      companies: json['companies'] ?? 0,
      institutions: json['institutions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users,
      'companies': companies,
      'institutions': institutions,
    };
  }
}
