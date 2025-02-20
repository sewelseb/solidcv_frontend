import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class IPFSCertificate {
  String? id;
  String? title;
  String? type;
  String? grade;
  String? curriculum;
  String? description;
  String? publicationDate;
  String? imagelink;
  String? ipfsHash;
  String? documentIPFSUrl;
  String? issuer;
  String? issuerBlockCahinWalletAddress;
  int objectVersion = 1;

  IPFSCertificate({
    this.id,
    this.title,
    this.type,
    this.grade,
    this.curriculum,
    this.description,
    this.publicationDate,
    this.imagelink,
    this.ipfsHash,
    this.documentIPFSUrl,
    this.issuer,
    this.issuerBlockCahinWalletAddress,
  });

  IPFSCertificate.fromCertificate(Certificate certificate, EducationInstitution educationInstitution) {
    id = '${DateTime.now().millisecondsSinceEpoch}_${1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 1000)}';
    title = certificate.title;
    type = certificate.type;
    grade = certificate.grade;
    curriculum = certificate.curriculum;
    description = certificate.description;
    publicationDate = certificate.publicationDate;
    imagelink = certificate.imagelink;
    ipfsHash = certificate.ipfsHash;
    documentIPFSUrl = certificate.documentIPFSUrl;
    issuer = educationInstitution.name;
    issuerBlockCahinWalletAddress = educationInstitution.ethereumAddress;
  }

  toJson() {
    return {
      "id": id,
      "title": title,
      "type": type,
      "grade": grade,
      "curriculum": curriculum,
      "description": description,
      "publicationDate": publicationDate,
      "imagelink": imagelink,
      "ipfsHash": ipfsHash,
      "documentIPFSUrl": documentIPFSUrl,
      "issuer": issuer,
      "issuerBlockCahinWalletAddress": issuerBlockCahinWalletAddress,
      "objectVersion": objectVersion,
    };
  }

  static fromJson(responseData) {
    return IPFSCertificate(
      id: responseData['id'],
      title: responseData['title'],
      type: responseData['type'],
      grade: responseData['grade'],
      curriculum: responseData['curriculum'],
      description: responseData['description'],
      publicationDate: responseData['publicationDate'],
      imagelink: responseData['imagelink'],
      ipfsHash: responseData['ipfsHash'],
      documentIPFSUrl: responseData['documentIPFSUrl'],
      issuer: responseData['issuer'],
      issuerBlockCahinWalletAddress: responseData['issuerBlockCahinWalletAddress'],
    );
  }
}