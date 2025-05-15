
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';

enum ExperienceOrigin {
  blockchain,
  manual,
}

class UnifiedExperienceViewModel {
  final int? manualId;

  final String title;
  final String company;
  final String? description;
  final String? location;
  final int? startDate;
  final int? endDate;
  final List<Promotion> promotions;
  final ExperienceOrigin origin;

  UnifiedExperienceViewModel({
    required this.title,
    required this.company,
    required this.startDate,
    required this.origin,
    this.description,
    this.location,
    this.endDate,
    this.promotions = const [],
    this.manualId,
  });

  String get label => origin == ExperienceOrigin.blockchain ? 'Verified' : 'Manual';

  bool get isVerified => origin == ExperienceOrigin.blockchain;

   factory UnifiedExperienceViewModel.fromClean(CleanExperience e) {
    return UnifiedExperienceViewModel(
      title: e.title ?? 'Unknown',
      company: e.companyName ?? 'Unknown',
      description: e.description,
      location: e.location,
      startDate: e.startDate ?? 0,
      endDate: e.endDate,
      promotions: e.promotions,
      origin: ExperienceOrigin.blockchain,
    );
  }

  // ✅ Convertisseur ManualExperience
  factory UnifiedExperienceViewModel.fromManual(ManualExperience e) {
    return UnifiedExperienceViewModel(
      manualId :e.id,
      title: e.title?? 'Unknown',
      company: e.company?? 'Unknown',
      description: e.description,
      location: e.location,
      startDate: e.startDateAsTimestamp != null ? e.startDateAsTimestamp! * 1000 : null,
      endDate: e.endDateAsTimestamp != null ? e.endDateAsTimestamp! * 1000 : null,
      promotions: e.promotions!
        .map((p) => Promotion(
              newTitle: p.newTitle,
              date: p.date * 1000,
            ))
        .toList(),
      origin: ExperienceOrigin.manual,
    );
  }

}
