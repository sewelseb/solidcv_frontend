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


class ApplicantAIFeedbackView extends StatefulWidget {
  const ApplicantAIFeedbackView({super.key});

  @override
  State<ApplicantAIFeedbackView> createState() => _ApplicantAIFeedbackViewState();
}

class _ApplicantAIFeedbackViewState extends State<ApplicantAIFeedbackView> {
  final IJobOfferBll _jobOfferBll = JobOfferBll();
  final UserBll _userBll = UserBll();
  
  Future<ApplicantAIFeedback>? _aiFeedbackFuture;
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
      await _jobOfferBll.generateAIFeedback(_userId!, _jobOfferId!);
      setState(() {
        _aiFeedbackFuture = _jobOfferBll.getAIFeedback(_userId!, _jobOfferId!);
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI feedback generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating feedback: $e'),
          backgroundColor: Colors.red,
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
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getScoreText(double? score) {
    if (score == null) return 'Not rated';
    if (score >= 0.8) return 'Excellent fit';
    if (score >= 0.6) return 'Good fit';
    if (score >= 0.4) return 'Fair fit';
    return 'Poor fit';
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
                                      'AI Analysis for ${user.firstName} ${user.lastName}',
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
              child: FutureBuilder<ApplicantAIFeedback>(
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
                  } else if (!snapshot.hasData) {
                    return _buildNoFeedbackState();
                  }

                  final feedback = snapshot.data!;
                  return Column(
                    children: [
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
                          '${(score * 100).toInt()}%',
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
                    _buildScoreBar('Technical Skills', feedback.technicalScore, isMobile),
                    const SizedBox(height: 12),
                    _buildScoreBar('Experience', feedback.experienceScore, isMobile),
                    const SizedBox(height: 12),
                    _buildScoreBar('Cultural Fit', feedback.culturalFitScore, isMobile),
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
                'AI Conclusion',
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
          if (feedback.recommendation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendation',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback.recommendation!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
          Icon(Icons.psychology_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No AI feedback available',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate AI-powered analysis for this candidate',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _generateNewFeedback,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate AI Feedback'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}