import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:solid_cv/config/EtheriumConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:web3dart/web3dart.dart';

class EtheriumWalletService implements IWalletService {
  @override
  void createWallet() {}

  Future<double> getBalanceInWei(String walletAddress) async {
    var httpClient = Client();
    var ethClient = Web3Client(EtheriumConnection().apiUrl, httpClient);

    EthereumAddress address = EthereumAddress.fromHex(walletAddress);

    EtherAmount balance = await ethClient.getBalance(address);
    return balance.getValueInUnit(EtherUnit.wei);
  }

  @override
  Future<String> mintWorkExperienceToken(String privateKey, String sender,
      String recieverAddress, String tokenUri) async {
    var httpClient = Client();
    var ethClient = Web3Client(EtheriumConnection().apiUrl, httpClient);

    final credentials = EthPrivateKey.fromHex(privateKey);

    const YOUR_CONTRACT_ABI = '''
[
  {
      "inputs": [
        {
          "internalType": "string",
          "name": "uri",
          "type": "string"
        },
        {
          "internalType": "address",
          "name": "receiver",
          "type": "address"
        }
      ],
      "name": "mint",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
]
''';

    final contract = DeployedContract(
      ContractAbi.fromJson(YOUR_CONTRACT_ABI, 'workExperienceSouldboundToken'),
      EthereumAddress.fromHex(
          EtheriumConnection().workExperienceSouldboundTokenContractAddress),
    );

    final mintFunction = contract.function('mint');

    var ethAddressOfReciever = EthereumAddress.fromHex(recieverAddress);

    print(await ethClient.getNetworkId());

    var result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: mintFunction,
        parameters: [tokenUri, ethAddressOfReciever],
        maxGas: 1000000,
      ),
      chainId: EtheriumConnection().chainId,
    );

    ethClient.dispose();

    return result;
  }

  count(String privateKey) async {
    var httpClient = Client();
    var ethClient = Web3Client(EtheriumConnection().apiUrl, httpClient);

    final credentials = EthPrivateKey.fromHex(privateKey);

    const YOUR_CONTRACT_ABI = '''
[
  {
      "inputs": [],
      "name": "count",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
]
''';

    final contract = DeployedContract(
      ContractAbi.fromJson(YOUR_CONTRACT_ABI, 'workExperienceSouldboundToken'),
      EthereumAddress.fromHex(
          EtheriumConnection().workExperienceSouldboundTokenContractAddress),
    );

    final countFunction = contract.function('count');


    print(await ethClient.getNetworkId());

    var result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: countFunction,
        parameters: [],
        maxGas: 100000,
      ),
      chainId: EtheriumConnection().chainId,
    );

    ethClient.dispose();

    return result;
  }
  
  @override
  Future<void> storeKeys(String ethereumAddress, String privateKey, String password) async {
    var random = Random.secure();
    //TODO: get password from user  
    Wallet wallet = Wallet.createNew(EthPrivateKey.fromHex(privateKey), password, random);

    //Store the wallet in the local storage
    const storage = FlutterSecureStorage();
    await storage.write(key: 'etheriumWallet-$ethereumAddress', value: wallet.toJson());
  }
}
