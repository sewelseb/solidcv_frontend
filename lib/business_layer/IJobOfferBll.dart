import 'package:solid_cv/data_access_layer/IJobOffreService.dart';
import 'package:solid_cv/data_access_layer/JobOfferService.dart';
import 'package:solid_cv/models/JobOffer.dart';

abstract class IJobOfferBll {

  Future<List<JobOffer>>? getJobOffersByCompany(int companyId);

  deleteJobOffer(int jobOfferId) {}

  createJobOffer(JobOffer jobOffer);

}