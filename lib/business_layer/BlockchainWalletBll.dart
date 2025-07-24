import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/config/IPFSConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/EtheriumWalletService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IIPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSExperienceStream.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:solid_cv/data_access_layer/CompanyService.dart';
import 'package:solid_cv/data_access_layer/EducationInstitutionService.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/data_access_layer/IEducationInstitutionService.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainWalletBll extends IBlockchainWalletBll {
  final IWalletService _walletService = EtheriumWalletService();
  final IUserService _userService = UserService();
  final ICompanyService _companyService = CompanyService();
  final IEducationInstitutionService _educationInstitutionService =
      EducationInstitutionService();
  final IIPFSService _ipfsService = IPFSService();

  @override
  Future<bool> saveWalletAddressForCurrentUser(String address) async {
    if (!await isWalletAddressValid(address)) return false;

    // Save the address to the user's profile
    _userService.saveWalletAddressForCurrentUser(address);

    return true;
  }

  Future<bool> isWalletAddressValid(String address) async {
    try {
      var ballance = await _walletService.getBalanceInWei(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  createCertificateToken(Certificate certificate, User user,
      EducationInstitution educationInstitution, String password) async {
    var privateKey = await getTeachingInstitutionPrivateKey(
        educationInstitution.id!, password);

    //create the IPFS uri for the document
    certificate.documentIPFSUrl = IPFSConnection().gatewayUrl +
        await _ipfsService.saveDocumentCertificate(certificate);

    //create the IPFS uri for the data
    var url = IPFSConnection().gatewayUrl +
        await _ipfsService.saveCertificate(certificate, educationInstitution);

    //mint the token
    var reciever = await _userService.getUser(user.id.toString());
    if (reciever.ethereumAddress == null) {
      throw Exception("User does not have an Base Blochchain address");
    }
    if (educationInstitution.ethereumAddress == null) {
      throw Exception("Company does not have an Base Blochchain address");
    }
    var tokenAddress = await _walletService.mintCertificateToken(privateKey,
        educationInstitution.ethereumAddress!, reciever.ethereumAddress!, url);
    return tokenAddress;
  }


  @override
  Future<String> createWorkEventToken(
      WorkEvent event, int companyId, int userId, String password) async {
    final privateKey = await getCompanyPrivateKey(companyId, password);

    final company = await _companyService.getCompany(companyId);
    final receiver = await _userService.getUser(userId.toString());

    if (receiver.ethereumAddress == null) {
      throw Exception("User does not have an Base Blochchain address");
    }

    if (company.ethereumAddress == null) {
      throw Exception("Company does not have an Base Blochchain address");
    }

    final cid = await _ipfsService.saveWorkEvent(event);

    final url = IPFSConnection().gatewayUrl + cid;

    final tokenAddress = await _walletService.mintWorkExperienceToken(
      privateKey,
      company.ethereumAddress!,
      receiver.ethereumAddress!,
      url,
    );

    return tokenAddress;
  }

  Future<String> getTeachingInstitutionPrivateKey(
      int educationInstitutionId, String password) async {
    var educationInstitution = await _educationInstitutionService
        .getEducationInstitution(educationInstitutionId);
    const storage = FlutterSecureStorage();
    var encryptedWallet = await storage.read(
        key: 'etheriumWallet-${educationInstitution.ethereumAddress!}');
    var wallet = Wallet.fromJson(encryptedWallet!, password);
    return "0x${bytesToHex(wallet.privateKey.privateKey)}";
  }

  Future<String> getCompanyPrivateKey(int companyId, String password) async {
    var company = await _companyService.getCompany(companyId);
    const storage = FlutterSecureStorage();
    var encryptedWallet =
        await storage.read(key: 'etheriumWallet-${company.ethereumAddress!}');
    var wallet = Wallet.fromJson(encryptedWallet!, password);
    return "0x${bytesToHex(wallet.privateKey.privateKey)}";
  }

  @override
  Future<List<CleanExperience>> getEventsForCurrentUser() async {
    var user = await _userService.getCurrentUser();
    var nftList =
        await _walletService.getWorkExperienceNFTs(user.ethereumAddress!);

    List<WorkEvent> allEvents = [];

    for (var nft in nftList) {
      final event = await getExperienceEventsFromIpfs(nft);
      allEvents.add(event);
    }

    final groupedStreams = _groupEventsByStream(allEvents);

    final experiences =
        groupedStreams.values.map((stream) => stream.build()).toList();

    return experiences;
  }

  @override
  Future<WorkEvent> getExperienceEventsFromIpfs(dynamic nft) async {
    var ipfsHash = nft[0].toString();
    final event = await _ipfsService.getWorkEvent(ipfsHash);
    return event;
  }

  @override
  Future<List<Certificate>> getCertificatesForCurrentUser() async {
    var user = await _userService.getCurrentUser();
    var certificateNfts =
        await _walletService.getCertificateNFTs(user.ethereumAddress!);
    List<Certificate> certificates = [];

    for (var nft in certificateNfts) {
      await getCertificatesFromIpfs(nft, certificates);
    }

    return certificates;
  }

  getCertificatesFromIpfs(nft, List<Certificate> certificates) async {
    var ipfsHash = nft[0].toString();
    var certificate = await _ipfsService.getCertificate(ipfsHash);
    certificates.add(Certificate.fromIPFSCertificate(certificate));
  }

  @override
  Future<Wallet> createANewWalletAddressForCurrentUser(String password) async {
    try {
      var wallet = await _walletService.createNewWalletAddress(password);
      _userService
          .saveWalletAddressForCurrentUser(wallet.privateKey.address.hex);
      return wallet;
    } catch (e) {
      throw Exception("Could not create wallet");
    }
  }

    @override
  Future<List<CleanExperience>> getEventsForUser(String ethereumAddress) async {
    var nftList =
        await _walletService.getWorkExperienceNFTs(ethereumAddress);

    List<WorkEvent> allEvents = [];

    for (var nft in nftList) {
      final event = await getExperienceEventsFromIpfs(nft);
      allEvents.add(event);
    }

    final groupedStreams = _groupEventsByStream(allEvents);

    final experiences =
        groupedStreams.values.map((stream) => stream.build()).toList();

    return experiences;
  }

  @override
  Future<List<Certificate>> getCertificates(String ethereumAddress) async {
    var certificateNfts =
        await _walletService.getCertificateNFTs(ethereumAddress);
    List<Certificate> certificates = [];

    for (var nft in certificateNfts) {
      await getCertificatesFromIpfs(nft, certificates);
    }

    return certificates;
  }

  Map<String, ExperienceStream> _groupEventsByStream(List<WorkEvent> events) {
    final Map<String, List<WorkEvent>> grouped = {};

    for (var event in events) {
      final dynamicEvent = event as dynamic;
      final streamId = dynamicEvent.experienceStreamId as String;
      grouped.putIfAbsent(streamId, () => []).add(event);
    }

    return grouped.map((streamId, events) => MapEntry(
        streamId, ExperienceStream(streamId: streamId, events: events)));
  }
}
