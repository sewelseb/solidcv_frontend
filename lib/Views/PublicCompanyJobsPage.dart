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

class PublicCompanyJobsPage extends StatefulWidget {
  final String companyId;

  const PublicCompanyJobsPage({super.key, required this.companyId});

  @override
  State<PublicCompanyJobsPage> createState() => _PublicCompanyJobsPageState();
}

class _PublicCompanyJobsPageState extends State<PublicCompanyJobsPage>
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
    _jobOffersFuture = _jobOfferBll.getJobOffersByCompany(companyIdInt);

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
                    
                    return FutureBuilder<List<JobOffer>>(
                      future: _jobOffersFuture ?? Future.value([]),
                      builder: (context, jobOffersSnapshot) {
                        if (jobOffersSnapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingContent(company);
                        }

                        final jobOffers = jobOffersSnapshot.data ?? [];
                        
                        return _buildContent(context, company, jobOffers, isMobile);
                      },
                    );
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

  Widget _buildLoadingContent(Company company) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCompanyHeader(company, false),
          const SizedBox(height: 40),
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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

  Widget _buildContent(BuildContext context, Company company, List<JobOffer> jobOffers, bool isMobile) {
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
              _buildCompanyOverview(company, jobOffers, isMobile),
              const SizedBox(height: 40),
              _buildCompanyDetails(company, isMobile),
              const SizedBox(height: 40),
              _buildJobOffersSection(jobOffers, isMobile),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader(Company company, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      const SizedBox(height: 8),
                    ],
                    if (company.phoneNumber != null && company.phoneNumber!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: _primaryColor,
                            size: isMobile ? 16 : 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            company.phoneNumber!,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              color: const Color(0xFF718096),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/company/profile/${company.id}',
                    );
                  },
                  icon: const Icon(Icons.business, size: 18),
                  label: Text(AppLocalizations.of(context)!.viewFullProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Contact functionality could be added here
                    if (company.email != null) {
                      // TODO: Open email client or show contact dialog
                    }
                  },
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: BorderSide(color: _primaryColor),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 12 : 14,
                    ),
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

  Widget _buildCompanyOverview(Company company, List<JobOffer> jobOffers, bool isMobile) {
    final activeJobs = jobOffers.where((job) => job.isActive == true).length;
    final totalJobs = jobOffers.length;
    
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
          Text(
            AppLocalizations.of(context)!.companyOverview,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  AppLocalizations.of(context)!.activePositions,
                  activeJobs.toString(),
                  Icons.work,
                  Colors.green,
                  isMobile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  AppLocalizations.of(context)!.totalJobOffers,
                  totalJobs.toString(),
                  Icons.business_center,
                  Colors.blue,
                  isMobile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  AppLocalizations.of(context)!.companyStatus,
                  company.isVerified == true ? AppLocalizations.of(context)!.verifiedCompany : AppLocalizations.of(context)!.standardCompany,
                  company.isVerified == true ? Icons.verified : Icons.business,
                  company.isVerified == true ? Colors.green : Colors.orange,
                  isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 24 : 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 11 : 12,
              color: const Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetails(Company company, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _primaryColor,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.companyDetails,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (company.getFullAddress().trim().isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.home,
                    AppLocalizations.of(context)!.fullAddress,
                    company.getFullAddress(),
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                ],
                if (company.phoneNumber != null && company.phoneNumber!.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.phone,
                    AppLocalizations.of(context)!.phoneNumber,
                    company.phoneNumber!,
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                ],
                if (company.email != null && company.email!.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.email,
                    AppLocalizations.of(context)!.emailAddress,
                    company.email!,
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                ],
                if (company.ethereumAddress != null && company.ethereumAddress!.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.account_balance_wallet,
                    AppLocalizations.of(context)!.blockchainAddress,
                    '${company.ethereumAddress!.substring(0, 6)}...${company.ethereumAddress!.substring(company.ethereumAddress!.length - 4)}',
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: _primaryColor,
                      size: isMobile ? 20 : 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.verificationStatus,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A5568),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: company.isVerified == true 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: company.isVerified == true 
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      company.isVerified == true ? Icons.verified : Icons.pending,
                                      color: company.isVerified == true ? Colors.green : Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      company.isVerified == true ? AppLocalizations.of(context)!.verifiedCompany : AppLocalizations.of(context)!.standardCompany,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: company.isVerified == true ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildDetailRow(IconData icon, String label, String value, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: _primaryColor,
          size: isMobile ? 20 : 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobOffersSection(List<JobOffer> jobOffers, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.currentJobOffers,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 20 : 24,
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
          const SizedBox(height: 24),
          if (jobOffers.isEmpty)
            _buildNoJobOffersMessage(isMobile)
          else
            ...jobOffers.map((jobOffer) => _buildJobOfferCard(jobOffer, isMobile)),
        ],
      ),
    );
  }

  Widget _buildNoJobOffersMessage(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_off,
            size: isMobile ? 48 : 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noJobOffersAvailableCompany,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.companyNoOpenPositions,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 16,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                    fontSize: isMobile ? 18 : 20,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
                fontSize: isMobile ? 14 : 15,
                color: const Color(0xFF718096),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (jobOffer.id != null) {
                      Navigator.pushNamed(
                        context,
                        '/job-details/${jobOffer.id}',
                      );
                    }
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: Text(AppLocalizations.of(context)!.viewDetails),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 12 : 14,
                    ),
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
    );
  }

  Widget _buildJobInfoChip(IconData icon, String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 14 : 16,
            color: _primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w500,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
