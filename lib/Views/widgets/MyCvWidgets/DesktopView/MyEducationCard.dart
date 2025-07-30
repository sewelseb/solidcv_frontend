import 'package:flutter/material.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/glassCardDecoration.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/models/Certificate.dart';

class EducationCard extends StatefulWidget {
  final Certificate certificate;
  final bool isValidated;
  final VoidCallback? onCertificateDeleted; // Add this callback

  const EducationCard({
    Key? key,
    required this.certificate,
    required this.isValidated,
    this.onCertificateDeleted, // Add this parameter
  }) : super(key: key);

  @override
  State<EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<EducationCard> {
  final IUserBLL _userBLL = UserBll();

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = widget.isValidated ? Colors.green : Colors.deepPurple;
    final String badgeLabel =
        widget.isValidated ? 'Verified by the blockchain' : 'Manually added';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: glassCardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow) _buildBadge(badgeColor, badgeLabel),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 15),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.certificate.title ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.certificate.type ?? 'Certificate',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (widget.certificate.publicationDate != null)
                                    Text(
                                      'Date: ${FormatDate().formatDateForCertificate(widget.certificate.publicationDate!)}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  const SizedBox(height: 4),
                                  if (widget.certificate.teachingInstitutionName !=
                                      null)
                                    Row(
                                      children: [
                                        const Icon(Icons.school,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            widget.certificate.teachingInstitutionName!,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (!isNarrow)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: _buildBadge(badgeColor, badgeLabel),
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
                  style:
                      const TextStyle(fontSize: 14.5, color: Colors.black87),
                ),
              ],
              if (widget.certificate.curriculum != null &&
                  widget.certificate.curriculum!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Curriculum: ${widget.certificate.curriculum!}',
                  style:
                      const TextStyle(fontSize: 13.5, color: Colors.black87),
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
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(Color color, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label.contains('Verified') ? Icons.verified : Icons.edit,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
                _userBLL.deleteManualyAddedCertificate(manualExperienceId);
                Navigator.of(context).pop();
                // Trigger parent refresh
                if (widget.onCertificateDeleted != null) {
                  widget.onCertificateDeleted!();
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
}
