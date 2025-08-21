class QuizSubmission {
  int? courseId;
  List<QuizAnswer>? answers;

  QuizSubmission({this.courseId, this.answers});

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'answers': answers?.map((x) => x.toJson()).toList(),
    };
  }
}

class QuizAnswer {
  int? questionId;
  int? selectedOptionId;

  QuizAnswer({this.questionId, this.selectedOptionId});

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
    };
  }
}

class QuizResult {
  bool? passed;
  int? score;
  int? totalQuestions;
  String? message;

  QuizResult({this.passed, this.score, this.totalQuestions, this.message});

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      passed: json['passed'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      message: json['message'],
    );
  }
}
