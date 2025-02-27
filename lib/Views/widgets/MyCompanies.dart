import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class MyCompanies extends StatefulWidget {
  const MyCompanies({super.key});

  @override
  _MyCompaniesState createState() => _MyCompaniesState();
}

class _MyCompaniesState extends State<MyCompanies> {
  late Future<List<Company>> companies;
  final ICompanyBll _companyBll = CompanyBll();

  @override
  void initState() {
    super.initState();
    companies = _companyBll.getMyCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Company>>(
      future: companies,
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
                    "/my-company-administration",
                    arguments: CompanyParameter(id: company.id!),
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
