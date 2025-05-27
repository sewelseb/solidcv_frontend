import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';

class WorkPromotedEvent extends WorkEvent {
  final String newTitle;
  final int promotionDate;
  final String experienceStreamId;
  final String companyName;
  final String companyWallet;


  WorkPromotedEvent({
    required super.id,
    required super.timestamp,
    required this.newTitle,
    required this.promotionDate,
    required this.experienceStreamId,
    required this.companyName,
    required this.companyWallet,
  }) : super(type: 'WorkPromotedEvent');

  @override
  void apply(CleanExperience experience) {
    experience.promotions.removeWhere((p) => p.date == promotionDate);
    experience.promotions.add(Promotion(newTitle: newTitle, date: promotionDate));
    experience.experienceStreamId = experienceStreamId; 
    experience.companyName = companyName;
    experience.companyWallet = companyWallet;
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "timestamp": timestamp,
        "type": type,
        "newTitle": newTitle,
        "promotionDate": promotionDate,
        "experienceStreamId": experienceStreamId,
        "companyName": companyName,
        "companyWallet": companyWallet,
      };
}
