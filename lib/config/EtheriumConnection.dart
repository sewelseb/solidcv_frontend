class EtheriumConnection {
  // String apiUrl = "http://127.0.0.1:8545";
  // String workExperienceSouldboundTokenContractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  
  String apiUrl = "http://localhost:7545";
  String workExperienceSouldboundTokenContractAddress = "0x452100546A3255bc647E4E705E25397412b6f7E9";

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