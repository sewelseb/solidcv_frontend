import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/models/JobOffer.dart';

class ManageJobOffers extends StatefulWidget {
  const ManageJobOffers({super.key});

  @override
  State<ManageJobOffers> createState() => _ManageJobOffersState();
}

class _ManageJobOffersState extends State<ManageJobOffers> {
  final IJobOfferBll _jobOfferBll = JobOfferBll();
  Future<List<JobOffer>>? _jobOffersFuture;
  int? _companyId;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_jobOffersFuture == null) {
      final String companyIdStr = ModalRoute.of(context)!.settings.arguments as String;
      _companyId = int.parse(companyIdStr);
      _jobOffersFuture = _jobOfferBll.getJobOffersByCompany(_companyId!);
    }
  }

  Future<void> _refreshJobOffers() async {
    setState(() {
      _jobOffersFuture = _jobOfferBll.getJobOffersByCompany(_companyId!);
    });
  }

  Future<void> _shareJobOffer(JobOffer jobOffer) async {
    final url = 'https://www.solidcv.com/job-details/${jobOffer.id}';
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.share, color: _primaryColor),
            const SizedBox(width: 8),
            const Text('Share Job Offer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share "${jobOffer.title}" with others:',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      url,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.of(context).pop('copied');
                    },
                    icon: Icon(Icons.copy, color: _primaryColor),
                    tooltip: 'Copy URL',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.of(context).pop('copied');
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Copy Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == 'copied') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Job offer URL copied to clipboard!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/job-details/${jobOffer.id}');
            },
          ),
        ),
      );
    }
  }

  void _viewJobOffer(JobOffer jobOffer) {
    Navigator.pushNamed(context, '/job-details/${jobOffer.id}');
  }

  void _viewApplications(JobOffer jobOffer) {
    Navigator.pushNamed(
      context, 
      '/company/job-applications',
      arguments: jobOffer.id.toString(),
    );
  }

  Future<void> _deleteJobOffer(int jobOfferId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Offer'),
        content: const Text('Are you sure you want to delete this job offer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _jobOfferBll.deleteJobOffer(jobOfferId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job offer deleted successfully')),
        );
        _refreshJobOffers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting job offer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Job Offers',
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
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/company/create-job-offer',
                arguments: _companyId.toString(),
              ).then((_) => _refreshJobOffers());
            },
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _refreshJobOffers,
        child: FutureBuilder<List<JobOffer>>(
          future: _jobOffersFuture,
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
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshJobOffers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No job offers found',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first job offer to get started',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/company/create-job-offer',
                          arguments: _companyId.toString(),
                        ).then((_) => _refreshJobOffers());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Job Offer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final jobOffers = snapshot.data!;

            return Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${jobOffers.length} Job Offer${jobOffers.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: jobOffers.length,
                      itemBuilder: (context, index) {
                        final jobOffer = jobOffers[index];
                        return _buildJobOfferCard(jobOffer, isMobile);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJobOfferCard(JobOffer jobOffer, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gradientStart.withOpacity(0.2)),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        jobOffer.title ?? 'Untitled Position',
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: jobOffer.isActive == true ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        jobOffer.isActive == true ? 'Active' : 'Inactive',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: jobOffer.isActive == true ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (jobOffer.location != null && jobOffer.location!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        jobOffer.location!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (jobOffer.description != null && jobOffer.description!.isNotEmpty)
                  Text(
                    jobOffer.description!.length > 150
                        ? '${jobOffer.description!.substring(0, 150)}...'
                        : jobOffer.description!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    if (jobOffer.createdAt != null)
                      Text(
                        'Created ${_formatDate(DateTime.fromMillisecondsSinceEpoch(jobOffer.createdAt as int))}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const Spacer(),
                    // Share Button
                    IconButton(
                      onPressed: () => _shareJobOffer(jobOffer),
                      icon: const Icon(Icons.share, size: 18),
                      tooltip: 'Share Job Offer',
                      style: IconButton.styleFrom(
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Action Buttons Row - Updated to stack all buttons on mobile
                if (isMobile)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _viewJobOffer(jobOffer),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Job Offer'),
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
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _viewApplications(jobOffer),
                          icon: const Icon(Icons.people, size: 16),
                          label: const Text('View Applications'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/company/edit-job-offer',
                              arguments: jobOffer.id.toString(),
                            ).then((_) => _refreshJobOffers());
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Job Offer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteJobOffer(jobOffer.id!),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete Job Offer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _viewJobOffer(jobOffer),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryColor,
                            side: BorderSide(color: _primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _viewApplications(jobOffer),
                          icon: const Icon(Icons.people, size: 16),
                          label: const Text('Apps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/company/edit-job-offer',
                              arguments: jobOffer.id.toString(),
                            ).then((_) => _refreshJobOffers());
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteJobOffer(jobOffer.id!),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
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
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}