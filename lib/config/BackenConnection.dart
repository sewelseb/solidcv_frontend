class BackenConnection {
  String url = 'https://localhost:8000';
  String registerApi = '/api/register';

  String get loginApi => '/api/login';

  String get createCompanyApi => '/api/protected/create-company';
}