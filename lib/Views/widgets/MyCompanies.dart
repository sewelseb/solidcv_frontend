import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class MyCompanies extends StatefulWidget {
  @override
  _MyCompaniesState createState() => _MyCompaniesState();
}

class _MyCompaniesState extends State<MyCompanies> {
  late Future<List<Company>> companies;
  ICompanyBll _companyBll = CompanyBll();

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
              return ListTile(
                title: Text(company.name!),
              );
            },
          );
        }
      },
    );
  }
}
