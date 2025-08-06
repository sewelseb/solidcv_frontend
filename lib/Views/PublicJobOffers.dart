import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/models/User.dart';

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
  
  String _searchQuery = '';
  String _selectedLocation = 'All Locations';
  String _selectedJobType = 'All Types';
  String _selectedExperienceLevel = 'All Levels';
  
  final TextEditingController _searchController = TextEditingController();
  
  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);

  final List<String> _jobTypes = [
    'All Types',
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance'
  ];

  final List<String> _experienceLevels = [
    'All Levels',
    'Entry-level',
    'Mid-level',
    'Senior',
    'Lead',
    'Executive'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
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
      if (_selectedLocation != 'All Locations' && 
          jobOffer.location != _selectedLocation) {
        return false;
      }

      // Job type filter
      if (_selectedJobType != 'All Types' && 
          jobOffer.jobType != _selectedJobType) {
        return false;
      }

      // Experience level filter
      if (_selectedExperienceLevel != 'All Levels' && 
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
    return {'All Locations', ...locations};
  }

  Future<void> _applyToJob(JobOffer jobOffer, User? currentUser) async {
    if (currentUser == null) {
      _showLoginDialog();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply to ${jobOffer.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${jobOffer.company?.name ?? 'Unknown'}'),
            Text('Location: ${jobOffer.location ?? 'Not specified'}'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to apply to this position?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _jobOfferBll.applyToJobOffer(jobOffer.id!);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: $e'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Opportunities',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          FutureBuilder<User?>(
            future: _currentUserFuture,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: Text(
                      'Welcome, ${user.firstName}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              } else {
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
            },
          ),
        ],
      ),
      // Conditionally show bottom navigation bar only for connected users
      bottomNavigationBar: FutureBuilder<User?>(
        future: _currentUserFuture,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) {
            return const MainBottomNavigationBar();
          } else {
            return const SizedBox.shrink(); // No bottom navigation bar for non-connected users
          }
        },
      ),
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
                    Text('Error loading job offers: ${snapshot.error}'),
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
                      'No job offers available',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new opportunities',
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

            return Column(
              children: [
                // Search and Filter Section
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search jobs, companies, or keywords...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _primaryColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Filters
                      isMobile
                          ? Column(
                              children: [
                                _buildFilterDropdown(
                                  label: 'Location',
                                  value: _selectedLocation,
                                  items: uniqueLocations.toList(),
                                  onChanged: (value) => setState(() => _selectedLocation = value!),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFilterDropdown(
                                        label: 'Type',
                                        value: _selectedJobType,
                                        items: _jobTypes,
                                        onChanged: (value) => setState(() => _selectedJobType = value!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildFilterDropdown(
                                        label: 'Level',
                                        value: _selectedExperienceLevel,
                                        items: _experienceLevels,
                                        onChanged: (value) => setState(() => _selectedExperienceLevel = value!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildFilterDropdown(
                                    label: 'Location',
                                    value: _selectedLocation,
                                    items: uniqueLocations.toList(),
                                    onChanged: (value) => setState(() => _selectedLocation = value!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Type',
                                    value: _selectedJobType,
                                    items: _jobTypes,
                                    onChanged: (value) => setState(() => _selectedJobType = value!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Level',
                                    value: _selectedExperienceLevel,
                                    items: _experienceLevels,
                                    onChanged: (value) => setState(() => _selectedExperienceLevel = value!),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                
                // Results
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredJobOffers.length} Job${filteredJobOffers.length != 1 ? 's' : ''} Found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredJobOffers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No jobs match your filters',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search criteria',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredJobOffers.length,
                                  itemBuilder: (context, index) {
                                    final jobOffer = filteredJobOffers[index];
                                    return FutureBuilder<User?>(
                                      future: _currentUserFuture,
                                      builder: (context, userSnapshot) {
                                        final currentUser = userSnapshot.data;
                                        return _buildJobOfferCard(jobOffer, currentUser, isMobile);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
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
                            jobOffer.title ?? 'Untitled Position',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (jobOffer.company?.name != null)
                            Text(
                              jobOffer.company!.name!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
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
                    if (jobOffer.location != null && jobOffer.location!.isNotEmpty)
                      const SizedBox(width: 16),
                    Icon(Icons.trending_up, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      jobOffer.experienceLevel!,
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
            child: Row(
              children: [
                if (jobOffer.createdAt != null)
                  Text(
                    'Posted ${_formatDate(DateTime.fromMillisecondsSinceEpoch(jobOffer.createdAt!))}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const Spacer(),
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
                  label: const Text('See More'),
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
}