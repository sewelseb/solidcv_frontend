import 'package:solid_cv/models/JobOffer.dart';

abstract class IJobOfferBll {
  Future<List<JobOffer>>? getJobOffersByCompany(int i) {}

  deleteJobOffer(int jobOfferId) {}

}