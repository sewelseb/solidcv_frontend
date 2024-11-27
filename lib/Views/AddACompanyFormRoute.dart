import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class AddACompanyFormRoute extends StatefulWidget {
  @override
  _AddACompanyFormRouteState createState() => _AddACompanyFormRouteState();
}

class _AddACompanyFormRouteState extends State<AddACompanyFormRoute> {
  final ICompanyBll _companyBll = CompanyBll();
  final _companyNameController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressStreetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressNumberController.dispose();
    _addressStreetController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Company'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                ),
                controller: _companyNameController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Address number',
                ),
                controller: _addressNumberController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Address street',
                ),
                controller: _addressStreetController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'City',
                ),
                controller: _cityController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Zip code',
                ),
                controller: _zipCodeController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Country',
                ),
                controller: _countryController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                controller: _phoneNumberController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                controller: _emailController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate the form
                    
                    var company = Company(
                      id: null,
                      name: _companyNameController.text,
                      addressNumber: _addressNumberController.text,
                      addressStreet: _addressStreetController.text,
                      addressCity: _cityController.text,
                      addressZipCode: _zipCodeController.text,
                      addressCountry: _countryController.text,
                      phoneNumber: _phoneNumberController.text,
                      email: _emailController.text,
                    );
                    await _companyBll.createCompany(company);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
