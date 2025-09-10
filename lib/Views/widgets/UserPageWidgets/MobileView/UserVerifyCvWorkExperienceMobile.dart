import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/glassCardDecoration.dart';
import 'package:solid_cv/Views/components/VerificationBadge.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class UserVerifyCvWorkExperienceCardMobile extends StatelessWidget {
  final UnifiedExperienceViewModel experience;

  const UserVerifyCvWorkExperienceCardMobile({
    super.key,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = experience.isVerified;
    final start = FormatDate().formatDateForExperience(context, experience.startDate);
    final end = FormatDate().formatDateForExperience(context, experience.endDate);
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
                      isVerified ? AppLocalizations.of(context)!.workExperienceVerified : AppLocalizations.of(context)!.workExperienceManually,
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
                      if (isVerified && (experience.isCompanyVerified ?? false))
                        Positioned(
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
                          AppLocalizations.of(context)!.workExperienceDateRange(start, end),
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
              final formattedDate = '${date.day}/${date.month}/${date.year}';
              return Text(
                AppLocalizations.of(context)!.workExperiencePromotion(p.newTitle, formattedDate),
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
        ],
      ),
    );
  }
}
