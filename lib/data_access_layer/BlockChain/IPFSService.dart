import 'dart:convert';

import 'package:solid_cv/config/IPFSConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IIPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSCertificate.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSWorkExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEventFactory.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:http/http.dart' as http;

class IPFSService extends IIPFSService {
  String _ipfsUrl = IPFSConnection().gatewayUrl;
  String _pinataUrl = IPFSConnection().pinJsonUrl;
  String _apiKey = IPFSConnection().apiKey;
  String _apiSecret = IPFSConnection().apiSecret;
  String _jwt = IPFSConnection().jwt;

  @override
  Future<String> saveWorkEvent(WorkEvent event) async {
  var headers = {
    "pinata_api_key": _apiKey,
    "pinata_secret_api_key": _apiSecret,
    'Content-Type': 'application/json',
  };

  var url = Uri.parse(IPFSConnection().pinJsonUrl);

  var body = jsonEncode({
    "pinataMetadata": {
      "name": "${event.type}-${event.id}"
    },
    "pinataContent": event.toJson(),
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final cid = responseData['IpfsHash'];
    return cid;
  } else {
    throw Exception('Failed to pin event to IPFS: ${response.statusCode}');
  }
}

@override
Future<WorkEvent> getWorkEvent(String ipfsHash) async {
  final response = await http.get(Uri.parse(ipfsHash));

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final event = WorkEventFactory.fromJson(responseData);
    return event;
  } else {
    throw Exception('Failed to get WorkEvent from IPFS: ${response.statusCode}');
  }
}
  
  @override
  Future<IPFSWorkExperience> getWorkExperience(String ipfsHash) async {
    final response = await http.get(Uri.parse(ipfsHash));

    if(response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final responseAsJson = IPFSWorkExperience.fromJson(responseData);
      return responseAsJson;
    } else {
      throw Exception('Failed to get file from IPFS: ${response.statusCode}');
    }
  }

  @override
  saveCertificate(Certificate certificate, EducationInstitution educationInstitution) async {
    var ipfsCertificate = IPFSCertificate.fromCertificate(certificate, educationInstitution);

    var headers = {
      "pinata_api_key": _apiKey,
      "pinata_secret_api_key": _apiSecret,
      'Content-Type': 'application/json',
    };
    var url = Uri.parse(IPFSConnection().pinJsonUrl);
    var body = jsonEncode({
      "pinataMetadata": {
        "name": "Certificate-"+ipfsCertificate.id.toString(),
      },
      // assuming client sends `nftMeta` json
      "pinataContent": ipfsCertificate.toJson(),
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

  @override
  saveDocumentCertificate(Certificate certificate) async {
    //save certificate.file to IPFS
    var headers = {
      "pinata_api_key": _apiKey,
      "pinata_secret_api_key": _apiSecret,
      'Content-Type': 'multipart/form-data',
    };
    var url = Uri.parse(IPFSConnection().pinFileUrl);

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile.fromBytes('file', certificate.file!.readAsBytesSync(), filename: "certificateDocument-"+certificate.title!));

    final response = await request.send();

    if (response.statusCode == 200) {
      var responseDataAsString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseDataAsString);
      final cid = responseData['IpfsHash'];
      return cid; // Return the CID of the pinned file
    } else {
      throw Exception('Failed to pin file to Filebase: ${response.statusCode}');
    }
  }
  
  @override
  Future<IPFSCertificate> getCertificate (String ipfsHash) async {
    final response = await http.get(Uri.parse(ipfsHash));

    if(response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final responseAsJson = IPFSCertificate.fromJson(responseData);
      return responseAsJson;
    } else {
      throw Exception('Failed to get file from IPFS: ${response.statusCode}');
    }
  }
}
