import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/EducationInstitutionParameter.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class MyEducationInstitutions extends StatefulWidget {
  const MyEducationInstitutions({super.key});

  @override
  _MyEducationInstitutionsState createState() => _MyEducationInstitutionsState();
}

class _MyEducationInstitutionsState extends State<MyEducationInstitutions> {
  late Future<List<EducationInstitution>> educationinstitutions;
  final IEducationInstitutionBll _educationInstitutionBll = EducationInstitutionBll();

  @override
  void initState() {
    super.initState();
    educationinstitutions = _educationInstitutionBll.getMyEducationInstitutions();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EducationInstitution>>(
      future: educationinstitutions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No companies found.'));
        } else {
            return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final company = snapshot.data![index];
              return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: Icon(Icons.business, color: Theme.of(context).primaryColor),
                title: Text(
                company.name!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor),
                onTap: () {
                // Handle onTap event if needed
                  Navigator.pushNamed(
                    context,
                    "/my-educationInstitution-administration",
                    arguments: EducationInstitutionParameter(id: company.id!),
                  );
                },
              ),
              );
            },
            );
        }
      },
    );
  }

  
}