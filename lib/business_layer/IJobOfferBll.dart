import 'package:solid_cv/Views/companyViews/ApplicantAIFeedbackView.dart';
import 'package:solid_cv/data_access_layer/IJobOffreService.dart';
import 'package:solid_cv/data_access_layer/JobOfferService.dart';
import 'package:solid_cv/models/ApplicantAIFeedback.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/models/User.dart';

abstract class IJobOfferBll {

  Future<List<JobOffer>>? getJobOffersByCompany(int companyId);

  deleteJobOffer(int id);

  createJobOffer(JobOffer jobOffer);

  Future<JobOffer>? getJobOfferById(int jobOfferId);

  updateJobOffer(JobOffer jobOffer);

  Future<List<JobOffer>>? getAllPublicJobOffers();

  applyToJobOffer(int id);

  Future<JobOffer>? getPublicJobOfferById(int id);

  Future<List<User>>? getApplicationsToJobOffer(int id);

  Future<ApplicantAIFeedback>? getAIFeedback(int i, int j) {}

  generateAIFeedback(int i, int j) {}

}