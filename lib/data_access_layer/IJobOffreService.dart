import 'package:solid_cv/models/ApplicantAIFeedback.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/models/User.dart';

abstract class IJobOfferService {
  createJobOffer(JobOffer jobOffer);

  Future<List<JobOffer>>? getJobOffersByCompany(int companyId);

  Future<JobOffer>? getJobOfferById(int jobOfferId);

  updateJobOffer(JobOffer jobOffer);

  deleteJobOffer(int id);

  Future<List<JobOffer>>? getAllPublicJobOffers();

  Future<JobOffer>? getPublicJobOfferById(int id);

  applyToJobOffer(int id);

  Future<List<User>>? getApplicationsToJobOffer(int id);

  Future<ApplicantAIFeedback> generateAIFeedback(int userId, int jobOfferId);

  Future<ApplicantAIFeedback?> getAIFeedback(int userId, int jobOfferId);
}