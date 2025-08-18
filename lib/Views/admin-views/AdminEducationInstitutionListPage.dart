import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/admin-views/AdminBottomNavigationBar.dart';
import 'package:solid_cv/Views/admin-views/AdminEducationInstitutionViewPage.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7B3FE4),
          child: institution.getProfilePicture().isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    institution.getProfilePicture(),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 20,
                ),
        ),
        title: Text(
          institution.name ?? "No name",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    institution.email ?? "No email",
                    style: GoogleFonts.inter(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (institution.addressCity != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      institution.addressCity!,
                      style: GoogleFonts.inter(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.tag, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'ID: ${institution.id}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Institution type indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getInstitutionTypeColor(institution),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getInstitutionType(institution),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getInstitutionTypeTextColor(institution),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Blockchain status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (institution.ethereumAddress != null && institution.ethereumAddress!.isNotEmpty)
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (institution.ethereumAddress != null && institution.ethereumAddress!.isNotEmpty)
                        ? 'Blockchain ✓'
                        : 'No Blockchain',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: (institution.ethereumAddress != null && institution.ethereumAddress!.isNotEmpty)
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          height: 32,
          child: ElevatedButton(
            onPressed: () => _viewInstitutionDetails(context, institution),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B3FE4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _viewInstitutionDetails(BuildContext context, EducationInstitution institution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEducationInstitutionViewPage(institutionId: institution.id.toString()),
      ),
    );
  }

  String _getInstitutionType(EducationInstitution institution) {
    final name = institution.name?.toLowerCase() ?? '';
    if (name.contains('university')) return 'University';
    if (name.contains('college')) return 'College';
    if (name.contains('school')) return 'School';
    if (name.contains('academy')) return 'Academy';
    if (name.contains('institute')) return 'Institute';
    return 'Institution';
  }

  Color _getInstitutionTypeColor(EducationInstitution institution) {
    final type = _getInstitutionType(institution);
    switch (type) {
      case 'University':
        return Colors.purple.shade100;
      case 'College':
        return Colors.blue.shade100;
      case 'School':
        return Colors.green.shade100;
      case 'Academy':
        return Colors.orange.shade100;
      case 'Institute':
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getInstitutionTypeTextColor(EducationInstitution institution) {
    final type = _getInstitutionType(institution);
    switch (type) {
      case 'University':
        return Colors.purple.shade700;
      case 'College':
        return Colors.blue.shade700;
      case 'School':
        return Colors.green.shade700;
      case 'Academy':
        return Colors.orange.shade700;
      case 'Institute':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
