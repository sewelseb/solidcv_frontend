import 'dart:convert';

import 'package:solid_cv/config/IPFSConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IIPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSWorkExperience.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:http/http.dart' as http;

class IPFSService extends IIPFSService {
  @override
  Future<String> saveWorkExperience(ExperienceRecord experienceRecord, Company company) async {
    // config
    var apiKey = IPFSConnection().apiKey;
    var apiSecret = IPFSConnection().apiSecret;
    var jwt = IPFSConnection().jwt;


    IPFSWorkExperience ipfsWorkExperience = IPFSWorkExperience.fromExperienceRecord(experienceRecord, company);

    var headers = {
      "pinata_api_key": apiKey,
      "pinata_secret_api_key": apiSecret,
      'Content-Type': 'application/json',
    };
    var url = Uri.parse(IPFSConnection().pinJsonUrl);
    var body = jsonEncode({
      "pinataMetadata": {
        "name": "ExperienceRecord",
      },
      // assuming client sends `nftMeta` json
      "pinataContent": ipfsWorkExperience.toJson(),
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final cid = responseData['IpfsHash'];
      return cid; // Return the CID of the pinned file
    } else {
      throw Exception('Failed to pin file to Filebase: ${response.statusCode}');
    }
  }
}
