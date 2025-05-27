import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/IStatisticsService.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';
import 'package:solid_cv/models/Statistics.dart';

class StatisticsService extends IStatisticsService {

@override
Future<Statistics> getAdminStatistics() async {
  var response = await http.get(
      Uri.parse(BackenConnection().url+BackenConnection().getAllStatisticsForAdmin),
    headers: {
      'Content-Type': 'application/json',
      'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
    },
  );

  if (response.statusCode == 200) {
    print( response.body);
    return Statistics.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch statistics');
  }
}
}