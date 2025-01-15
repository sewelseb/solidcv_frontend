class SearchTherms {
  String? term;
  String? date;

  SearchTherms({this.term, this.date});

  factory SearchTherms.fromJson(Map<String, dynamic> json) {
    return SearchTherms(
      term: json['term'],
      date: json['date'],
    );
  }
}