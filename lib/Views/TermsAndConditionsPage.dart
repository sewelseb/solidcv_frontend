import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
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
        title: Text(
          AppLocalizations.of(context)!.termsAndConditions,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF7B3FE4),
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34, vertical: 38),
                    child: _TermsAndConditionsContent(),
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

class _TermsAndConditionsContent extends StatelessWidget {
  const _TermsAndConditionsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Center(
          child: Text(
            AppLocalizations.of(context)!.termsAndConditions,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7B3FE4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppLocalizations.of(context)!.lastUpdated,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Introduction
        _buildSection(
          AppLocalizations.of(context)!.termsSection1Title,
          AppLocalizations.of(context)!.termsSection1Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection2Title,
          AppLocalizations.of(context)!.termsSection2Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection3Title,
          AppLocalizations.of(context)!.termsSection3Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection4Title,
          AppLocalizations.of(context)!.termsSection4Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection5Title,
          AppLocalizations.of(context)!.termsSection5Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection6Title,
          AppLocalizations.of(context)!.termsSection6Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection7Title,
          AppLocalizations.of(context)!.termsSection7Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection8Title,
          AppLocalizations.of(context)!.termsSection8Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection9Title,
          AppLocalizations.of(context)!.termsSection9Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection10Title,
          AppLocalizations.of(context)!.termsSection10Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection11Title,
          AppLocalizations.of(context)!.termsSection11Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection12Title,
          AppLocalizations.of(context)!.termsSection12Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection13Title,
          AppLocalizations.of(context)!.termsSection13Content,
        ),

        _buildSection(
          AppLocalizations.of(context)!.termsSection14Title,
          AppLocalizations.of(context)!.termsSection14Content,
        ),

        const SizedBox(height: 32),

        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            AppLocalizations.of(context)!.termsFooterAcknowledgment,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7B3FE4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
