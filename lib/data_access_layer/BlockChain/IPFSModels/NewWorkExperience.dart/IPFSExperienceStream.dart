import 'IPFSCleanExperience.dart';
import 'IPFSWorkEvent.dart';

class ExperienceStream {
  final String streamId;
  final List<WorkEvent> events;

  ExperienceStream({
    required this.streamId,
    required this.events,
  });

  CleanExperience build() {
    final sortedEvents = [...events]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final experience = CleanExperience();
    for (final event in sortedEvents) {
      event.apply(experience);
    }

    return experience;
  }
}
