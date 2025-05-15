import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';

class ExperienceTimeline {
  final List<WorkEvent> events;

  ExperienceTimeline(this.events);

  CleanExperience build() {
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final result = CleanExperience();
    for (final event in events) {
      event.apply(result);
    }
    return result;
  }
}
