import 'package:solid_cv/data_access_layer/IJobOffreService.dart';
import 'package:solid_cv/data_access_layer/JobOfferService.dart';
import 'package:solid_cv/models/JobOffer.dart';

abstract class IJobOfferBll {
  final IJobOfferService _jobOfferService = new JobOffreService();

  Future<List<JobOffer>>? getJobOffersByCompany(int i) {}

  deleteJobOffer(int jobOfferId) {}

  createJobOffer(JobOffer jobOffer) {
    return _jobOfferService.createJobOffer(jobOffer);
  }

}