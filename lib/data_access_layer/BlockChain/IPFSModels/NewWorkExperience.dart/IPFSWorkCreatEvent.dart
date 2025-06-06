import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';

class WorkCreatedEvent extends WorkEvent {
  final String title;
  final int startDate;
  final String description;
  final String companyName;
  final String companyWallet;
  final String location;
  final String experienceStreamId;

  WorkCreatedEvent({
    required super.id,
    required super.timestamp,
    required this.title,
    required this.startDate,
    required this.description,
    required this.companyName,
    required this.companyWallet,
    required this.location,
    required this.experienceStreamId,
  }) : super(type: 'WorkCreatedEvent');

  @override
  void apply(CleanExperience experience) {
    experience.title = title;
    experience.startDate = startDate;
    experience.description = description;
    experience.companyName = companyName;
    experience.companyWallet = companyWallet;
    experience.location = location;
    experience.experienceStreamId = experienceStreamId;
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "timestamp": timestamp,
        "type": type,
        "title": title,
        "startDate": startDate,
        "description": description,
        "companyName": companyName,
        "companyWallet": companyWallet,
        "location": location,
        "experienceStreamId": experienceStreamId,
      };
}

