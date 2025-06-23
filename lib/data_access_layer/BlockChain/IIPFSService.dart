import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSCertificate.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/IPFSWorkExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

abstract class IIPFSService {

  Future<IPFSWorkExperience> getWorkExperience(String ipfsHash);

  saveCertificate(Certificate certificate, EducationInstitution educationInstitution);

  saveDocumentCertificate(Certificate certificate);

  Future<IPFSCertificate> getCertificate(String ipfsHash);

  Future<String> saveWorkEvent(WorkEvent event);

  Future<WorkEvent> getWorkEvent(String ipfsHash);
}