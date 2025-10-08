import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlansView extends StatelessWidget {
  const PlansView({super.key, required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A69F1), Color(0xFF8A5CF0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.subscriptionUpgradeTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.subscriptionUpgradeSubtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              final children = [
                _PlanCard(
                  title: AppLocalizations.of(context)!.subscriptionPlanMonthly,
                  price: AppLocalizations.of(context)!.subscriptionPriceMonthly,
                  period: AppLocalizations.of(context)!.subscriptionPeriodMonth,
                  features: [
                    AppLocalizations.of(context)!
                        .subscriptionFeaturePreviousWeeksRecommendations,
                  ],
                  highlighted: false,
                ),
                _PlanCard(
                  title: AppLocalizations.of(context)!.subscriptionPlanYearly,
                  price: AppLocalizations.of(context)!.subscriptionPriceYearly,
                  period: AppLocalizations.of(context)!.subscriptionPeriodYear,
                  subtitle: AppLocalizations.of(context)!
                      .subscriptionSubtitleYearlySavings,
                  features: [
                    AppLocalizations.of(context)!
                        .subscriptionFeaturePreviousWeeksRecommendations,
                  ],
                  highlighted: true,
                ),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: children[0]),
                    const SizedBox(width: 16),
                    Expanded(child: children[1]),
                  ],
                );
              }
              return Column(
                children: [
                  children[0],
                  const SizedBox(height: 16),
                  children[1],
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    this.subtitle,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String period;
  final String? subtitle;
  final List<String> features;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
            color:
                highlighted ? const Color(0xFF7B3FE4) : const Color(0x11000000),
            width: highlighted ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1F7B3FE4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle!,
                    style:
                        const TextStyle(color: Color(0xFF7B3FE4), fontSize: 12),
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(period, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF2ECC71), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    highlighted ? const Color(0xFF7B3FE4) : Colors.white,
                foregroundColor: highlighted ? Colors.white : Colors.black,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color: highlighted
                          ? const Color(0xFF7B3FE4)
                          : const Color(0x33000000)),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.subscriptionChoosePlan),
            ),
          ),
        ],
      ),
    );
    return card;
  }
}
