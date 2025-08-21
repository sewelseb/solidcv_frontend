class WeeklyRecommendation {
  int? id;
  List<RecommendedCourse>? courses;
  List<RecommendedEvent>? events;

  WeeklyRecommendation({
    this.id,
    this.courses,
    this.events,
  });

  WeeklyRecommendation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['course'] != null) {
      courses = <RecommendedCourse>[];
      json['course'].forEach((v) {
        courses!.add(RecommendedCourse.fromJson(v));
      });
    }
    if (json['events'] != null) {
      events = <RecommendedEvent>[];
      json['events'].forEach((v) {
        events!.add(RecommendedEvent.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (courses != null) {
      data['courses'] = courses!.map((v) => v.toJson()).toList();
    }
    if (events != null) {
      data['events'] = events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RecommendedCourse {
  int? id;
  String? title;
  String? description;
  String? provider;
  String? duration;
  String? difficulty;
  String? category;
  String? url;
  String? imageUrl;
  bool? isCompleted;
  DateTime? completedAt;
  String? iconName;
  String? courseContent;

  RecommendedCourse({
    this.id,
    this.title,
    this.description,
    this.provider,
    this.duration,
    this.difficulty,
    this.category,
    this.url,
    this.imageUrl,
    this.isCompleted,
    this.completedAt,
    this.iconName,
    this.courseContent,
  });

  RecommendedCourse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    provider = json['provider'];
    difficulty = json['level'];
    isCompleted = json['isCompleted'];
    completedAt = json['completedAt'];
    courseContent = json['courseContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['level'] = difficulty;
    data['isCompleted'] = isCompleted;
    data['completedAt'] = completedAt?.toIso8601String();
    return data;
  }
}

class RecommendedEvent {
  int? id;
  String? title;
  String? description;
  String? organizer;
  int? date;
  String? location;
  String? eventType;
  String? url;

  RecommendedEvent({
    this.id,
    this.title,
    this.description,
    this.organizer,
    this.date,
    this.location,
    this.eventType,
    this.url,
  });

  RecommendedEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    organizer = json['organizer'];
    date = json['date'];
    location = json['location'];
    eventType = json['eventType'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['organizer'] = organizer;
    data['date'] = date;
    data['location'] = location;
    data['eventType'] = eventType;
    data['url'] = url;
    return data;
  }
}

class WeeklyProgress {
  int? totalCourses;
  int? completedCourses;
  int? totalEvents;
  int? registeredEvents;
  double? overallProgress;

  WeeklyProgress({
    this.totalCourses,
    this.completedCourses,
    this.totalEvents,
    this.registeredEvents,
    this.overallProgress,
  });

  WeeklyProgress.fromJson(Map<String, dynamic> json) {
    totalCourses = json['totalCourses'];
    completedCourses = json['completedCourses'];
    totalEvents = json['totalEvents'];
    registeredEvents = json['registeredEvents'];
    overallProgress = json['overallProgress']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCourses'] = totalCourses;
    data['completedCourses'] = completedCourses;
    data['totalEvents'] = totalEvents;
    data['registeredEvents'] = registeredEvents;
    data['overallProgress'] = overallProgress;
    return data;
  }
}
