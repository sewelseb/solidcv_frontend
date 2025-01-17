import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/data_access_layer/BlockChain/EtheriumWalletService.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:solid_cv/data_access_layer/IUserService.dart';
import 'package:solid_cv/data_access_layer/UserService.dart';

class BlockchainWalletBll extends IBlockchainWalletBll {
  final IWalletService _walletService = EtheriumWalletService();
  final IUserService _userService = UserService();

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

}