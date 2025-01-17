import 'package:http/http.dart';
import 'package:solid_cv/config/EtheriumConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:web3dart/web3dart.dart';

class EtheriumWalletService implements IWalletService {
  @override
  void createWallet() {
    
  }

  Future<double> getBalanceInWei(String walletAddress) async {
    var httpClient = Client();
    var ethClient = Web3Client(EtheriumConnection().apiUrl, httpClient);

    EthereumAddress address = EthereumAddress.fromHex(walletAddress);

    EtherAmount balance = await ethClient.getBalance(address);
    return balance.getValueInUnit(EtherUnit.wei);
  }

}