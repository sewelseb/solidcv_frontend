import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class MyCompanyAdministration extends StatefulWidget {
  const MyCompanyAdministration({super.key});

  @override
  State<MyCompanyAdministration> createState() =>
      _MyCompanyAdministrationState();
}

class _MyCompanyAdministrationState extends State<MyCompanyAdministration> {
  final ICompanyBll _companyBll = CompanyBll();
  late Future<Company> _company;
  final TextEditingController _ethereumAddressController =
      TextEditingController();
  final TextEditingController _ethereumPrivateKeyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final CompanyParameter args =
        ModalRoute.of(context)!.settings.arguments as CompanyParameter;
    _company = _companyBll.getCompany(args.id).then((value) {
      _ethereumAddressController.text = value.ethereumAddress ?? '';
      return value;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Administration'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: FutureBuilder<Company>(
        future: _company,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final company = snapshot.data!;
            return ListView(
              shrinkWrap: true,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company Information',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Name: ${company.name}'),
                        Text('Address: ${company.getFullAddress()}'),
                        Text('Phone: ${company.phoneNumber}'),
                      ],
                    ),
                  ),
                ),
                //add a panel with a form to set the company ethereum address
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ethereum Address',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Ethereum Address',
                            border: OutlineInputBorder(),
                          ),
                          controller: _ethereumAddressController,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Ethereum Private key',
                            border: OutlineInputBorder(),
                          ),
                          controller: _ethereumPrivateKeyController,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                            'This is the Ethereum address that will be used to mint tokens for your employees. We don\'t store your private key on our server, it is stored on your device so make sure to keep it safe.'),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                            'This password will be used to encrypt your private key. Make sure to remember it. (there is no way to recover it)'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await _companyBll.setEthereumAddress(
                                company, _ethereumAddressController.text, _ethereumPrivateKeyController.text, _passwordController.text);
                            setState(() {});
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Employees',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        //button to add an employee
                        ElevatedButton(
                          onPressed: () {
                            var args = CompanyParameter(id: company.id!);
                            Navigator.pushNamed(
                                context, '/company/add-an-employee',
                                arguments: args);
                          },
                          child: const Text('+ Add Employee'),
                        ),
            
                        // const SizedBox(height: 10),
                        // ...company.employees.map((employee) => Text('Employee: ${employee.name}')).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
