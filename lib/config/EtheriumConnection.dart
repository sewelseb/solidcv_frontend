class EtheriumConnection {
  // String apiUrl = "http://127.0.0.1:8545";
  // String workExperienceSouldboundTokenContractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  
  String apiUrl = "http://localhost:7545";
  String workExperienceSouldboundTokenContractAddress = "0x84207f31cC2eF8F8BB75a95548c2bFCdf2A850B5"; 
  String trainingSouldboundTokenContractAddress = "0x6dDA50bBbc875aF0EDEda9A0c9d86e9aC610324C";

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