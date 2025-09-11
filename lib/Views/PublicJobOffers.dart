import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';

class PublicJobOffers extends StatefulWidget {
  const PublicJobOffers({super.key});

  @override
  State<PublicJobOffers> createState() => _PublicJobOffersState();
}

class _PublicJobOffersState extends State<PublicJobOffers> {
  final IJobOfferBll _jobOfferBll = JobOfferBll();
  final UserBll _userBll = UserBll();
  
  Future<List<JobOffer>>? _jobOffersFuture;
  Future<User?>? _currentUserFuture;
  bool _isUserAuthenticated = false;
  
  String _searchQuery = '';
  String _selectedLocation = '';
  String _selectedJobType = '';
  String _selectedExperienceLevel = '';
  
  final TextEditingController _searchController = TextEditingController();
  
  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);

  // Remove static lists - will use dynamic localized lists instead

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkUserAuthentication();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize filter values with localized strings
    if (_selectedLocation.isEmpty) {
      _selectedLocation = AppLocalizations.of(context)!.allLocations;
    }
    if (_selectedJobType.isEmpty) {
      _selectedJobType = AppLocalizations.of(context)!.allTypes;
    }
    if (_selectedExperienceLevel.isEmpty) {
      _selectedExperienceLevel = AppLocalizations.of(context)!.allLevels;
    }
  }

  List<String> _getLocalizedJobTypes() {
    return [
      AppLocalizations.of(context)!.allTypes,
      AppLocalizations.of(context)!.fullTime,
      AppLocalizations.of(context)!.partTime,
      AppLocalizations.of(context)!.contract,
      AppLocalizations.of(context)!.internship,
      AppLocalizations.of(context)!.freelance,
    ];
  }

  List<String> _getLocalizedExperienceLevels() {
    return [
      AppLocalizations.of(context)!.allLevels,
      AppLocalizations.of(context)!.entryLevel,
      AppLocalizations.of(context)!.midLevel,
      AppLocalizations.of(context)!.senior,
      AppLocalizations.of(context)!.lead,
      AppLocalizations.of(context)!.executive,
    ];
  }

  void _loadData() {
    _jobOffersFuture = _jobOfferBll.getAllPublicJobOffers();
    _currentUserFuture = _userBll.getCurrentUser();
  }

  Future<void> _refreshJobOffers() async {
    setState(() {
      _loadData();
    });
  }

  Future<void> _checkUserAuthentication() async {
    try {
      final token = await APIConnectionHelper.getJwtToken();
      setState(() {
        _isUserAuthenticated = token.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isUserAuthenticated = false;
      });
    }
  }

  List<JobOffer> _filterJobOffers(List<JobOffer> jobOffers) {
    return jobOffers.where((jobOffer) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final titleMatch = jobOffer.title?.toLowerCase().contains(searchLower) ?? false;
        final descriptionMatch = jobOffer.description?.toLowerCase().contains(searchLower) ?? false;
        final companyMatch = jobOffer.company?.name?.toLowerCase().contains(searchLower) ?? false;
        
        if (!titleMatch && !descriptionMatch && !companyMatch) {
          return false;
        }
      }

      // Location filter
      if (_selectedLocation != AppLocalizations.of(context)!.allLocations && 
          jobOffer.location != _selectedLocation) {
        return false;
      }

      // Job type filter
      if (_selectedJobType != AppLocalizations.of(context)!.allTypes && 
          jobOffer.jobType != _selectedJobType) {
        return false;
      }

      // Experience level filter
      if (_selectedExperienceLevel != AppLocalizations.of(context)!.allLevels && 
          jobOffer.experienceLevel != _selectedExperienceLevel) {
        return false;
      }

      // Only show active job offers
      return jobOffer.isActive == true;
    }).toList();
  }

  Set<String> _getUniqueLocations(List<JobOffer> jobOffers) {
    final locations = jobOffers
        .where((job) => job.location.isNotEmpty)
        .map((job) => job.location)
        .toSet();
    return {AppLocalizations.of(context)!.allLocations, ...locations};
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
                AppLocalizations.of(context)!.applyTo(jobOffer.title ?? ''),
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
                        // Company Logo in Dialog
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: jobOffer.company != null
                                ? Image.network(
                                    jobOffer.company!.getProfilePicture(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                      Icon(Icons.business, size: 12, color: Colors.grey.shade600),
                                  )
                                : Icon(Icons.business, size: 12, color: Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            jobOffer.company?.name ?? AppLocalizations.of(context)!.unknownCompany,
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
                            jobOffer.location.isNotEmpty ? jobOffer.location : AppLocalizations.of(context)!.locationNotSpecified,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              jobOffer.jobType,
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
                          AppLocalizations.of(context)!.maximizeYourChances,
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
                      AppLocalizations.of(context)!.beforeApplyingRecommend,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRecommendationItem(
                      icon: Icons.person,
                      text: AppLocalizations.of(context)!.completeProfilePersonalInfo,
                      color: Colors.blue.shade700,
                    ),
                    _buildRecommendationItem(
                      icon: Icons.work_history,
                      text: AppLocalizations.of(context)!.addWorkExperiences,
                      color: Colors.blue.shade700,
                    ),
                    _buildRecommendationItem(
                      icon: Icons.psychology,
                      text: AppLocalizations.of(context)!.testShowcaseSkills,
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
                              AppLocalizations.of(context)!.recruitersAnalyzeProfile,
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
                        Navigator.pushNamed(context, '/profile');
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(AppLocalizations.of(context)!.completeProfile),
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
                        Navigator.pushNamed(context, '/ai-skills-test');
                      },
                      icon: const Icon(Icons.quiz, size: 16),
                      label: Text(AppLocalizations.of(context)!.testSkills),
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
                AppLocalizations.of(context)!.readySubmitApplication,
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
            label: Text(AppLocalizations.of(context)!.applyNow),
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
                Expanded(child: Text(AppLocalizations.of(context)!.applicationSubmittedSuccessfully)),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.viewApplications,
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
                Expanded(child: Text(AppLocalizations.of(context)!.errorSubmittingApplication(e.toString()))),
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
        title: Text(AppLocalizations.of(context)!.loginRequired),
        content: Text(AppLocalizations.of(context)!.loginRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/register');
            },
            child: Text(AppLocalizations.of(context)!.register),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: Text(AppLocalizations.of(context)!.login, style: const TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<List<JobOffer>>(
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
                  Text(AppLocalizations.of(context)!.errorLoadingJobOffers(snapshot.error.toString())),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshJobOffers,
                    child: Text(AppLocalizations.of(context)!.retry),
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
                    AppLocalizations.of(context)!.noJobOffersAvailable,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.checkBackLaterOpportunities,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final allJobOffers = snapshot.data!;
          final filteredJobOffers = _filterJobOffers(allJobOffers);
          final uniqueLocations = _getUniqueLocations(allJobOffers);

          return RefreshIndicator(
            onRefresh: _refreshJobOffers,
            child: CustomScrollView(
              slivers: [
                // Collapsible Search and Filter Header
                SliverAppBar(
                  expandedHeight: isMobile ? 360 : 250,
                  floating: false,
                  pinned: true,
                  backgroundColor: _primaryColor,
                  title: FutureBuilder<User?>(
                    future: _currentUserFuture,
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      if (user != null) {
                        return Text(
                          'Welcome, ${user.firstName}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      } else {
                        return Text(
                          AppLocalizations.of(context)!.jobOpportunities,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                  actions: [
                    // Results count in collapsed state
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredJobOffers.length} jobs',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    FutureBuilder<User?>(
                      future: _currentUserFuture,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        if (user == null) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                                child: const Text('Login', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                                child: const Text('Register', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_gradientStart, _gradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 20 : 32,
                            60, // Account for app bar
                            isMobile ? 20 : 32,
                            20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.findYourDreamJob,
                                          style: GoogleFonts.inter(
                                            fontSize: isMobile ? 18 : 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.discoverOpportunitiesSkills,
                                          style: GoogleFonts.inter(
                                            fontSize: isMobile ? 13 : 14,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Search Bar
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: GoogleFonts.inter(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.searchJobs,
                                    hintStyle: GoogleFonts.inter(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: _primaryColor,
                                      size: 18,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.grey.shade600,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = '';
                                              });
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Filters - Only visible when expanded
                              _buildCollapsibleFilters(uniqueLocations, isMobile),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Job Offers List
                SliverPadding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  sliver: filteredJobOffers.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.noJobsMatchFilters,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.tryAdjustingSearchCriteria,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final jobOffer = filteredJobOffers[index];
                              return FutureBuilder<User?>(
                                future: _currentUserFuture,
                                builder: (context, userSnapshot) {
                                  final currentUser = userSnapshot.data;
                                  return _buildJobOfferCard(jobOffer, currentUser, isMobile);
                                },
                              );
                            },
                            childCount: filteredJobOffers.length,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      // Conditionally show bottom navigation bar only for connected users
      bottomNavigationBar: _isUserAuthenticated ? const MainBottomNavigationBar() : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: _primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: _primaryColor.withOpacity(0.95),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildJobOfferCard(JobOffer jobOffer, User? currentUser, bool isMobile) {
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobOffer.title ?? AppLocalizations.of(context)!.untitledPosition,
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (jobOffer.company?.name != null)
                            GestureDetector(
                              onTap: () {
                                if (jobOffer.company?.id != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/company/profile/${jobOffer.company!.id}',
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Company Logo
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _primaryColor.withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        jobOffer.company!.getProfilePicture(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                          Container(
                                            color: _primaryColor.withOpacity(0.1),
                                            child: Icon(
                                              Icons.business,
                                              size: 12,
                                              color: _primaryColor,
                                            ),
                                          ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    jobOffer.company!.name!,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 14,
                                    color: _primaryColor,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        jobOffer.jobType,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Location and Salary Row
                Row(
                  children: [
                    if (jobOffer.location.isNotEmpty) ...[
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          jobOffer.location,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    ...[
                    if (jobOffer.location.isNotEmpty)
                      const SizedBox(width: 16),
                    Icon(Icons.trending_up, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      jobOffer.experienceLevel,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  ],
                ),
                const SizedBox(height: 12),
                
                // Short description preview
                if (jobOffer.description != null && jobOffer.description!.isNotEmpty)
                  Text(
                    jobOffer.description!.length > 100
                        ? '${jobOffer.description!.substring(0, 100)}...'
                        : jobOffer.description!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (jobOffer.createdAt != null)
                        Text(
                          'Posted ${_formatDate(DateTime.fromMillisecondsSinceEpoch(jobOffer.createdAt! * 1000))}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (jobOffer.company?.id != null) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/company/profile/${jobOffer.company!.id}',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _primaryColor,
                                  side: BorderSide(color: _primaryColor),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.business, size: 14),
                                label: Text(AppLocalizations.of(context)!.company, style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/job-details/${jobOffer.id}',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.visibility, size: 14),
                              label: Text(AppLocalizations.of(context)!.seeMore, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      if (jobOffer.createdAt != null)
                        Text(
                          'Posted ${_formatDate(DateTime.fromMillisecondsSinceEpoch(jobOffer.createdAt! * 1000))}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const Spacer(),
                      if (jobOffer.company?.id != null) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/company/profile/${jobOffer.company!.id}',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryColor,
                            side: BorderSide(color: _primaryColor),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.business, size: 16),
                          label: Text(AppLocalizations.of(context)!.company),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/job-details/${jobOffer.id}',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(AppLocalizations.of(context)!.seeMore),
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
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() != 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Widget _buildCollapsibleFilters(Set<String> uniqueLocations, bool isMobile) {
    return Container(
      child: isMobile 
        ? Column( // Stack filters vertically on mobile
            children: [
              _buildCompactFilter(
                'Location',
                _selectedLocation,
                uniqueLocations.toList(),
                (value) => setState(() => _selectedLocation = value!),
                Icons.location_on,
              ),
              const SizedBox(height: 8),
              _buildCompactFilter(
                'Type',
                _selectedJobType,
                _getLocalizedJobTypes(),
                (value) => setState(() => _selectedJobType = value!),
                Icons.work,
              ),
              const SizedBox(height: 8),
              _buildCompactFilter(
                'Level',
                _selectedExperienceLevel,
                _getLocalizedExperienceLevels(),
                (value) => setState(() => _selectedExperienceLevel = value!),
                Icons.trending_up,
              ),
            ],
          )
        : Row( // Row layout for desktop
            children: [
              Expanded(
                flex: 2,
                child: _buildCompactFilter(
                  'Location',
                  _selectedLocation,
                  uniqueLocations.toList(),
                  (value) => setState(() => _selectedLocation = value!),
                  Icons.location_on,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactFilter(
                  'Type',
                  _selectedJobType,
                  _getLocalizedJobTypes(),
                  (value) => setState(() => _selectedJobType = value!),
                  Icons.work,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactFilter(
                  'Level',
                  _selectedExperienceLevel,
                  _getLocalizedExperienceLevels(),
                  (value) => setState(() => _selectedExperienceLevel = value!),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCompactFilter(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        style: GoogleFonts.inter(
          fontSize: isMobile ? 12 : 11,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 14, color: _primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          isDense: true,
        ),
        icon: const Icon(Icons.keyboard_arrow_down, size: 14),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              // Show full text on mobile since we have more width
              isMobile ? item : (
                item == AppLocalizations.of(context)!.allLocations ? AppLocalizations.of(context)!.all : 
                item == AppLocalizations.of(context)!.allTypes ? AppLocalizations.of(context)!.all :
                item == AppLocalizations.of(context)!.allLevels ? AppLocalizations.of(context)!.all : 
                item.length > 8 ? '${item.substring(0, 8)}...' : item
              ),
              style: GoogleFonts.inter(fontSize: isMobile ? 12 : 11),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}