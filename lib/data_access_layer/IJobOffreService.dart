import 'package:solid_cv/models/JobOffer.dart';

abstract class IJobOfferService {
  createJobOffer(JobOffer jobOffer);

  Future<List<JobOffer>>? getJobOffersByCompany(int companyId);

  Future<JobOffer>? getJobOfferById(int jobOfferId);

  updateJobOffer(JobOffer jobOffer);
  
}