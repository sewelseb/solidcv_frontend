import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class WorkExperienceCard extends StatelessWidget {
  final UnifiedExperienceViewModel experience;
  final VoidCallback? onPromotionAdded;

  const WorkExperienceCard({
    super.key,
    required this.experience,
    this.onPromotionAdded,
  });

  String _formatDate(int? millis) {
    if (millis == null) return 'Ongoing';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = experience.title;
    final company = experience.company;
    final description = experience.description ?? '';
    final start = _formatDate(experience.startDate);
    final end = _formatDate(experience.endDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: const Color(0xFFF0F8FF),
      elevation: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                const SizedBox(height: 4),
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
                  '$start - $end',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (experience.promotions.isNotEmpty) ...[
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
                  ...experience.promotions.map((p) {
                    final date = DateTime.fromMillisecondsSinceEpoch(p.date);
                    final formattedDate =
                        '${date.day}/${date.month}/${date.year}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '🔹 ${p.newTitle} – $formattedDate',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                ],
                if (description.isNotEmpty) ...[
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
          // Label & Add promotion button
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!experience.isVerified)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () {
                        _showAddPromotionDialog(context, experience.manualId!);
                      },
                      child: const Text(
                        '+ Ajouter une promotion',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: experience.isVerified
                        ? Colors.green
                        : Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        experience.isVerified ? Icons.verified : Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        experience.isVerified
                            ? 'Verified by the blockchain'
                            : 'Manual',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPromotionDialog(BuildContext context, int manualExperienceId) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une promotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Titre de promotion'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    dateController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty && selectedDate != null) {
                  final promotion = Promotion(
                    newTitle: newTitle,
                    date: selectedDate!.millisecondsSinceEpoch ~/ 1000,
                  );
                  var _userBLL = UserBll();
                   _userBLL.addManuallyPromotion(
                      promotion, manualExperienceId);
                  Navigator.of(context).pop();
                  if (onPromotionAdded != null) {
                    onPromotionAdded!();
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
