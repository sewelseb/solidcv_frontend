import 'package:solid_cv/data_access_layer/BlockChain/NearWalletService.dart';
import 'package:test/test.dart';

void main() {
  
  test('create a wallet is working', () async {
    final walletService = NearWalletService();
    
    final result = await walletService.createWallet();

    expect(result, isNotNull);
  });
}