class CareerAdvice {
  String? id;
  String? userId;
  String? summary;
  List<String>? recommendations;
  List<String>? skillDevelopment;
  List<String>? nextSteps;
  List<CareerResource>? resources;
  CareerAdviceRequest? requestData;
  DateTime? createdAt;
  DateTime? updatedAt;

  CareerAdvice({
    this.id,
    this.userId,
    this.summary,
    this.recommendations,
    this.skillDevelopment,
    this.nextSteps,
    this.resources,
    this.requestData,
    this.createdAt,
    this.updatedAt,
  });

  CareerAdvice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    summary = json['careerSummary'];
    recommendations = json['keyRecommendations'] != null
        ? List<String>.from(json['keyRecommendations'])
        : null;
    skillDevelopment = json['skillDevelopment'] != null
        ? List<String>.from(json['skillDevelopment'])
        : null;
    nextSteps = json['nextSteps'] != null
        ? List<String>.from(json['nextSteps'])
        : null;
    resources = json['recommendedResources'] != null
        ? (json['recommendedResources'] as List)
            .map((item) => CareerResource.fromJson(item))
            .toList()
        : null;
    requestData = json['requestData'] != null
        ? CareerAdviceRequest.fromJson(json['requestData'])
        : null;
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['summary'] = summary;
    data['recommendations'] = recommendations;
    data['skillDevelopment'] = skillDevelopment;
    data['nextSteps'] = nextSteps;
    data['resources'] = resources?.map((item) => item.toJson()).toList();
    data['requestData'] = requestData?.toJson();
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }

  // Convert to the format expected by the UI
  Map<String, dynamic> toAdviceMap() {
    return {
      'summary': summary ?? '',
      'recommendations': recommendations ?? [],
      'skillDevelopment': skillDevelopment ?? [],
      'nextSteps': nextSteps ?? [],
      'resources': resources?.map((resource) => resource.toMap()).toList() ?? [],
    };
  }

  bool get isValid {
    return summary != null && 
           summary!.isNotEmpty &&
           recommendations != null &&
           recommendations!.isNotEmpty;
  }
}

class CareerResource {
  String? title;
  String? description;
  String? url;
  String? type; // 'course', 'certification', 'platform', 'tool', etc.

  CareerResource({
    this.title,
    this.description,
    this.url,
    this.type,
  });

  CareerResource.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    url = json['url'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['type'] = type;
    return data;
  }

  // Convert to the format expected by the UI
  Map<String, String> toMap() {
    return {
      'title': title ?? '',
      'description': description ?? '',
      'url': url ?? '',
      'type': type ?? '',
    };
  }
}

class CareerAdviceRequest {
  String? careerGoal;
  Map<String, int>? skillRatings;
  List<String>? selectedIndustries;
  Map<String, String>? workPreferences;
  bool? cvCompleted;
  DateTime? timestamp;

  CareerAdviceRequest({
    this.careerGoal,
    this.skillRatings,
    this.selectedIndustries,
    this.workPreferences,
    this.cvCompleted,
    this.timestamp,
  });

  CareerAdviceRequest.fromJson(Map<String, dynamic> json) {
    careerGoal = json['careerGoal'];
    skillRatings = json['skillRatings'] != null
        ? Map<String, int>.from(json['skillRatings'])
        : null;
    selectedIndustries = json['selectedIndustries'] != null
        ? List<String>.from(json['selectedIndustries'])
        : null;
    workPreferences = json['workPreferences'] != null
        ? Map<String, String>.from(json['workPreferences'])
        : null;
    cvCompleted = json['cvCompleted'];
    timestamp = json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['careerGoal'] = careerGoal;
    data['skillRatings'] = skillRatings;
    data['selectedIndustries'] = selectedIndustries;
    data['workPreferences'] = workPreferences;
    data['cvCompleted'] = cvCompleted;
    data['timestamp'] = timestamp?.toIso8601String();
    return data;
  }

  bool get isValid {
    return careerGoal != null && 
           careerGoal!.isNotEmpty &&
           skillRatings != null &&
           skillRatings!.isNotEmpty;
  }
}

// Enum for career advice status
enum CareerAdviceStatus {
  pending,
  processing,
  completed,
  failed,
}

extension CareerAdviceStatusExtension on CareerAdviceStatus {
  String get value {
    switch (this) {
      case CareerAdviceStatus.pending:
        return 'pending';
      case CareerAdviceStatus.processing:
        return 'processing';
      case CareerAdviceStatus.completed:
        return 'completed';
      case CareerAdviceStatus.failed:
        return 'failed';
    }
  }

  static CareerAdviceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return CareerAdviceStatus.pending;
      case 'processing':
        return CareerAdviceStatus.processing;
      case 'completed':
        return CareerAdviceStatus.completed;
      case 'failed':
        return CareerAdviceStatus.failed;
      default:
        return CareerAdviceStatus.pending;
    }
  }
}