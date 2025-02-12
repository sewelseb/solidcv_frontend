import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:solid_cv/config/EtheriumConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';
import 'package:web3dart/web3dart.dart';

class EtheriumWalletService implements IWalletService {
  @override
  void createWallet() {}

  @override
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

    const mintWorkExperienceTokenAbi = '''
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
      ContractAbi.fromJson(
          mintWorkExperienceTokenAbi, 'workExperienceSouldboundToken'),
      EthereumAddress.fromHex(
          EtheriumConnection().workExperienceSouldboundTokenContractAddress),
    );

    final mintFunction = contract.function('mint');

    var ethAddressOfReciever = EthereumAddress.fromHex(recieverAddress);

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

    const yourContractAbi = '''
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
      ContractAbi.fromJson(yourContractAbi, 'workExperienceSouldboundToken'),
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
  Future<void> storeKeys(
      String ethereumAddress, String privateKey, String password) async {
    var random = Random.secure();
    //TODO: get password from user
    Wallet wallet =
        Wallet.createNew(EthPrivateKey.fromHex(privateKey), password, random);

    //Store the wallet in the local storage
    const storage = FlutterSecureStorage();
    await storage.write(
        key: 'etheriumWallet-$ethereumAddress', value: wallet.toJson());
  }

  @override
  Future getWorkExperienceNFTs(String address) async {
    var httpClient = Client();
    var ethClient = Web3Client(EtheriumConnection().apiUrl, httpClient);

    const getNFTsAbi = '''
  [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "tokensOfOwner",
      "outputs": [
        {
          "components": [
            {
              "internalType": "string",
              "name": "uri",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "timestamp",
              "type": "uint256"
            }
          ],
          "internalType": "struct WorkExperienceSouldboundToken.TokenData[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';

    final contract = DeployedContract(
      ContractAbi.fromJson(getNFTsAbi, 'tokensOfOwner'),
      EthereumAddress.fromHex(
          EtheriumConnection().workExperienceSouldboundTokenContractAddress),
    );

    final tokensOfOwnerFunction = contract.function('tokensOfOwner');

    final result = await ethClient.call(
      contract: contract,
      function: tokensOfOwnerFunction,
      params: [EthereumAddress.fromHex(address)],
    );

    ethClient.dispose();

    return result.first as List<dynamic>;
  }
}
