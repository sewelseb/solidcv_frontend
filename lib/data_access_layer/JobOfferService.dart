import 'package:solid_cv/data_access_layer/IJobOffreService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:http/http.dart' as http;
import 'package:solid_cv/config/BackenConnection.dart';
import 'dart:convert';

class JobOffreService implements IJobOfferService {

  @override
  void createJobOffer(JobOffer jobOffer) async {
    var response = await http.post(Uri.parse(BackenConnection().url+BackenConnection().createJobOfferApi),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
      },
      body: jsonEncode(jobOffer.toJson()),
    );

    if (response.statusCode == 200) {
      // Successfully created job offer
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to create job offer');
    }
  }
  
}