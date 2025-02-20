import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:near_api_dart/near_api_dart.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IWalletService.dart';

class NearWalletService extends IWalletService {
  @override
  Future<String> createWallet() async {
    String rpcURL = 'https://rpc.testnet.near.org';

    Near near = Near();
    JsonRpcProvider rpc = near.providers.jsonRpcProvider(rpcURL);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);

    var transaction = stringToBase64.encode('''
      {
        "signer_id":"test-22-05-1990.testnet",
        "nonce":1,
        "receiver_id":"testnet",
        "actions":
          [
            {"FunctionCall":
              {
                "method_name":"create_account",
                "args":"{
                  "new_account_id": "test_account_id_22-05-1991.testnet",
                  "new_public_key": "ed25519:J6RUNJXBKEGMgpZkwrNCpvvs7nLxTaSa5nKVZz7NvBRp"
                }"
              }
            }
          ]
      }
      ''');
    
    var signature = await signMessage(
      Uint8List.fromList(transaction.codeUnits),
      'test-22-05-1990.testnet',
      'ed25519:J6RUNJXBKEGMgpZkwrNCpvvs7nLxTaSa5nKVZz7NvBRp',
      'testnet',
      'ed25519:3QJvDQsKZ2V4z8vP1t6YqXzj1zQ3rk9v1z1zQ3rk9v12'
    );

    var result = await rpc.sendTransactionAsync(signature.toString());
    return result;
  }

  Future<Signature> signMessage(Uint8List message, String? accountId,
      String? keyPair, String? networkId, String secretKey) async {
    // Hash the message using SHA-256
    var hash = sha256.convert(message).bytes;

    if (accountId == null) {
      throw Exception('InMemorySigner requires provided account id');
    }

    // Retrieve the key pair from the key store
    //var keyPair = await keyStore.getKey(networkId, accountId);
    // if (keyPair! == null) {
    //   throw Exception('Key for $accountId not found in $networkId');
    // }

    final algorithm = Ed25519();

    // Generate a key pair
    final keyPair = await algorithm.newKeyPair();

     final signature = await algorithm.sign(
      hash,
      keyPair: keyPair,
    );

    return signature;
  }
  
  @override
  Future<double> getBalanceInWei(String address) {
    // TODO: implement getBalanceInWei
    throw UnimplementedError();
  }
  
  @override
  Future<String> mintWorkExperienceToken(String privateKey, String sender, String reciever, String tokenUri) {
    // TODO: implement mintWorkExperienceToken
    throw UnimplementedError();
  }
  
  @override
  Future<void> storeKeys(String ethereumAddress, String privateKey, String password) {
    throw UnimplementedError();
  }
  
  @override
  Future getWorkExperienceNFTs(String address) {
    // TODO: implement getWorkExperienceNFTs
    throw UnimplementedError();
  }
  
  @override
  mintCertificateToken(String privateKey, String educationInstitutionEthereumAddress, String recieverEthereumAddress, String url) {
    // TODO: implement mintCertificateToken
    throw UnimplementedError();
  }
  
  @override
  getCertificateNFTs(String address) {
    // TODO: implement getCertificateNFTs
    throw UnimplementedError();
  }
  

}
