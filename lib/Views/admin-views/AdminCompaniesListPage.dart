import 'package:flutter/material.dart';
import 'package:solid_cv/Views/admin-views/AdminBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class AdminCompaniesPage extends StatefulWidget {
  const AdminCompaniesPage({super.key});

  @override
  State<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends State<AdminCompaniesPage> {
  final ICompanyBll _companyService = CompanyBll();
  late Future<List<Company>> _companiesFuture;

  @override
  void initState() {
    super.initState();
    _companiesFuture = _companyService.getAllCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏢 All Companies')),
      bottomNavigationBar: const AdminBottomNavigationBar(),
      body: FutureBuilder<List<Company>>(
        future: _companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No companies found."));
          }

          final companies = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: companies.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return CompanyTile(company: companies[index]);
            },
          );
        },
      ),
    );
  }
}

class CompanyTile extends StatelessWidget {
  final Company company;
  const CompanyTile({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.business, color: Colors.indigo),
        title: Text(company.name ?? "No name",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company.email ?? "-"),
            if (company.addressCity != null)
              Text("📍 ${company.addressCity!}", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
