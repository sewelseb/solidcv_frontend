import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/EducationInstitutionParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class MyEducationInstitutionAdministration extends StatefulWidget {
  @override
  _MyEducationInstitutionAdministrationState createState() =>
      _MyEducationInstitutionAdministrationState();
}

class _MyEducationInstitutionAdministrationState
    extends State<MyEducationInstitutionAdministration> {
  final IEducationInstitutionBll _educationInstitutionBll = EducationInstitutionBll();
  late Future<EducationInstitution> _educationInstitution;

  final TextEditingController _ethereumAddressController =
      TextEditingController();
  final TextEditingController _ethereumPrivateKeyController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final EducationInstitutionParameter args = ModalRoute.of(context)!
        .settings
        .arguments as EducationInstitutionParameter;
    _educationInstitution =
        _educationInstitutionBll.getEducationInstitution(args.id).then((value) {
      _ethereumAddressController.text = value.ethereumAddress ?? '';
      return value;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Institution Administration'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: FutureBuilder<EducationInstitution>(
        future: _educationInstitution,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final educationInstitution = snapshot.data!;
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
                          'Education Institution Information',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Name: ${educationInstitution.name}'),
                        Text(
                            'Address: ${educationInstitution.getFullAddress()}'),
                        Text('Phone: ${educationInstitution.phoneNumber}'),
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
                            'This is the Ethereum address that will be used to mint tokens for your certificates and diplomas. We don\'t store your private key on our server, it is stored on your device so make sure to keep it safe.'),
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
                            await _educationInstitutionBll.setEthereumAddress(
                                educationInstitution,
                                _ethereumAddressController.text,
                                _ethereumPrivateKeyController.text,
                                _passwordController.text);
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
                          'Trainees and Students',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        //button to add an employee
                        ElevatedButton(
                          onPressed: () {
                            var args = EducationInstitutionParameter(
                                id: educationInstitution.id!);
                            Navigator.pushNamed(context,
                                '/educationInstitution/add-a-certificate-to-user',
                                arguments: args);
                          },
                          child: const Text('+ Add Certificates to User'),
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
            return Text('No data found');
          }
        },
      ),
    );
  }
}
