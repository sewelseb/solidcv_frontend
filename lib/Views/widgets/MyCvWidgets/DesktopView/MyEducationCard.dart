import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/glassCardDecoration.dart';
import 'package:solid_cv/Views/components/VerificationBadge.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/Views/widgets/AddManuallyCertificateDialog.dart';

class EducationCard extends StatefulWidget {
  final Certificate certificate;
  final bool isValidated;
  final VoidCallback? onCertificateDeleted; // Add this callback

  const EducationCard({
    super.key,
    required this.certificate,
    required this.isValidated,
    this.onCertificateDeleted, // Add this parameter
  });

  @override
  State<EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<EducationCard> {
  final IUserBLL _userBLL = UserBll();

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = widget.isValidated ? Colors.green : Colors.deepPurple;
    final String badgeLabel =
        widget.isValidated ? AppLocalizations.of(context)!.verifiedByBlockchain : AppLocalizations.of(context)!.manuallyAdded;

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
                  Stack(
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
                      if (widget.isValidated && (widget.certificate.isInstitutionVerified ?? false))
                        Positioned(
                          right: 11,
                          bottom: -2,
                          child: VerificationBadge(
                            isVerified: true,
                            size: 16,
                            entityType: 'institution',
                          ),
                        ),
                    ],
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
                                    widget.certificate.title ?? AppLocalizations.of(context)!.untitled,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.certificate.type ?? AppLocalizations.of(context)!.certificate,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (widget.certificate.publicationDate != null)
                                    Text(
                                      '${AppLocalizations.of(context)!.date}: ${FormatDate().formatDateForCertificate(context, widget.certificate.publicationDate!)}',
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
                  '${AppLocalizations.of(context)!.curriculum}: ${widget.certificate.curriculum!}',
                  style:
                      const TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
              ],
              if (widget.certificate.grade != null && widget.certificate.grade!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '${AppLocalizations.of(context)!.grade}: ${widget.certificate.grade!}',
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
                      // Edit pencil icon
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.editProfile,
                        icon: const Icon(Icons.edit, color: Colors.black87),
                        onPressed: () async {
                          await AddManuallyCertificateDialog.show(
                            context,
                            initial: widget.certificate,
                            onAdd: (updated) async {
                              _userBLL.updateManuallyAddedCertificate(updated);
                              if (widget.onCertificateDeleted != null) {
                                // reuse callback to trigger reload in parent
                                widget.onCertificateDeleted!();
                              }
                            },
                          );
                        },
                      ),
                      // Delete as red trash icon
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.delete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(
                          context,
                          int.parse(widget.certificate.id!),
                        ),
                      ),
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
          title: Text(AppLocalizations.of(context)!.confirmDeletion),
          content: Text(AppLocalizations.of(context)!.deleteCertificateConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
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
              child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
