abstract class IWalletService {
  void createWallet();

  Future<double> getBalanceInWei(String address);

  Future<String> mintWorkExperienceToken(String privateKey, String sender, String reciever, String tokenUri);

  Future<void> storeKeys(String ethereumAddress, String privateKey, String password);

  Future getWorkExperienceNFTs(String address);

  mintCertificateToken(String privateKey, String educationInstitutionEthereumAddress, String recieverEthereumAddress, String url);

  getCertificateNFTs(String address);
}