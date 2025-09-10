import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/glassCardDecoration.dart';
import 'package:solid_cv/Views/components/VerificationBadge.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class UserVerifyCvWorkExperienceDesktopCard extends StatelessWidget {
  final UnifiedExperienceViewModel experience;

  const UserVerifyCvWorkExperienceDesktopCard({
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
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: glassCardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow) _buildBadge(isVerified, context),
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
                      if (isVerified && (experience.isCompanyVerified ?? false))
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
                                    experience.title,
                                    style: const TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    experience.company,
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(AppLocalizations.of(context)!.workExperienceDateRange(start, end),
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
                            if (!isNarrow)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: _buildBadge(isVerified, context),
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
                ...experience.promotions.map((p) {
                  final date = DateTime.fromMillisecondsSinceEpoch(p.date);
                  final formattedDate = '${date.day}/${date.month}/${date.year}';
                  return Text(
                      AppLocalizations.of(context)!.workExperiencePromotion(p.newTitle, formattedDate),
                      style: const TextStyle(fontSize: 14));
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
          );
        },
      ),
    );
  }

  Widget _buildBadge(bool isVerified, BuildContext context) {
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
            isVerified ? AppLocalizations.of(context)!.workExperienceVerifiedBlockchain : AppLocalizations.of(context)!.workExperienceManuallyAdded,
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

}