import 'package:flutter/material.dart';
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
          "Terms and Conditions",
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
            "Terms and Conditions",
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
            "Last updated: ${DateTime.now().year}",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Introduction
        _buildSection(
          "1. Introduction",
          "Welcome to SolidCV. These Terms and Conditions ('Terms') govern your use of our platform and services. By accessing or using SolidCV, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use our services.",
        ),

        _buildSection(
          "2. Description of Service",
          "SolidCV is a blockchain-powered CV/Resume management platform that allows users to create, manage, and verify their professional credentials through NFT-based certificates and work experience tokens. Our platform combines traditional CV management with blockchain technology for credential verification and AI-powered career guidance.",
        ),

        _buildSection(
          "3. User Accounts and Registration",
          "To use our services, you must:\n\n• Be at least 18 years old or have parental consent\n• Provide accurate and complete registration information\n• Maintain the security of your account credentials\n• Accept responsibility for all activities under your account\n• Notify us immediately of any unauthorized use of your account",
        ),

        _buildSection(
          "4. Acceptable Use",
          "You agree to use SolidCV only for lawful purposes and in accordance with these Terms. You may not:\n\n• Upload false, misleading, or fraudulent information\n• Violate any applicable laws or regulations\n• Infringe on the rights of others\n• Attempt to gain unauthorized access to our systems\n• Use our services for any commercial purpose without permission\n• Upload malicious code or engage in any harmful activities",
        ),

        _buildSection(
          "5. Blockchain and NFT Services",
          "SolidCV utilizes blockchain technology for credential verification:\n\n• NFT certificates are minted on the Ethereum blockchain\n• Work experience tokens are stored on IPFS\n• Blockchain transactions may incur gas fees\n• We do not control blockchain networks or their availability\n• Digital assets may have value fluctuations\n• You are responsible for managing your wallet and private keys",
        ),

        _buildSection(
          "6. Data and Privacy",
          "Your privacy is important to us. Our data practices are governed by our Privacy Policy, which is incorporated into these Terms by reference. By using our services, you consent to the collection, use, and sharing of your information as described in our Privacy Policy.",
        ),

        _buildSection(
          "7. Intellectual Property",
          "SolidCV and its content are protected by intellectual property laws:\n\n• We retain all rights to our platform, design, and proprietary technology\n• You retain ownership of content you upload\n• You grant us a license to use your content to provide our services\n• You may not copy, modify, or redistribute our platform without permission",
        ),

        _buildSection(
          "8. AI-Powered Features",
          "Our platform includes AI-powered career guidance and feedback:\n\n• AI recommendations are for informational purposes only\n• We do not guarantee the accuracy of AI-generated content\n• AI features may use your data to improve our services\n• You should not rely solely on AI recommendations for career decisions",
        ),

        _buildSection(
          "9. Payment and Subscription Terms",
          "If applicable to premium features:\n\n• Subscription fees are charged in advance\n• Refunds are subject to our refund policy\n• We may change pricing with 30 days' notice\n• You are responsible for all taxes and fees\n• Payment information must be accurate and current",
        ),

        _buildSection(
          "10. Limitation of Liability",
          "TO THE MAXIMUM EXTENT PERMITTED BY LAW:\n\n• SolidCV is provided 'as is' without warranties\n• We are not liable for indirect, incidental, or consequential damages\n• Our total liability is limited to the amount you paid us in the past 12 months\n• We are not responsible for blockchain network issues or third-party services",
        ),

        _buildSection(
          "11. Termination",
          "We may terminate or suspend your account at any time for:\n\n• Violation of these Terms\n• Fraudulent or illegal activity\n• Abuse of our services or other users\n• Non-payment of fees (if applicable)\n\nYou may terminate your account at any time by contacting us. Upon termination, your right to use our services ceases immediately.",
        ),

        _buildSection(
          "12. Changes to Terms",
          "We reserve the right to modify these Terms at any time. We will notify you of significant changes via email or platform notification. Your continued use of our services after changes constitutes acceptance of the new Terms.",
        ),

        _buildSection(
          "13. Governing Law and Disputes",
          "These Terms are governed by the laws of Ireland. Any disputes will be resolved through binding arbitration in accordance with the rules of [Arbitration Organization]. You waive your right to participate in class action lawsuits.",
        ),

        _buildSection(
          "14. Contact Information",
          "If you have questions about these Terms, please contact us at:\n\nEmail: sebastien@solidcv.com\n\nFor technical support: sebastien@solidcv.com",
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
            "By using SolidCV, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.",
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
