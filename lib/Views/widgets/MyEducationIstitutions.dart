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
          return const Center(child: Text('No education institutions found.'));
        } else {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 110,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 16,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final institution = snapshot.data![index];
                  return _InstitutionCard(institution: institution);
                },
              ),
            ),
          );
        }
      },
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  final EducationInstitution institution;
  const _InstitutionCard({required this.institution});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(
          context,
          "/my-educationInstitution-administration",
          arguments: EducationInstitutionParameter(id: institution.id!),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: Colors.white,
        child: Row(
          children: [
            const SizedBox(width: 18),
            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.deepPurple.shade50,
              backgroundImage: NetworkImage(institution.getProfilePicture()),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institution.name ?? "Unnamed Institution",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    institution.getFullAddress() ?? "",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  if (institution.email != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.5),
                      child: Text(
                        institution.email!,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black38),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF7B3FE4), size: 23),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
