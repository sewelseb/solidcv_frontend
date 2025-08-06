
class IPFSWorkExperience {
  String? id;
  String? jobTitle;
  String? companyName;
  String? companyId;
  String? companyBlockCahinWalletAddress;
  String? location;
  int? startDate;
  int? endDate;
  String? description;
  int objectVersion = 1;

  IPFSWorkExperience({
    this.id,
    this.jobTitle,
    this.companyName,
    this.companyId,
    this.companyBlockCahinWalletAddress,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
  });

  toJson() {
    return {
      "id": id,
      "jobTitle": jobTitle,
      "companyName": companyName,
      "companyId": companyId,
      "companyBlockCahinWalletAddress": companyBlockCahinWalletAddress,
      "location": location,
      "startDate": startDate,
      "endDate": endDate,
      "description": description,
      "objectVersion": objectVersion,
    };
  }

  static IPFSWorkExperience fromJson(responseData) {
    return IPFSWorkExperience(
      id: responseData['id'],
      jobTitle: responseData['jobTitle'],
      companyName: responseData['companyName'],
      companyId: responseData['companyId'],
      companyBlockCahinWalletAddress: responseData['companyBlockCahinWalletAddress'],
      location: responseData['location'],
      startDate: responseData['startDate'],
      endDate: responseData['endDate'],
      description: responseData['description'],
    );
  }
}