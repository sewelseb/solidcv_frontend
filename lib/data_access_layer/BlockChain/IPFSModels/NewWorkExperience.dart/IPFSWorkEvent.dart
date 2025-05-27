import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';

abstract class WorkEvent {
  final String id;
  final int timestamp;
  final String type;

  WorkEvent({
    required this.id,
    required this.timestamp,
    required this.type,
  });

  void apply(CleanExperience experience);

  Map<String, dynamic> toJson();
}
