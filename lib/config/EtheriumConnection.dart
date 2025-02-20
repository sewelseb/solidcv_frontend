class EtheriumConnection {
  // String apiUrl = "http://127.0.0.1:8545";
  // String workExperienceSouldboundTokenContractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  
  String apiUrl = "http://localhost:7545";
  String workExperienceSouldboundTokenContractAddress = "0x84207f31cC2eF8F8BB75a95548c2bFCdf2A850B5"; 
  String trainingSouldboundTokenContractAddress = "0x57DC6998953FaB661B3EB3f3e2b091b71F9304CF";

  get chainId => 1337;

  String mintWorkExperienceTokenAbi = '''
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

}