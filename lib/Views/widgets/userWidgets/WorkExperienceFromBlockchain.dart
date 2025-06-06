import 'package:flutter/material.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';

class WorkExperienceFromBlockchain extends StatelessWidget {
  final CleanExperience workExperience;

  const WorkExperienceFromBlockchain({
    Key? key,
    required this.workExperience,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = workExperience.title ?? '';
    final company = workExperience.companyName ?? '';
    final description = workExperience.description ?? '';
    final startDate = _formatDate(workExperience.startDate);
    final endDate = _formatDate(workExperience.endDate);
    final hasPromotions = workExperience.promotions.isNotEmpty;

    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$startDate - $endDate',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (hasPromotions) ...[
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    '📈 Promotions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...workExperience.promotions.map((p) {
                    final date = DateTime.fromMillisecondsSinceEpoch(p.date);
                    final formattedDate =
                        '${date.day}/${date.month}/${date.year}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '🔹 ${p.newTitle} – $formattedDate',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                ],
                if (description.isNotEmpty) ...[
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Verified',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(int? millis) {
    if (millis == null) return 'Ongoing';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day}/${date.month}/${date.year}';
  }
}
