import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/EducationInstitutionParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class MyEducationInstitutionAdministration extends StatefulWidget {
  @override
  _MyEducationInstitutionAdministrationState createState() => _MyEducationInstitutionAdministrationState();
}

class _MyEducationInstitutionAdministrationState extends State<MyEducationInstitutionAdministration> {
  IEducationInstitutionBll _educationInstitutionBll = EducationInstitutionBll();
  late Future<EducationInstitution> _educationInstitution;


  @override
  Widget build(BuildContext context) {
    final EducationInstitutionParameter args =
        ModalRoute.of(context)!.settings.arguments as EducationInstitutionParameter;
    _educationInstitution = _educationInstitutionBll.getEducationInstitution(args.id).then((value) {
      return value;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Institution Administration'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: Center(
        child: FutureBuilder<EducationInstitution>(
          future: _educationInstitution,
          builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final educationInstitution = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Text('Name: ${educationInstitution.name}'),
          // Add more fields as necessary
            ],
          );
        } else {
          return Text('No data found');
        }
          },
        ),
      ),
      );
  }
}