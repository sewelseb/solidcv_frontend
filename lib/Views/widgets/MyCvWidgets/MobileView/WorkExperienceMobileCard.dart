import 'package:flutter/material.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class WorkExperienceCardMobile extends StatelessWidget {
  final UnifiedExperienceViewModel experience;
  final VoidCallback? onPromotionAdded;

  const WorkExperienceCardMobile({
    super.key,
    required this.experience,
    this.onPromotionAdded,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = experience.isVerified;
    final start = _formatDate(experience.startDate);
    final end = _formatDate(experience.endDate);
    final hasPromotions = experience.promotions.isNotEmpty;
    final logoUrl = (experience.companyLogoUrl?.isNotEmpty ?? false)
        ? experience.companyLogoUrl!
        : '${BackenConnection().url}${BackenConnection().imageAssetFolder}company.png';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green : Colors.deepPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified : Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Verified' : 'Manually',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          experience.company,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$start - $end',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_pin,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                experience.location ?? '',
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
            ],
          ),
          if (hasPromotions) ...[
            const SizedBox(height: 16),
            ...experience.promotions.map((p) {
              final date = DateTime.fromMillisecondsSinceEpoch(p.date);
              return Text(
                '• ${p.newTitle} – ${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontSize: 14),
              );
            }),
          ],
          if (experience.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Text(
              experience.description!,
              style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            ),
          ],
          if (!isVerified)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    _showAddPromotionDialog(context, experience.manualId!),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                child: const Text('Add a promotion'),
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
                    date: selectedDate!.millisecondsSinceEpoch,
                  );
                  var userBLL = UserBll();
                  userBLL.addManuallyPromotion(promotion, manualExperienceId);
                  Navigator.of(context).pop();
                  if (onPromotionAdded != null) onPromotionAdded!();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(int? millis) {
    if (millis == null) return 'Ongoing';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day}/${date.month}/${date.year}';
  }

  BoxDecoration glassCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF7B3FE4).withOpacity(0.18),
        width: 1.4,
      ),
    );
  }
}
