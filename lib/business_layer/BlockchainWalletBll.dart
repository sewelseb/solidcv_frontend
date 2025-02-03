import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/data_access_layer/BlockChain/EtheriumWalletService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IIPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:solid_cv/data_access_layer/CompanyService.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainWalletBll extends IBlockchainWalletBll {
  final IWalletService _walletService = EtheriumWalletService();
  final IUserService _userService = UserService();
  final ICompanyService _companyService = CompanyService();
  final IIPFSService _ipfsService = IPFSService();

  @override
  Future<bool> saveWalletAddressForCurrentUser(String address) async {
    if (! await isWalletAddressValid(address)) return false;
    
    // Save the address to the user's profile
    _userService.saveWalletAddressForCurrentUser(address);

    return true;
  }

  Future<bool> isWalletAddressValid(String address) async {
    try {
      var ballance = await _walletService.getBalanceInWei(address);
      return true;
    }
    catch (e) {
      return false;
    }

  }

  @override
  Future<String> createWorkExperienceToken(ExperienceRecord experienceRecord, int companyId, int userId, String password) async {
    var privateKey = await getCompanyPrivateKey(companyId, password);

    //TODO: create the IPFS uri
    var url = await _ipfsService.saveWorkExperience(experienceRecord, companyId);
    
    //TODO: mint the token
    var reciever = await _userService.getUser(userId.toString());
    if (reciever.ethereumAddress == null) {
      throw Exception("User does not have an ethereum address");
    }
    var company = await _companyService.getCompany(companyId); 
    if (company.ethereumAddress == null) {
      throw Exception("Company does not have an ethereum address");
    }
    var tokenAddress = await _walletService.mintWorkExperienceToken(privateKey, company.ethereumAddress!, reciever.ethereumAddress!, url);

    return tokenAddress;
  }

  Future<String> getCompanyPrivateKey(int companyId, String password) async {
    var company = await _companyService.getCompany(companyId);
    const storage = FlutterSecureStorage();
    var encryptedWallet = await storage.read(key: 'etheriumWallet-${company.ethereumAddress!}');
    var wallet = Wallet.fromJson(encryptedWallet!, password);
    return "0x${bytesToHex(wallet.privateKey.privateKey)}";
  }

}