abstract class IWalletService {
  void createWallet();

  Future<double> getBalanceInWei(String address);
}