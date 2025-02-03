import 'dart:convert';

import 'package:solid_cv/config/IPFSConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IIPFSService.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:http/http.dart' as http;

class IPFSService extends IIPFSService {
  @override
  saveWorkExperience(ExperienceRecord experienceRecord, int companyId) async {
    // config
    var apiKey = IPFSConnection().apiKey;
    var apiSecret = IPFSConnection().apiSecret;
    var jwt = IPFSConnection().jwt;

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
      "pinataContent": experienceRecord.toJson(),
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final cid = responseData['IpfsHash'];
      return cid; // Return the CID of the pinned file
    } else {
      throw Exception('Failed to pin file to Filebase: ${response.statusCode}');
    }

    // try {
    //   final jsonString = jsonEncode(experienceRecord.toJson());

    //   // Prepare the request body
    //   final body = jsonEncode({
    //     "CID":"",
    //     'name': 'demo.json',
    //     'meta': experienceRecord.toJson()
    //   });

    //   // Set the Filebase API endpoint
    //   final url = Uri.parse('https://api.filebase.io/v1/ipfs');

    //   // Set the headers
    //   final headers = {
    //     'Authorization': 'Bearer $filebaseApiKey',
    //     'Content-Type': 'application/json',
    //   };

    //   // Send the request
    //   final response = await http.post(url, headers: headers, body: body);

    //   // Check for success
    //   if (response.statusCode == 200) {
    //     final responseData = jsonDecode(response.body);
    //     final cid = responseData['cid'];
    //     return cid; // Return the CID of the pinned file
    //   } else {
    //     throw Exception(
    //         'Failed to pin file to Filebase: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   throw Exception('Error sending file to Filebase: $e');
    // }
  }
}
