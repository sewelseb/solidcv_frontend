class CourseQuestion {
  int? id;
  String? questionText;
  List<QuestionOption>? options;

  CourseQuestion({this.id, this.questionText, this.options});

  factory CourseQuestion.fromJson(Map<String, dynamic> json) {
    return CourseQuestion(
      id: json['id'],
      questionText: json['questionText'],
      options: json['options'] != null
          ? List<QuestionOption>.from(
              json['options'].map((x) => QuestionOption.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options?.map((x) => x.toJson()).toList(),
    };
  }
}

class QuestionOption {
  int? id;
  String? optionText;

  QuestionOption({this.id, this.optionText});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      optionText: json['optionText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionText': optionText,
    };
  }
}
