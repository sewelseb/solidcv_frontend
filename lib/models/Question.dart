class Question {
  int? id;
  String? question;
  String? answer;
  
  int? skillId;

  Question({this.id, this.question, this.answer, this.skillId});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      skillId: json['skillId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'skillId': skillId,
    };
  }

}