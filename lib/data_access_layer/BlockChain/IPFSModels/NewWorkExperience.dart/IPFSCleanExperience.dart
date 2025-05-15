import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';

class CleanExperience {
  String? title;
  int? startDate;
  int? endDate;
  String? description;
  String? location;
  String? companyName;
  String? companyWallet;
  String? experienceStreamId;

  List<Promotion> promotions = [];

  String? get currentTitle {
  if (promotions.isEmpty) return title;
  promotions.sort((a, b) => b.date.compareTo(a.date)); // plus récent en premier
  return promotions.first.newTitle;
}
}