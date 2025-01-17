class BackenConnection {
  String url = 'https://localhost:8000';
  String registerApi = '/api/register';

  String get loginApi => '/api/login';

  String get createCompanyApi => '/api/protected/create-company';

  String get getMyCompaniesApi => '/api/protected/get-my-companies';

  String get getCompanyApi => '/api/protected/get-company/';

  String get getMyEducationInstitutionsApi => "/api/protected/get-my-education-institutions";

  String get addEducationInstitutionApi => "/api/protected/create-education-institution";

  String get searchUsersApi => "/api/protected/search-user";

  String get addEmployeeApi => "/api/protected/add-an-employee";

  String get saveWalletAddressApi => "/api/protected/set-ethereum-wallet";

  String get getCurrentUserApi => "/api/protected/get-current-user";
}