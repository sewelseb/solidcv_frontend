import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/glassCardDecoration.dart';
import 'package:solid_cv/Views/components/VerificationBadge.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

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
  final IUserBLL _userBLL = UserBll();

  @override
  Widget build(BuildContext context) {
    final isVerified = widget.experience.isVerified;
    final start = FormatDate().formatDateForExperience(context, widget.experience.startDate);
    final end = FormatDate().formatDateForExperience(context, widget.experience.endDate);
    final hasPromotions = widget.experience.promotions.isNotEmpty;
    final logoUrl = (widget.experience.companyLogoUrl?.isNotEmpty ?? false)
        ? widget.experience.companyLogoUrl!
        : '${BackenConnection().url}${BackenConnection().imageAssetFolder}company.png';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: glassCardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow) _buildBadge(isVerified),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isVerified && (widget.experience.isCompanyVerified ?? false))
                        Positioned(
                          right: 16,
                          bottom: -2,
                          child: VerificationBadge(
                            isVerified: true,
                            size: 16,
                            entityType: 'company',
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
                                    widget.experience.title,
                                    style: const TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.experience.company,
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$start - $end',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_pin,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          widget.experience.location ?? '',
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
                            if (!isNarrow)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: _buildBadge(isVerified),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasPromotions) ...[
                const SizedBox(height: 16),
                ...widget.experience.promotions.map((p) {
                  final date = DateTime.fromMillisecondsSinceEpoch(p.date);
                  return Text(
                      '• ${p.newTitle} – ${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(fontSize: 14));
                }),
              ],
              if (widget.experience.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  widget.experience.description!,
                  style: const TextStyle(fontSize: 14.5, color: Colors.black87),
                ),
              ],
              if (!isVerified)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, widget.experience.manualId!),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                  TextButton(
                    onPressed: () =>
                        _showAddPromotionDialog(context, widget.experience.manualId!),
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                    child: Text(AppLocalizations.of(context)!.addPromotion),
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

  Widget _buildBadge(bool isVerified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            isVerified ? AppLocalizations.of(context)!.verifiedByBlockchain : AppLocalizations.of(context)!.manuallyAdded,
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

  void _showAddPromotionDialog(BuildContext context, int manualExperienceId) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addPromotionDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    InputDecoration(labelText: AppLocalizations.of(context)!.promotionTitle),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.date),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
                  if (widget.onPromotionAdded != null) widget.onPromotionAdded!();
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int manualExperienceId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeletion),
          content: Text(AppLocalizations.of(context)!.deleteExperienceConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {

                _userBLL.deleteManualExperience(manualExperienceId);
                Navigator.of(context).pop();
                if (widget.onPromotionAdded != null) widget.onPromotionAdded!();
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