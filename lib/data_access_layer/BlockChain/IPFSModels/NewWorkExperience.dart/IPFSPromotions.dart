class Promotion {
  final String newTitle;
  final int date;

  Promotion({required this.newTitle, required this.date});

    factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      newTitle: json['newTitle'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newTitle': newTitle,
      'date': date,
    };
  }
}
