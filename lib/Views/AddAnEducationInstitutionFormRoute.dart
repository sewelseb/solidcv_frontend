import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class AddanEducationInstitutionFormRoute  extends StatefulWidget {
  const AddanEducationInstitutionFormRoute({super.key});

  @override
  _AddanEducationInstitutionFormRouteState createState() => _AddanEducationInstitutionFormRouteState();
}

class _AddanEducationInstitutionFormRouteState extends State<AddanEducationInstitutionFormRoute> {
  final IEducationInstitutionBll _educationInstitutionBll = EducationInstitutionBll();
  final _educationInstitutionNameController = TextEditingController();
  final _addressNumberController = TextEditingController();
  final _addressStreetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _educationInstitutionNameController.dispose();
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
        title: const Text('Add an Education Institution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Education Institution Name',
                ),
                controller: _educationInstitutionNameController,
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
                  labelText: 'Phone number',
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
                  onPressed: () {
                    // Add your education institution addition logic here
                    var educationInstitution = EducationInstitution(
                      name: _educationInstitutionNameController.text,
                      addressNumber: _addressNumberController.text,
                      addressStreet: _addressStreetController.text,
                      addressCity: _cityController.text,
                      addressZipCode: _zipCodeController.text,
                      addressCountry: _countryController.text,
                      phoneNumber: _phoneNumberController.text,
                      email: _emailController.text,
                    );
                    _educationInstitutionBll.addEducationInstitution(educationInstitution);
                    Navigator.pop(context);
                  },
                  child: const Text('Add Education Institution'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

