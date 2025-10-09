import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSCertificate.dart';

class Certificate {
  String? id;
  String? title;
  String? type;
  String? grade;
  String? curriculum;
  String? description;
  String? publicationDate;
  String? imagelink;
  File? file;
  Uint8List? fileBytes; // For web platform file uploads
  String?fielPath;
  String? ipfsHash;
  String? documentIPFSUrl;
  String? teachingInstitutionName;
  String? fileExtention;
  String? logoUrl;
  String? issuerBlockCahinWalletAddress;
  bool? isInstitutionVerified;

  Certificate({this.id, this.title, this.type, this.grade, this.curriculum, this.description, this.publicationDate, this.imagelink, this.file, this.fileBytes, this.ipfsHash, this.documentIPFSUrl, String? this.teachingInstitutionName, this.logoUrl,this.issuerBlockCahinWalletAddress, this.isInstitutionVerified});

  Certificate.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    type = json['type'];
    grade = json['grade'];
    curriculum = json['curriculum'];
    description = json['description'];
    publicationDate = json['publicationDate'];
    imagelink = json['imagelink'];
    fielPath = json['file'];
    ipfsHash = json['ipfsHash'];
    documentIPFSUrl = json['documentIPFSUrl'];
    teachingInstitutionName = json['institution'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'grade': grade,
      'curriculum': curriculum,
      'description': description,
      'publicationDate': publicationDate,
      'imagelink': imagelink,
      'file': file != null ? base64Encode(file!.readAsBytesSync()) : null,
      'ipfsHash': ipfsHash,
      'documentIPFSUrl': documentIPFSUrl,
      'teachingInstitutionName': teachingInstitutionName,
      'fileExtention': file?.path.split('.').last,
      'publicationDateAsTimestamp': publicationDate != null ? DateTime.parse(publicationDate!).millisecondsSinceEpoch*1000 : null,
    };
  }

  static Certificate fromIPFSCertificate(IPFSCertificate certificate) {
    return Certificate(
      id: certificate.id,
      title: certificate.title,
      type: certificate.type,
      grade: certificate.grade,
      curriculum: certificate.curriculum,
      description: certificate.description,
      publicationDate: certificate.publicationDate,
      imagelink: certificate.imagelink,
      ipfsHash: certificate.ipfsHash,
      documentIPFSUrl: certificate.documentIPFSUrl,
      issuerBlockCahinWalletAddress: certificate.issuerBlockCahinWalletAddress,
    );
  }
}