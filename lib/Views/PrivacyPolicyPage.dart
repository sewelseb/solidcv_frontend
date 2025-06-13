import 'package:flutter/material.dart';

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
        title: const Text("Privacy Policy",
            style: TextStyle(fontWeight: FontWeight.w600)),
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34, vertical: 38),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Icon(Icons.privacy_tip_outlined,
                  size: 48, color: Color(0xFF7B3FE4)),
              SizedBox(height: 12),
              Text(
                "SolidCV Privacy Policy",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B3FE4)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Text(
          "1. Data Collection",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "We collect the data you provide (such as your name, email, CV details, education, and company information) to deliver and improve SolidCV services. We do not collect unnecessary personal data.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "2. Data Use",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "Your data is only used to allow you to build, verify, and manage your CV, as well as interact with companies and educational institutions. We do not sell your information. Some features may use your data to improve the user experience or for statistical purposes (always anonymously).",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "3. Data Sharing",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "We do not share your personal data with third parties except when required by law, or with your explicit consent (for example, when you request to verify your CV with a company or educational institution).",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "4. Data Security",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "Your data is encrypted and securely stored. Sensitive data (such as private keys) are never stored on our servers but remain on your device only. Always keep your credentials safe.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "5. User Rights",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "You can access, modify, or delete your personal data at any time via the application. To request data deletion, contact us at privacy@solidcv.app.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "6. Cookies & Analytics",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "We use essential cookies and analytics only to improve the app. No tracking for advertising purposes is done.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 18),
        Text(
          "7. Contact",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        SizedBox(height: 5),
        Text(
          "If you have any question about your privacy, contact us at sebastien.debeauffort@outlook.com.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
        SizedBox(height: 34),
        Center(
          child: Text(
            "Last updated: June 2025",
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
