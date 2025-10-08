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
import 'package:solid_cv/Views/widgets/AddedManuallyWorkExperienceForm.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';

class WorkExperienceCardMobile extends StatefulWidget {
  final UnifiedExperienceViewModel experience;
  final VoidCallback? onPromotionAdded;

  const WorkExperienceCardMobile({
    super.key,
    required this.experience,
    this.onPromotionAdded,
  });

  @override
  State<WorkExperienceCardMobile> createState() => _WorkExperienceCardMobileState();
}

class _WorkExperienceCardMobileState extends State<WorkExperienceCardMobile> {
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
                      isVerified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.manually,
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
                  Stack(
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
                      if (isVerified && (widget.experience.isCompanyVerified ?? false))
                        const Positioned(
                          right: -2,
                          bottom: -2,
                          child: VerificationBadge(
                            isVerified: true,
                            size: 16,
                            entityType: 'company',
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
                          widget.experience.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.experience.company,
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
                ],
              ),
            ],
          ),
          if (hasPromotions) ...[
            const SizedBox(height: 16),
            ...widget.experience.promotions.map((p) {
              final date = DateTime.fromMillisecondsSinceEpoch(p.date);
              return Text(
                '• ${p.newTitle} – ${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontSize: 14),
              );
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
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.editProfile,
                    icon: const Icon(Icons.edit, color: Colors.black87),
                    onPressed: () async {
                      if (widget.experience.manualId == null) return;
                      final manual = ManualExperience(
                        id: widget.experience.manualId,
                        title: widget.experience.title,
                        company: widget.experience.company,
                        description: widget.experience.description,
                        location: widget.experience.location,
                        startDateAsTimestamp: widget.experience.startDate != null
                            ? (widget.experience.startDate! / 1000).round()
                            : null,
                        endDateAsTimestamp: widget.experience.endDate != null
                            ? (widget.experience.endDate! / 1000).round()
                            : null,
                        promotions: widget.experience.promotions,
                      );

                      await showDialog(
                        context: context,
                        builder: (ctx) => AddedManuallyWorkExperienceForm(
                          initialExperience: manual,
                          onSubmit: (updated) async {
                            _userBLL.updateManuallyAddedExperience(updated);
                            if (widget.onPromotionAdded != null) {
                              widget.onPromotionAdded!();
                            }
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.delete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(
                      context,
                      widget.experience.manualId!,
                    ),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.addPromotion,
                    onPressed: () => _showAddPromotionDialog(
                        context, widget.experience.manualId!),
                    icon: const Icon(Icons.add, color: Colors.deepPurple),
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
          title: Text(AppLocalizations.of(context)!.addPromotionDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.promotionTitle),
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
