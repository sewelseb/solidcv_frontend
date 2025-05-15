import 'IPFSWorkEvent.dart';
import 'IPFSCleanExperience.dart';

class ExperienceStream {
  final String streamId;
  final List<WorkEvent> events;

  ExperienceStream({
    required this.streamId,
    required this.events,
  });

  CleanExperience build() {
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final experience = CleanExperience();
    for (final event in events) {
      event.apply(experience);
    }
    return experience;
  }

  bool get isOngoing => build().endDate == null;

  bool get hasBeenPromoted => build().promotions.isNotEmpty;

  int? get durationInDays {
    final exp = build();
    if (exp.startDate == null || exp.endDate == null) return null;
    return ((exp.endDate! - exp.startDate!) / (1000 * 60 * 60 * 24)).round();
  }
}
