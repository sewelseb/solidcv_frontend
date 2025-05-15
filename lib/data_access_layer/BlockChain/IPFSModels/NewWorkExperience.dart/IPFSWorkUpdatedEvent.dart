import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';

class WorkUpdatedEvent extends WorkEvent {
  final String? correctedTitle;
  final int? correctedStartDate;
  final int? correctedEndDate;
  final String? correctedDescription;
  final String? correctedLocation;
  final String? correctedPromotionTitle;
  final int? correctedPromotionDate;
  final String experienceStreamId;
  final String companyName;
  final String companyWallet;


  WorkUpdatedEvent({
    required super.id,
    required super.timestamp,
    this.correctedTitle,
    this.correctedStartDate,
    this.correctedEndDate,
    this.correctedDescription,
    this.correctedLocation,
    this.correctedPromotionTitle,
    this.correctedPromotionDate,
    required this.experienceStreamId,
    required this.companyName,
    required this.companyWallet,
  }) : super(type: 'WorkUpdatedEvent');

  @override
  void apply(CleanExperience experience) {
    experience.experienceStreamId = experienceStreamId;
    experience.companyName = companyName;
    experience.companyWallet = companyWallet;

    if (correctedTitle != null) experience.title = correctedTitle!;
    if (correctedStartDate != null) experience.startDate = correctedStartDate!;
    if (correctedEndDate != null) experience.endDate = correctedEndDate!;
    if (correctedDescription != null)
      experience.description = correctedDescription!;
    if (correctedLocation != null) experience.location = correctedLocation!;

    if (correctedPromotionDate != null && correctedPromotionTitle != null) {
      // Remove the old promotion if it exists
      experience.promotions
          .removeWhere((p) => p.date == correctedPromotionDate);
      experience.promotions.add(Promotion(
        newTitle: correctedPromotionTitle!,
        date: correctedPromotionDate!,
      ));
      experience.title = correctedPromotionTitle!;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "timestamp": timestamp,
        "type": type,
        "correctedTitle": correctedTitle,
        "correctedStartDate": correctedStartDate,
        "correctedEndDate": correctedEndDate,
        "correctedDescription": correctedDescription,
        "correctedLocation": correctedLocation,
        "correctedPromotionTitle": correctedPromotionTitle,
        "correctedPromotionDate": correctedPromotionDate,
        "experienceStreamId": experienceStreamId,
        "companyName": companyName,
        "companyWallet": companyWallet,
      };
}
