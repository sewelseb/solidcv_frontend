import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';

class PublicCompanyProfilePage extends StatefulWidget {
  final String companyId;

  const PublicCompanyProfilePage({super.key, required this.companyId});

  @override
  State<PublicCompanyProfilePage> createState() => _PublicCompanyProfilePageState();
}

class _PublicCompanyProfilePageState extends State<PublicCompanyProfilePage>
    with TickerProviderStateMixin {
  final ICompanyBll _companyBll = CompanyBll();
  final IJobOfferBll _jobOfferBll = JobOfferBll();

  late Future<Company> _companyFuture;
  Future<List<JobOffer>>? _jobOffersFuture;
  bool _isUserAuthenticated = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    final int companyIdInt = int.tryParse(widget.companyId) ?? 0;
    _companyFuture = _companyBll.getCompany(companyIdInt);
    _jobOffersFuture = _jobOfferBll.getAllPublicJobOffersByCompany(companyIdInt);

    _checkUserAuthentication();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_gradientStart, _gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isMobile),
              Expanded(
                child: FutureBuilder<Company>(
                  future: _companyFuture,
                  builder: (context, companySnapshot) {
                    if (companySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    
                    if (companySnapshot.hasError) {
                      return _buildErrorWidget(AppLocalizations.of(context)!.companyNotFoundOrError);
                    }

                    if (!companySnapshot.hasData) {
                      return _buildErrorWidget(AppLocalizations.of(context)!.companyNotFound);
                    }

                    final company = companySnapshot.data!;
                    
                    return _buildContent(context, company, isMobile);
                  },
                ),
              ),
              if (_isUserAuthenticated) const MainBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            AppLocalizations.of(context)!.companyProfile,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _glassBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Company company, bool isMobile) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyHeader(company, isMobile),
              const SizedBox(height: 40),
              _buildCompanyStats(company, isMobile),
              const SizedBox(height: 40),
              _buildJobOffersSection(company, isMobile),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader(Company company, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: _glassBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 100 : 140,
                height: isMobile ? 100 : 140,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    company.getProfilePicture(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildCompanyInitials(company, isMobile),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 16 : 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company.name ?? AppLocalizations.of(context)!.unknownCompanyFallback,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        if (company.isVerified == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: isMobile ? 16 : 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (company.addressCity != null && company.addressCountry != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _primaryColor,
                            size: isMobile ? 16 : 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${company.addressCity}, ${company.addressCountry}',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              color: const Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (company.email != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: _primaryColor,
                            size: isMobile ? 16 : 20,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              company.email!,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 14 : 16,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.companyInformation,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                if (company.getFullAddress().trim().isNotEmpty) ...[
                  _buildInfoRow(
                    Icons.home,
                    'Address',
                    company.getFullAddress(),
                    isMobile,
                  ),
                  const SizedBox(height: 12),
                ],
                if (company.phoneNumber != null && company.phoneNumber!.isNotEmpty) ...[
                  _buildInfoRow(
                    Icons.phone,
                    'Phone',
                    company.phoneNumber!,
                    isMobile,
                  ),
                  const SizedBox(height: 12),
                ],
                if (company.email != null && company.email!.isNotEmpty) ...[
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    company.email!,
                    isMobile,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInitials(Company company, bool isMobile) {
    final initials = company.name != null && company.name!.isNotEmpty
        ? company.name!.split(' ').map((word) => word[0]).take(2).join().toUpperCase()
        : 'C';
    
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: isMobile ? 40 : 56,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: _primaryColor,
          size: isMobile ? 18 : 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyStats(Company company, bool isMobile) {
    return FutureBuilder<List<JobOffer>>(
      future: _jobOffersFuture ?? Future.value([]),
      builder: (context, snapshot) {
        final jobOffers = snapshot.data ?? [];
        final activeJobs = jobOffers.where((job) => job.isActive == true).length;
        
        return Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            color: _glassBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(AppLocalizations.of(context)!.activeJobs, activeJobs.toString(), Icons.work, isMobile),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(AppLocalizations.of(context)!.totalJobs, jobOffers.length.toString(), Icons.business_center, isMobile),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Verified', company.isVerified == true ? 'Yes' : 'No', Icons.verified_user, isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _primaryColor,
            size: isMobile ? 24 : 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 12 : 14,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobOffersSection(Company company, bool isMobile) {
    return FutureBuilder<List<JobOffer>>(
      future: _jobOffersFuture ?? Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              color: _glassBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final jobOffers = snapshot.data ?? [];
        
        return Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            color: _glassBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work,
                    color: _primaryColor,
                    size: isMobile ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.currentJobOffers,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${jobOffers.length} position${jobOffers.length != 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (jobOffers.isEmpty)
                _buildNoJobOffersMessage(isMobile)
              else
                ...jobOffers.take(isMobile ? 3 : 5).map((jobOffer) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJobOfferCard(jobOffer, isMobile),
                  )
                ),
              if (jobOffers.length > (isMobile ? 3 : 5)) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/company/jobs/${company.id}',
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text(AppLocalizations.of(context)!.viewAllJobOffers(jobOffers.length.toString())),
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoJobOffersMessage(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_off,
            size: isMobile ? 40 : 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noJobOffersAvailableCompany,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.companyNoOpenPositions,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 15,
              color: Colors.grey.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobOfferCard(JobOffer jobOffer, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  jobOffer.title ?? AppLocalizations.of(context)!.untitledPosition,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              if (jobOffer.isActive == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildJobInfoChip(Icons.location_on, jobOffer.location, isMobile),
              const SizedBox(width: 8),
              _buildJobInfoChip(Icons.work, jobOffer.jobType, isMobile),
              const SizedBox(width: 8),
              _buildJobInfoChip(Icons.trending_up, jobOffer.experienceLevel, isMobile),
            ],
          ),
          if (jobOffer.salary != null) ...[
            const SizedBox(height: 8),
            _buildJobInfoChip(Icons.attach_money, '\$${jobOffer.salary!.toStringAsFixed(0)}', isMobile),
          ],
          if (jobOffer.description != null && jobOffer.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              jobOffer.description!,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF718096),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (jobOffer.id != null) {
                      Navigator.pushNamed(
                        context,
                        '/job-details/${jobOffer.id}',
                      );
                    }
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text(AppLocalizations.of(context)!.viewDetails),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: BorderSide(color: _primaryColor),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 8 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoChip(IconData icon, String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 12 : 14,
            color: _primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
