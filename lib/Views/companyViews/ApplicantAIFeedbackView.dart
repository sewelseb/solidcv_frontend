import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/ApplicantAIFeedback.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:flutter/services.dart';


class ApplicantAIFeedbackView extends StatefulWidget {
  const ApplicantAIFeedbackView({super.key});

  @override
  State<ApplicantAIFeedbackView> createState() => _ApplicantAIFeedbackViewState();
}

class _ApplicantAIFeedbackViewState extends State<ApplicantAIFeedbackView> {
  final IJobOfferBll _jobOfferBll = JobOfferBll();
  final UserBll _userBll = UserBll();
  
  Future<ApplicantAIFeedback?>? _aiFeedbackFuture;
  Future<User>? _userFuture;
  Future<JobOffer>? _jobOfferFuture;
  
  int? _userId;
  int? _jobOfferId;
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aiFeedbackFuture == null) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      _userId = int.parse(args['userId']!);
      _jobOfferId = int.parse(args['jobOfferId']!);
      
      _userFuture = _userBll.getUser(_userId!.toString());
      _jobOfferFuture = _jobOfferBll.getJobOfferById(_jobOfferId!);
      _aiFeedbackFuture = _jobOfferBll.getAIFeedback(_userId!, _jobOfferId!);
    }
  }

  Future<void> _generateNewFeedback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate new feedback
      await _jobOfferBll.generateAIFeedback(_userId!, _jobOfferId!);
      
      // Refresh the feedback data after successful generation
      setState(() {
        _aiFeedbackFuture = _jobOfferBll.getAIFeedback(_userId!, _jobOfferId!);
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('AI analysis generated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Error generating analysis: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getScoreColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreText(double? score) {
    if (score == null) return 'Not rated';
    if (score >= 80) return 'Excellent fit';
    if (score >= 60) return 'Good fit';
    if (score >= 40) return 'Fair fit';
    return 'Poor fit';
  }

  void _contactCandidate(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _primaryColor,
              radius: 20,
              child: Text(
                user.getEasyName()!.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact ${user.getEasyName()}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Candidate Contact Information',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null) ...[
              _buildCopyableContactItem(
                icon: Icons.email,
                label: 'Email',
                value: user.email!,
                onCopy: () => _copyToClipboard(user.email!, 'Email copied to clipboard'),
              ),
              const SizedBox(height: 16),
            ],
            if (user.phoneNumber != null) ...[
              _buildCopyableContactItem(
                icon: Icons.phone,
                label: 'Phone',
                value: user.phoneNumber!,
                onCopy: () => _copyToClipboard(user.phoneNumber!, 'Phone number copied to clipboard'),
              ),
              const SizedBox(height: 16),
            ],
            if (user.email == null && user.phoneNumber == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No contact information available for this candidate.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: _primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.copy,
                      color: _primaryColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: _primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Job Application Follow-up',
    );
    // Add your URL launcher logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening email client for $email'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    // Add your URL launcher logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening phone app for $phoneNumber'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _launchLinkedIn(String linkedinUrl) async {
    // Add your URL launcher logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening LinkedIn profile'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _scheduleInterview(User user) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedule interview with ${user.getEasyName()}'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Calendar',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to calendar or scheduling view
          },
        ),
      ),
    );
  }

  void _viewUserProfile(User user) {
    Navigator.of(context).pop();
    Navigator.pushNamed(
      context,
      '/user/${user.id}',
    );
  }

  void _composeEmail(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Email to ${user.getEasyName()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'Job Application Follow-up',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Dear ${user.getEasyName()},\n\nThank you for your application...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Candidate Analysis',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _generateNewFeedback,
            tooltip: 'Generate New Feedback',
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientStart, _gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([_userFuture!, _jobOfferFuture!]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data![0] as User;
                    final jobOffer = snapshot.data![1] as JobOffer;
                    
                    return Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.psychology,
                                  color: Colors.white,
                                  size: isMobile ? 24 : 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Analysis for ${user.getEasyName()}',
                                      style: GoogleFonts.inter(
                                        fontSize: isMobile ? 18 : 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      jobOffer.title ?? 'Job Position',
                                      style: GoogleFonts.inter(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Comprehensive AI-powered analysis of candidate fit based on skills, experience, and job requirements',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Contact Candidate Button
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _contactCandidate(user),
                                icon: const Icon(Icons.email, size: 18),
                                label: Text(
                                  isMobile ? 'Contact' : 'Contact Candidate',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 16 : 24,
                                    vertical: isMobile ? 12 : 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return Container(
                    height: 120,
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // AI Feedback Content
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: FutureBuilder<ApplicantAIFeedback?>(
                future: _aiFeedbackFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Analyzing candidate profile...'),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return _buildErrorState();
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    // No feedback available yet - not an error
                    return _buildNoFeedbackState();
                  }

                  final feedback = snapshot.data!;
                  return Column(
                    children: [
                      // Regenerate Feedback Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generateNewFeedback,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(
                            _isLoading ? 'Generating...' : 'Regenerate AI Analysis',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 32,
                              vertical: isMobile ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: _primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),

                      // Overall Score Card
                      _buildOverallScoreCard(feedback, isMobile),
                      const SizedBox(height: 20),
                      
                     
                      
                      // Strengths Section
                      _buildStrengthsCard(feedback, isMobile),
                      const SizedBox(height: 20),
                      
                      // Weaknesses Section
                      _buildWeaknessesCard(feedback, isMobile),
                      const SizedBox(height: 20),
                      
                      // Conclusion Section
                      _buildConclusionCard(feedback, isMobile),
                      const SizedBox(height: 20),

                       // Recommendations Section
                      if (feedback.recommendations != null && feedback.recommendations!.isNotEmpty) ...[
                        _buildRecommendationsCard(feedback, isMobile),
                        const SizedBox(height: 20),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(ApplicantAIFeedback feedback, bool isMobile) {
    final score = feedback.overallScore ?? 0.0;
    final scoreColor = _getScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics, color: scoreColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Overall Match Score',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withOpacity(0.1),
                        border: Border.all(color: scoreColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${(score).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getScoreText(score),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreBar('Technical Skills', feedback.technicalScore!/100, isMobile),
                    const SizedBox(height: 12),
                    _buildScoreBar('Experience', feedback.experienceScore!/100, isMobile),
                    const SizedBox(height: 12),
                    _buildScoreBar('Cultural Fit', feedback.culturalFitScore!/100, isMobile),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double? score, bool isMobile) {
    final normalizedScore = score ?? 0.0;
    final scoreColor = _getScoreColor(normalizedScore);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${(normalizedScore * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: normalizedScore,
            child: Container(
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthsCard(ApplicantAIFeedback feedback, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.thumb_up, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Strengths',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (feedback.strengths != null && feedback.strengths!.isNotEmpty)
            ...feedback.strengths!.map((strength) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strength,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ))
          else
            Text(
              'No specific strengths identified.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeaknessesCard(ApplicantAIFeedback feedback, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Areas for Improvement',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (feedback.weaknesses != null && feedback.weaknesses!.isNotEmpty)
            ...feedback.weaknesses!.map((weakness) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      weakness,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ))
          else
            Text(
              'No significant weaknesses identified.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConclusionCard(ApplicantAIFeedback feedback, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_gradientStart.withOpacity(0.1), _gradientEnd.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.summarize, color: _primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Summary',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            feedback.conclusion ?? 'No conclusion available.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(ApplicantAIFeedback feedback, bool isMobile) {
    final score = feedback.overallScore ?? 0.0;
    final scoreColor = _getScoreColor(score);
    
    // Determine recommendation type based on score
    IconData recommendationIcon;
    Color recommendationColor;
    String recommendationLabel;
    
    if (score >= 80) {
      recommendationIcon = Icons.thumb_up;
      recommendationColor = Colors.green;
      recommendationLabel = 'Strong Recommendation';
    } else if (score >= 60) {
      recommendationIcon = Icons.lightbulb;
      recommendationColor = Colors.orange;
      recommendationLabel = 'Consider with Conditions';
    } else {
      recommendationIcon = Icons.warning;
      recommendationColor = Colors.red;
      recommendationLabel = 'Not Recommended';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recommendationColor.withOpacity(0.05),
            recommendationColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: recommendationColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: recommendationColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with recommendation status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: recommendationColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: recommendationColor.withOpacity(0.3)),
                ),
                child: Icon(
                  recommendationIcon,
                  color: recommendationColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendations',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: recommendationColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recommendationLabel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: recommendationColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${score.toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Recommendations list
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: _primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Analysis & Recommendations',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Display each recommendation as a bullet point
                ...feedback.recommendations!.map((recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: recommendationColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          // Action suggestions based on recommendation
          const SizedBox(height: 16),
          _buildActionSuggestions(score, isMobile),
        ],
      ),
    );
  }

  Widget _buildActionSuggestions(double score, bool isMobile) {
    List<Map<String, dynamic>> suggestions = [];
    
    if (score >= 80) {
      suggestions = [
        {'icon': Icons.phone, 'text': 'Schedule immediate interview', 'color': Colors.green},
        {'icon': Icons.star, 'text': 'Consider for priority positions', 'color': Colors.green},
        {'icon': Icons.handshake, 'text': 'Prepare competitive offer', 'color': Colors.green},
      ];
    } else if (score >= 60) {
      suggestions = [
        {'icon': Icons.quiz, 'text': 'Conduct skills assessment', 'color': Colors.orange},
        {'icon': Icons.people, 'text': 'Team interview recommended', 'color': Colors.orange},
        {'icon': Icons.school, 'text': 'Consider training opportunities', 'color': Colors.orange},
      ];
    } else {
      suggestions = [
        {'icon': Icons.feedback, 'text': 'Provide constructive feedback', 'color': Colors.red},
        {'icon': Icons.bookmark, 'text': 'Keep for future opportunities', 'color': Colors.red},
        {'icon': Icons.trending_up, 'text': 'Suggest skill development', 'color': Colors.red},
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Next Steps',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: suggestion['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  suggestion['icon'],
                  size: 16,
                  color: suggestion['color'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion['text'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading AI feedback',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try generating new feedback',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _generateNewFeedback,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate Feedback'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFeedbackState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined, 
              size: 48, 
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No AI Analysis Yet',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Generate AI-powered analysis to get insights about this candidate\'s fit for the position.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _generateNewFeedback,
            icon: _isLoading 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome, size: 20),
            label: Text(
              _isLoading ? 'Generating Analysis...' : 'Generate AI Analysis',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: _primaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Analysis typically takes 30-60 seconds to complete',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}