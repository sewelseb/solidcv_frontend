import 'package:flutter/material.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/models/Certificate.dart';

class EducationCard extends StatelessWidget {
  final Certificate certificate;
  final bool isValidated;

  const EducationCard({
    Key? key,
    required this.certificate,
    required this.isValidated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isValidated ? Colors.green : Colors.deepPurple;
    final String badgeLabel =
        isValidated ? 'Verified by the blockchain' : 'Manually added';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      certificate.logoUrl ??
                          '${BackenConnection().url}${BackenConnection().imageAssetFolder}education-institution.png',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.title ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      certificate.type ?? 'Certificate',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (certificate.publicationDate != null)
                      Text(
                        'Date: ${formatDate(certificate.publicationDate!)}',
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
                          Text(
                            certificate.teachingInstitutionName!,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                  // const SizedBox(height: 8),
                  // TextButton(
                  //   onPressed: () {}, // TODO: Implement details modal
                  //   style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                  //   child: const Text('View details'),
                  // ),
                ],
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

  BoxDecoration glassCardDecoration() => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B3FE4).withOpacity(0.18),
          width: 1.4,
        ),
      );

  String formatDate(String? input) {
    try {
      if (input == null || input.isEmpty) return 'Date inconnue';
      final micros = int.parse(input);
      final date = DateTime.fromMicrosecondsSinceEpoch(micros);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Date invalide';
    }
  }
}
