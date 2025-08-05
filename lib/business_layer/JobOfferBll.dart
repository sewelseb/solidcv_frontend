import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/data_access_layer/IJobOffreService.dart';
import 'package:solid_cv/data_access_layer/JobOfferService.dart';
import 'package:solid_cv/models/JobOffer.dart';

class JobOfferBll extends IJobOfferBll {
    final IJobOfferService _jobOfferService = new JobOffreService();

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
}