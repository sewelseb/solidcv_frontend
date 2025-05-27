import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';

class WorkEndedEvent extends WorkEvent {
  final int endDate;
  final String experienceStreamId;
  final String companyName;
  final String companyWallet;

  WorkEndedEvent({
    required super.id,
    required super.timestamp,
    required this.endDate,
    required this.experienceStreamId,
    required this.companyName,
    required this.companyWallet,
  }) : super(type: 'WorkEndedEvent');

  @override
  void apply(CleanExperience experience) {
    experience.endDate = endDate;
    experience.experienceStreamId = experienceStreamId;
    experience.companyName = companyName;
    experience.companyWallet = companyWallet; 
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "timestamp": timestamp,
        "type": type,
        "endDate": endDate,
        "experienceStreamId": experienceStreamId,
        "companyName": companyName,
        "companyWallet": companyWallet,
      };
}
