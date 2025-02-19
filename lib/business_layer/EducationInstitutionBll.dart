import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/data_access_layer/BlockChain/EtheriumWalletService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:solid_cv/data_access_layer/EducationInstitutionService.dart';
import 'package:solid_cv/data_access_layer/IEducationInstitutionService.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';

class EducationInstitutionBll extends IEducationInstitutionBll {
  final IEducationInstitutionService _educationInstitutionService = EducationInstitutionService();
  final IWalletService _walletService = EtheriumWalletService();
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  

  @override
  Future<List<EducationInstitution>> getMyEducationInstitutions() {
    return _educationInstitutionService.getMyEducationInstitutions();
  }
  
  @override
  void addEducationInstitution(EducationInstitution educationInstitution) {
    _educationInstitutionService.addEducationInstitution(educationInstitution);
  }
  
  @override
  Future<EducationInstitution> getEducationInstitution(int id) {
    return _educationInstitutionService.getEducationInstitution(id);
  }
  
  @override
  setEthereumAddress(EducationInstitution educationInstitution, String ethereumAddress, String privateKey, String password) async {
    if (! await isWalletAddressValid(ethereumAddress)) return false;

    //save the keys on the local device
    _walletService.storeKeys(ethereumAddress, privateKey, password);

    _educationInstitutionService.setEthereumAddress(educationInstitution, ethereumAddress);
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
  void createCertificate(EducationInstitution educationInstitution, User user, Certificate certificate, String password) async {
    var token = await _blockchainWalletBll.createCertificateToken(certificate, user, educationInstitution, password);

    //Save all in the database
  }

}