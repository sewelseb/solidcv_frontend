import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkCreatEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEndedEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkPromotedEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkUpdatedEvent.dart';

class WorkEventFactory {
  static WorkEvent fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'WorkCreatedEvent':
        return WorkCreatedEvent(
          id: json['id'],
          timestamp: json['timestamp'],
          title: json['title'],
          startDate: json['startDate'],
          description: json['description'],
          companyName: json['companyName'],
          companyWallet: json['companyWallet'],
          location: json['location'],
          experienceStreamId: json['experienceStreamId'],
        );
      case 'WorkUpdatedEvent':
        return WorkUpdatedEvent(
          id: json['id'],
          timestamp: json['timestamp'],
          correctedTitle: json['correctedTitle'],
          correctedStartDate: json['correctedStartDate'],
          correctedEndDate: json['correctedEndDate'],
          correctedDescription: json['correctedDescription'],
          correctedLocation: json['correctedLocation'],
          correctedPromotionTitle: json['correctedPromotionTitle'],
          correctedPromotionDate: json['correctedPromotionDate'],
          experienceStreamId: json['experienceStreamId'],
          companyName: json['companyName'],
          companyWallet: json['companyWallet'],

        );
      case 'WorkPromotedEvent':
        return WorkPromotedEvent(
          id: json['id'],
          timestamp: json['timestamp'],
          newTitle: json['newTitle'],
          promotionDate: json['promotionDate'],
          experienceStreamId: json['experienceStreamId'],
          companyName: json['companyName'],
          companyWallet: json['companyWallet'],

        );
      case 'WorkEndedEvent':
        return WorkEndedEvent(
          id: json['id'],
          timestamp: json['timestamp'],
          endDate: json['endDate'],
          experienceStreamId: json['experienceStreamId'],
          companyName: json['companyName'],
          companyWallet: json['companyWallet'],

        );
      default:
        throw Exception('Unknown event type: $type');
    }
  }
}
