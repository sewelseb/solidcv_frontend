import 'package:flutter/material.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/glassCardDecoration.dart';
import 'package:solid_cv/Views/components/VerificationBadge.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/models/Certificate.dart';

class UserVerifyCvEducationMobileCard extends StatelessWidget {
  final Certificate certificate;
  final bool isValidated;

  const UserVerifyCvEducationMobileCard({
    super.key,
    required this.certificate,
    required this.isValidated,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isValidated ? Colors.green : Colors.deepPurple;
    final String badgeLabel = isValidated ? 'Verified' : 'Manually';

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
                  isValidated ? Icons.verified : Icons.edit,
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
              Stack(
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
                          certificate.logoUrl ??
                              '${BackenConnection().url}${BackenConnection().imageAssetFolder}education-institution.png',
                        ),
                      ),
                    ),
                  ),
                  if (isValidated && (certificate.isInstitutionVerified ?? false))
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: VerificationBadge(
                        isVerified: true,
                        size: 16,
                        entityType: 'institution',
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.title ?? 'Untitled',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      certificate.type ?? 'Certificate',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    if (certificate.publicationDate != null)
                      Text(
                        'Date: ${FormatDate().formatDateForCertificate(certificate.publicationDate!)}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    const SizedBox(height: 4),
                    if (certificate.teachingInstitutionName != null)
                      Row(
                        children: [
                          const Icon(Icons.school,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              certificate.teachingInstitutionName!,
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
          if (certificate.description != null &&
              certificate.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              certificate.description!,
              style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            ),
          ],
          if (certificate.curriculum != null &&
              certificate.curriculum!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Curriculum: ${certificate.curriculum!}',
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
          ],
          if (certificate.grade != null && certificate.grade!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Grade: ${certificate.grade!}',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

}
