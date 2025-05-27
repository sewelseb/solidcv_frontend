import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class WorkExperienceCard extends StatefulWidget {
  final UnifiedExperienceViewModel experience;
  final VoidCallback? onPromotionAdded;

  const WorkExperienceCard({
    super.key,
    required this.experience,
    this.onPromotionAdded,
  });

  @override
  State<WorkExperienceCard> createState() => _WorkExperienceCardState();
}

class _WorkExperienceCardState extends State<WorkExperienceCard> {
  late final String _startFormatted;
  late final String _endFormatted;
  late final List<Widget> _promotionWidgets;
  late final bool _isVerified;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.experience.isVerified;
    _startFormatted = _formatDate(widget.experience.startDate);
    _endFormatted = _formatDate(widget.experience.endDate);
    _promotionWidgets = widget.experience.promotions.map((p) {
      final date = DateTime.fromMillisecondsSinceEpoch(p.date);
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          '🔹 ${p.newTitle} – $formattedDate',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final exp = widget.experience;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: const Color(0xFFF0F8FF),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 450;

            return Column(
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
                            exp.company,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exp.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isSmallScreen) _buildActionBar(context),
                  ],
                ),
                if (isSmallScreen)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: _buildActionBar(context),
                  ),
                Text(
                  '$_startFormatted - $_endFormatted',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (_promotionWidgets.isNotEmpty) ...[
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
                  ..._promotionWidgets,
                ],
                if (exp.description?.isNotEmpty ?? false) ...[
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    exp.description!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        if (!_isVerified)
          TextButton(
            onPressed: () =>
                _showAddPromotionDialog(context, widget.experience.manualId!),
            child: const Text(
              '+ Ajouter une promotion',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _isVerified ? Colors.green : Colors.deepPurple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isVerified ? Icons.verified : Icons.edit,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                _isVerified ? 'Verified' : 'Manual',
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
                  _userBLL.addManuallyPromotion(promotion, manualExperienceId);
                  Navigator.of(context).pop();
                  if (widget.onPromotionAdded != null) {
                    widget.onPromotionAdded!();
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

  String _formatDate(int? millis) {
    if (millis == null) return 'Ongoing';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day}/${date.month}/${date.year}';
  }
}
