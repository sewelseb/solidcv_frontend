class ApplicantAIFeedback {

  double? overallScore;

  double? technicalScore;

  double? experienceScore;

  double? culturalFitScore;

  List<String>? strengths;

  List<String>? weaknesses;

  String? conclusion;

  List<String>? recommendations;

  ApplicantAIFeedback({
    this.overallScore,
    this.technicalScore,
    this.experienceScore,
    this.culturalFitScore,
    this.strengths,
    this.weaknesses,
    this.conclusion,
    this.recommendations,
  });

  ApplicantAIFeedback.fromJson(Map<String, dynamic> json) {
    overallScore = json['overallScore']?.toDouble();
    technicalScore = json['technicalScore']?.toDouble();
    experienceScore = json['experienceScore']?.toDouble();
    culturalFitScore = json['culturalFitScore']?.toDouble();
    strengths = (json['strengths'] as List?)?.map((e) => e.toString()).toList();
    weaknesses = (json['weaknesses'] as List?)?.map((e) => e.toString()).toList();
    conclusion = json['conclusion'];
    recommendations = (json['recommendations'] as List?)?.map((e) => e.toString()).toList();
  }
}