import 'package:image_picker/image_picker.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/data_access_layer/BlockChain/EtheriumWalletService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:solid_cv/data_access_layer/CompanyService.dart';
import 'package:solid_cv/data_access_layer/ICompanyService.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

class CompanyBll extends ICompanyBll {
  final ICompanyService _companyService = CompanyService();
  final IWalletService _walletService = EtheriumWalletService();
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();

  @override
  Future<Company> createCompany(Company company,XFile? image) {
    return _companyService.createCompany(company, image);
  }

  @override
  Future<Company> deleteCompany(int id) {
    // TODO: implement deleteCompany
    throw UnimplementedError();
  }

  @override
  Future<List<Company>> getCompanies() {
    // TODO: implement getCompanies
    throw UnimplementedError();
  }

  @override
  Future<Company> getCompany(int id) {
    return _companyService.getCompany(id);
  }

  @override
   Future<void> updateCompany(Company company, XFile? image, int id) {
    
    return _companyService.updateCompany(company, image,id);
  }
  
  @override
  Future<List<Company>> getMyCompanies() {
    return _companyService.getMyCompanies();
  }

  @override
  addEmployee(User user, ExperienceRecord experienceRecord, int id, String password) async {
    var token = await _blockchainWalletBll.createWorkExperienceToken(experienceRecord, id, user.id!, password);
    experienceRecord.ethereumToken = token;
    _companyService.addEmployee(user, experienceRecord, id);
  }

  @override
  addEmployeeEvents(User user,WorkEvent event,int companyId,String password) async {
    final token = await _blockchainWalletBll.createWorkEventToken(event,companyId,user.id!,password,
  );
  }
  
  @override
  setEthereumAddress(Company company, String ethereumAddress, String privateKey, String password) async {
    if (! await isWalletAddressValid(ethereumAddress)) return false;

    //save the keys on the local device
    _walletService.storeKeys(ethereumAddress, privateKey, password);
    
    // Save the address to the user's profile
    _companyService.saveWalletAddressForCurrentUser(company, ethereumAddress);

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
  Future<List<Company>> getAllCompanies() {
    return _companyService.getAllCompanies();
  }

  @override
  Future<Company?> fetchCompanyByWallet(String ethereumAddress) {
    return _companyService.fetchCompanyByWallet(ethereumAddress);
  }
}