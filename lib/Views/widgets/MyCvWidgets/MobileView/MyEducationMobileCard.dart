import 'package:flutter/material.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class EducationMobileCard extends StatefulWidget {
  final Certificate certificate;
  final bool isValidated;
  final VoidCallback? onCertificateDeleted; // Add this callback

  const EducationMobileCard({
    super.key,
    required this.certificate,
    required this.isValidated,
    this.onCertificateDeleted, // Add this parameter
  });

  @override
  State<EducationMobileCard> createState() => _EducationMobileCardState();
}

class _EducationMobileCardState extends State<EducationMobileCard> {
  final IUserBLL _userBLL = UserBll();

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = widget.isValidated ? Colors.green : Colors.deepPurple;
    final String badgeLabel = widget.isValidated ? 'Verified by the Blockchain' : 'Manually added';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isValidated ? Icons.verified : Icons.edit,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      widget.certificate.logoUrl ??
                          '${BackenConnection().url}${BackenConnection().imageAssetFolder}education-institution.png',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.certificate.title ?? 'Untitled',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.certificate.type ?? 'Certificate',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    if (widget.certificate.publicationDate != null)
                      Text(
                        'Date: ${FormatDate().formatDateForCertificate(widget.certificate.publicationDate!)}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    const SizedBox(height: 4),
                    if (widget.certificate.teachingInstitutionName != null)
                      Row(
                        children: [
                          const Icon(Icons.school,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.certificate.teachingInstitutionName!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.certificate.description != null &&
              widget.certificate.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.certificate.description!,
              style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            ),
          ],
          if (widget.certificate.curriculum != null &&
              widget.certificate.curriculum!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Curriculum: ${widget.certificate.curriculum!}',
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
          ],
          if (widget.certificate.grade != null && widget.certificate.grade!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Grade: ${widget.certificate.grade!}',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
          if (!widget.isValidated)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, int.parse(widget.certificate.id!)),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int manualExperienceId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this certificate? This action is irreversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  _userBLL.deleteManualyAddedCertificate(manualExperienceId);
                  Navigator.of(context).pop();
                  
                  widget.onCertificateDeleted!();

                } catch (e) {
                  Navigator.of(context).pop();
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting certificate: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration glassCardDecoration() => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B3FE4).withOpacity(0.18),
          width: 1.4,
        ),
      );
}
