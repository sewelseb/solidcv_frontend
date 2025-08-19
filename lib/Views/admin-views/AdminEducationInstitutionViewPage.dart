import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/admin-views/AdminBottomNavigationBar.dart';
import 'package:solid_cv/Views/components/VerificationBadge.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/EducationInstitution.dart';

class AdminEducationInstitutionViewPage extends StatefulWidget {
  final String institutionId;
  
  const AdminEducationInstitutionViewPage({super.key, required this.institutionId});

  @override
  State<AdminEducationInstitutionViewPage> createState() => _AdminEducationInstitutionViewPageState();
}

class _AdminEducationInstitutionViewPageState extends State<AdminEducationInstitutionViewPage> {
  final IEducationInstitutionBll _institutionBll = EducationInstitutionBll();
  late Future<EducationInstitution> _institutionFuture;
  
  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);
  final Color _glassBackground = Colors.white.withOpacity(0.85);
  final Color _shadowColor = Colors.deepPurple.shade50;

  @override
  void initState() {
    super.initState();
    final id = int.parse(widget.institutionId);
    _institutionFuture = _institutionBll.getEducationInstitution(id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎓 Institution Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: const AdminBottomNavigationBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder<EducationInstitution>(
        future: _institutionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading institution',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.inter(
                      color: Colors.red.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Institution not found'),
            );
          }

          final institution = snapshot.data!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _gradientStart.withOpacity(0.05),
                  _gradientEnd.withOpacity(0.02),
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: isMobile ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Institution Logo and Basic Info
                  _buildHeaderCard(institution, isMobile),
                  const SizedBox(height: 24),
                  
                  // Institution Information Grid
                  isMobile ? 
                    Column(
                      children: [
                        _buildVerificationCard(institution, isMobile),
                        const SizedBox(height: 24),
                        _buildInstitutionInfoCard(institution, isMobile),
                        const SizedBox(height: 24),
                        _buildContactInfoCard(institution, isMobile),
                        const SizedBox(height: 24),
                        _buildBlockchainInfoCard(institution, isMobile),
                        const SizedBox(height: 24),
                        _buildStatisticsCard(institution, isMobile),
                      ],
                    ) :
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildVerificationCard(institution, isMobile),
                              const SizedBox(height: 24),
                              _buildInstitutionInfoCard(institution, isMobile),
                              const SizedBox(height: 24),
                              _buildContactInfoCard(institution, isMobile),
                              const SizedBox(height: 24),
                              _buildBlockchainInfoCard(institution, isMobile),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _buildStatisticsCard(institution, isMobile),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(EducationInstitution institution, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientStart, _gradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Institution Logo
          Container(
            width: isMobile ? 80 : 120,
            height: isMobile ? 80 : 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: institution.getProfilePicture().isNotEmpty
                  ? Image.network(
                      institution.getProfilePicture(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildInstitutionIcon(isMobile),
                    )
                  : _buildInstitutionIcon(isMobile),
            ),
          ),
          const SizedBox(width: 20),
          
          // Institution Name and ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        institution.name ?? 'Unnamed Institution',
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    VerificationBadgeInline(
                      isVerified: institution.isVerified ?? false,
                      iconSize: isMobile ? 20 : 24,
                      entityName: institution.name,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Institution ID: ${institution.id}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (institution.addressCity != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          institution.addressCity!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildInstitutionIcon(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.school,
        size: isMobile ? 40 : 60,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildVerificationCard(EducationInstitution institution, bool isMobile) {
    final isVerified = institution.isVerified ?? false;
    
    return _buildSectionCard(
      'Verification Status',
      Icons.verified_user,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVerified ? Colors.green.shade200 : Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.pending,
                  color: isVerified ? Colors.green.shade600 : Colors.orange.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVerified ? 'Verified Institution' : 'Pending Verification',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        isVerified 
                          ? 'This institution has been verified by administrators'
                          : 'This institution is awaiting admin verification',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isVerified ? Colors.green.shade600 : Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Admin Actions
          Text(
            'Admin Actions',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              if (!isVerified) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyInstitution(institution),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Verify Institution'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _unverifyInstitution(institution),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Remove Verification'),
                  ),
                ),
              ],
            ],
          ),
          
          // Info Box
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verified institutions display a blue checkmark throughout the app to build trust with users.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      isMobile,
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: _glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  gradient: LinearGradient(
                    colors: [_gradientStart, _gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInstitutionInfoCard(EducationInstitution institution, bool isMobile) {
    return _buildSectionCard(
      'Institution Information',
      Icons.info_outline,
      Column(
        children: [
          _buildInfoRow('Institution Name', institution.name ?? 'Not provided'),
          _buildInfoRow('Email', institution.email ?? 'Not provided'),
          _buildInfoRow('Phone Number', institution.phoneNumber ?? 'Not provided'),
          _buildInfoRow('Type', _getInstitutionType(institution)),
        ],
      ),
      isMobile,
    );
  }

  Widget _buildContactInfoCard(EducationInstitution institution, bool isMobile) {
    return _buildSectionCard(
      'Address Information',
      Icons.location_on_outlined,
      Column(
        children: [
          _buildInfoRow('Street', '${institution.getSafeAdressNumber()} ${institution.getSafeAdressStreet()}'.trim()),
          _buildInfoRow('City', institution.getSafeAdressCity()),
          _buildInfoRow('ZIP Code', institution.getSafeAdressZipCode()),
          _buildInfoRow('Country', institution.getSafeAdressCountry()),
          if (institution.getFullAddress().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Full Address: ${institution.getFullAddress()}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      isMobile,
    );
  }

  Widget _buildBlockchainInfoCard(EducationInstitution institution, bool isMobile) {
    final hasBlockchainInfo = institution.ethereumAddress != null && institution.ethereumAddress!.isNotEmpty;
    
    return _buildSectionCard(
      'Blockchain Information',
      Icons.account_balance_wallet,
      hasBlockchainInfo
          ? Column(
              children: [
                _buildInfoRow('Ethereum Address', institution.ethereumAddress!),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Institution has blockchain capabilities for certificate management',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No blockchain address configured',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      isMobile,
    );
  }

  Widget _buildStatisticsCard(EducationInstitution institution, bool isMobile) {
    return _buildSectionCard(
      'Institution Statistics',
      Icons.analytics,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('Institution Type', _getInstitutionType(institution), Icons.school),
          _buildStatRow(
            'Blockchain Status', 
            (institution.ethereumAddress != null && institution.ethereumAddress!.isNotEmpty) 
                ? 'Enabled' 
                : 'Disabled',
            Icons.account_balance_wallet,
          ),
          _buildStatRow('Profile Status', 'Complete', Icons.check_circle),
          const SizedBox(height: 16),
          
          // Additional Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: _primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Info',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This institution can issue digital certificates and manage student credentials through the platform.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      isMobile,
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey.shade500 : Colors.black87,
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInstitutionType(EducationInstitution institution) {
    // Basic logic to determine institution type based on name
    final name = institution.name?.toLowerCase() ?? '';
    if (name.contains('university')) return 'University';
    if (name.contains('college')) return 'College';
    if (name.contains('school')) return 'School';
    if (name.contains('academy')) return 'Academy';
    if (name.contains('institute')) return 'Institute';
    return 'Educational Institution';
  }
  
  Future<void> _verifyInstitution(EducationInstitution institution) async {
    try {
      final success = await _institutionBll.verifyEducationInstitution(institution.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${institution.name} has been verified successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Refresh the institution data
        setState(() {
          _institutionFuture = _institutionBll.getEducationInstitution(institution.id!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Failed to verify institution')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  Future<void> _unverifyInstitution(EducationInstitution institution) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Verification',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove verification from ${institution.name}? This will remove the blue checkmark from all displays.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final success = await _institutionBll.unverifyEducationInstitution(institution.id!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Verification removed from ${institution.name}'),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Refresh the institution data
          setState(() {
            _institutionFuture = _institutionBll.getEducationInstitution(institution.id!);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Failed to remove verification')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
