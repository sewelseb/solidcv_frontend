import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/models/User.dart';

class JobDetails extends StatefulWidget {
  final String jobOfferId;
  
  const JobDetails({super.key, required this.jobOfferId});

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  final IJobOfferBll _jobOfferBll = JobOfferBll();
  final UserBll _userBll = UserBll();
  
  Future<JobOffer>? _jobOfferFuture;
  User? _currentUser;
  int? _jobOfferId;
  bool _isLoadingUser = true;
  bool _userLoadError = false;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);

  @override
  void initState() {
    super.initState();
    _jobOfferId = int.parse(widget.jobOfferId);
    _jobOfferFuture = _jobOfferBll.getPublicJobOfferById(_jobOfferId!);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _userBll.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
        _userLoadError = false;
      });
    } catch (e) {
      // User is not connected or there's an authentication error
      setState(() {
        _currentUser = null;
        _isLoadingUser = false;
        _userLoadError = true;
      });
    }
  }

  Future<void> _applyToJob(JobOffer jobOffer, User? currentUser) async {
    if (currentUser == null) {
      _showLoginDialog();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.work, color: _primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Apply to ${jobOffer.title}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            jobOffer.company?.name ?? 'Unknown Company',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            jobOffer.location ?? 'Location not specified',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (jobOffer.jobType != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              jobOffer.jobType!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Recommendation section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.indigo.shade50,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Maximize Your Chances!',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Before applying, we recommend:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRecommendationItem(
                      icon: Icons.person,
                      text: 'Complete your profile with personal information',
                      color: Colors.blue.shade700,
                    ),
                    _buildRecommendationItem(
                      icon: Icons.work_history,
                      text: 'Add your work experiences and achievements',
                      color: Colors.blue.shade700,
                    ),
                    _buildRecommendationItem(
                      icon: Icons.psychology,
                      text: 'Test and showcase your skills with AI validation',
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.amber.shade700, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recruiters will use AI to analyze your profile against this job!',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        Navigator.pushNamed(context, '/my-cv');
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Complete Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        side: BorderSide(color: _primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        Navigator.pushNamed(context, '/my-cv');
                      },
                      icon: const Icon(Icons.quiz, size: 16),
                      label: const Text('Test Skills'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                        side: BorderSide(color: Colors.orange.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Are you ready to submit your application?',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Apply Now'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _jobOfferBll.applyToJobOffer(jobOffer.id!);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Application submitted successfully!')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'View Applications',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/my-applications');
              },
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
                Expanded(child: Text('Error submitting application: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to apply for jobs. Would you like to login or register?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Register'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(JobOffer jobOffer) {
    if (_isLoadingUser) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          label: const Text('Loading...'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _applyToJob(jobOffer, _currentUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentUser != null ? _primaryColor : Colors.grey.shade600,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: Icon(_currentUser != null ? Icons.send : Icons.login),
        label: Text(_currentUser != null ? 'Apply Now' : 'Login to Apply'),
      ),
    );
  }

  Widget _buildUserStatusBanner() {
    if (_isLoadingUser) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Checking login status...'),
          ],
        ),
      );
    }

    if (_currentUser != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Welcome back, ${_currentUser!.firstName ?? 'User'}! You can apply to this position.',
                style: GoogleFonts.inter(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not logged in',
                  style: GoogleFonts.inter(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You need to login or register to apply for this position.',
                  style: GoogleFonts.inter(
                    color: Colors.orange.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showLoginDialog,
            child: Text(
              'Login',
              style: TextStyle(color: Colors.orange.shade700),
            ),
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
          'Job Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Conditionally show bottom navigation bar only for connected users
      bottomNavigationBar: _currentUser != null ? const MainBottomNavigationBar() : null,
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<JobOffer>(
        future: _jobOfferFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error loading job details: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Job not found'),
            );
          }

          final jobOffer = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // User Status Banner
                    _buildUserStatusBanner(),
                    
                    // Main Job Card
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        jobOffer.title ?? 'Untitled Position',
                                        style: GoogleFonts.inter(
                                          fontSize: isMobile ? 24 : 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (jobOffer.company?.name != null)
                                        Text(
                                          jobOffer.company!.name!,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: _primaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Job Info Grid
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow('Job Type', jobOffer.jobType, Icons.schedule),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Experience Level', jobOffer.experienceLevel, Icons.trending_up),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Location', jobOffer.location, Icons.location_on),
                                  if (jobOffer.salary != null) const SizedBox(height: 12),
                                  if (jobOffer.salary != null)
                                    _buildInfoRow('Salary', jobOffer.salary!.toString(), Icons.attach_money),
                                  if (jobOffer.createdAt != null) const SizedBox(height: 12),
                                  if (jobOffer.createdAt != null)
                                    _buildInfoRow('Posted', _formatDate(DateTime.fromMillisecondsSinceEpoch(jobOffer.createdAt!)), Icons.calendar_today),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Job Description
                            if (jobOffer.description != null && jobOffer.description!.isNotEmpty) ...[
                              _buildSection('Job Description', jobOffer.description!),
                              const SizedBox(height: 24),
                            ],

                            // Requirements
                            if (jobOffer.requirements != null && jobOffer.requirements!.isNotEmpty) ...[
                              _buildSection('Requirements', jobOffer.requirements!),
                              const SizedBox(height: 24),
                            ],

                            // Benefits
                            if (jobOffer.benefits != null && jobOffer.benefits!.isNotEmpty) ...[
                              _buildSection('Benefits', jobOffer.benefits!),
                              const SizedBox(height: 24),
                            ],

                            // Apply Button
                            _buildApplyButton(jobOffer),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Row(
      children: [
        Icon(icon, size: 18, color: _primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 14,
            ),
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() != 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}