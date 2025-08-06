import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/data_access_layer/IJobOffreService.dart';
import 'package:solid_cv/data_access_layer/JobOfferService.dart';
import 'package:solid_cv/models/ApplicantAIFeedback.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/models/User.dart';

class JobOfferBll extends IJobOfferBll {
    final IJobOfferService _jobOfferService = JobOffreService();

  @override
  createJobOffer(JobOffer jobOffer) {
    return _jobOfferService.createJobOffer(jobOffer);
  }
  
  @override
  Future<List<JobOffer>>? getJobOffersByCompany(int companyId) {
    return _jobOfferService.getJobOffersByCompany(companyId);
  }
  
  @override
  Future<JobOffer>? getJobOfferById(int jobOfferId) {
    return _jobOfferService.getJobOfferById(jobOfferId);
  }
  
  @override
  updateJobOffer(JobOffer jobOffer) {
    return _jobOfferService.updateJobOffer(jobOffer);
  }
  
  @override
  deleteJobOffer(int id) {
    return _jobOfferService.deleteJobOffer(id);
  }
  
  @override
  Future<List<JobOffer>>? getAllPublicJobOffers() {
    return _jobOfferService.getAllPublicJobOffers();
  }
  
  @override
  Future<JobOffer>? getPublicJobOfferById(int id) {
    return _jobOfferService.getPublicJobOfferById(id);
  }
  
  @override
  applyToJobOffer(int id) {
    return _jobOfferService.applyToJobOffer(id);
  }

  @override
  Future<List<User>>? getApplicationsToJobOffer(int id) {
    return _jobOfferService.getApplicationsToJobOffer(id);
  }
  
  @override
  Future<ApplicantAIFeedback> generateAIFeedback(int userId, int jobOfferId) {
    return _jobOfferService.generateAIFeedback(userId, jobOfferId);
  }
  
  @override
  Future<ApplicantAIFeedback?> getAIFeedback(int userId, int jobOfferId) async {
    return await _jobOfferService.getAIFeedback(userId, jobOfferId);
  }
}