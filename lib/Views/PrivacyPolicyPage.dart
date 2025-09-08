import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 550;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyPolicy,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF7B3FE4),
        elevation: 1,
        centerTitle: true,
      ),
      body: Center(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Card(
                  color: Colors.white,
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  margin: EdgeInsets.symmetric(
                      horizontal: isWide ? 0 : 18, vertical: 32),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 38),
                    child: _PrivacyPolicyContent(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Icon(Icons.privacy_tip_outlined,
                  size: 48, color: Color(0xFF7B3FE4)),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.solidcvPrivacyPolicy,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B3FE4)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          AppLocalizations.of(context)!.dataCollection,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.dataCollectionText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.dataUse,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.dataUseText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.dataSharing,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.dataSharingText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.dataSecurity,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.dataSecurityText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.userRights,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.userRightsText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.cookiesAnalytics,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.cookiesAnalyticsText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!.contact,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.contactText,
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 34),
        Center(
          child: Text(
            AppLocalizations.of(context)!.lastUpdated,
            style: const TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
