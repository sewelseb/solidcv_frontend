import 'package:flutter/material.dart';
import 'package:solid_cv/Views/admin-views/AdminBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class AdminInstitutionsPage extends StatefulWidget {
  const AdminInstitutionsPage({super.key});

  @override
  State<AdminInstitutionsPage> createState() => _AdminInstitutionsPageState();
}

class _AdminInstitutionsPageState extends State<AdminInstitutionsPage> {
  final IEducationInstitutionBll _institutionService = EducationInstitutionBll();
  late Future<List<EducationInstitution>> _institutionsFuture;

  @override
  void initState() {
    super.initState();
    _institutionsFuture = _institutionService.getAllInstitutions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎓 All Institutions')),
      bottomNavigationBar: const AdminBottomNavigationBar(),
      body: FutureBuilder<List<EducationInstitution>>(
        future: _institutionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No institutions found."));
          }

          final institutions = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: institutions.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return InstitutionTile(institution: institutions[index]);
            },
          );
        },
      ),
    );
  }
}

class InstitutionTile extends StatelessWidget {
  final EducationInstitution institution;
  const InstitutionTile({super.key, required this.institution});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.school, color: Colors.blue),
        title: Text(institution.name ?? "No name",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(institution.email ?? "-"),
            if (institution.addressCity != null)
              Text("📍 ${institution.addressCity!}", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
