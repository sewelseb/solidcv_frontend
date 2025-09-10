import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateJobOffer extends StatefulWidget {
  const CreateJobOffer({super.key});

  @override
  State<CreateJobOffer> createState() => _CreateJobOfferState();
}

class _CreateJobOfferState extends State<CreateJobOffer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final IJobOfferBll _jobOfferBll = JobOfferBll();
  
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  
  // Form state
  int? _companyId;
  bool _isSubmitting = false;
  bool _isActive = true;
  String _jobType = 'Full-time';
  String _experienceLevel = 'Mid-level';
  String _localizedJobType = '';
  String _localizedExperienceLevel = '';

  final Color _primaryColor = const Color(0xFF7B3FE4);
  final Color _gradientStart = const Color(0xFF7B3FE4);
  final Color _gradientEnd = const Color(0xFFB57AED);

  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance'
  ];

  final List<String> _experienceLevels = [
    'Entry-level',
    'Mid-level',
    'Senior',
    'Lead',
    'Executive'
  ];

  // Helper methods to get localized dropdown items
  List<String> _getLocalizedJobTypes(BuildContext context) {
    return [
      AppLocalizations.of(context)!.fullTime,
      AppLocalizations.of(context)!.partTime,
      AppLocalizations.of(context)!.contract,
      AppLocalizations.of(context)!.internship,
      AppLocalizations.of(context)!.freelance,
    ];
  }

  List<String> _getLocalizedExperienceLevels(BuildContext context) {
    return [
      AppLocalizations.of(context)!.entryLevel,
      AppLocalizations.of(context)!.midLevel,
      AppLocalizations.of(context)!.senior,
      AppLocalizations.of(context)!.lead,
      AppLocalizations.of(context)!.executive,
    ];
  }

  String _getLocalizedJobType(BuildContext context, String jobType) {
    switch (jobType) {
      case 'Full-time':
        return AppLocalizations.of(context)!.fullTime;
      case 'Part-time':
        return AppLocalizations.of(context)!.partTime;
      case 'Contract':
        return AppLocalizations.of(context)!.contract;
      case 'Internship':
        return AppLocalizations.of(context)!.internship;
      case 'Freelance':
        return AppLocalizations.of(context)!.freelance;
      default:
        return jobType;
    }
  }

  String _getLocalizedExperienceLevel(BuildContext context, String experienceLevel) {
    switch (experienceLevel) {
      case 'Entry-level':
        return AppLocalizations.of(context)!.entryLevel;
      case 'Mid-level':
        return AppLocalizations.of(context)!.midLevel;
      case 'Senior':
        return AppLocalizations.of(context)!.senior;
      case 'Lead':
        return AppLocalizations.of(context)!.lead;
      case 'Executive':
        return AppLocalizations.of(context)!.executive;
      default:
        return experienceLevel;
    }
  }

  String _getEnglishJobType(BuildContext context, String localizedJobType) {
    if (localizedJobType == AppLocalizations.of(context)!.fullTime) return 'Full-time';
    if (localizedJobType == AppLocalizations.of(context)!.partTime) return 'Part-time';
    if (localizedJobType == AppLocalizations.of(context)!.contract) return 'Contract';
    if (localizedJobType == AppLocalizations.of(context)!.internship) return 'Internship';
    if (localizedJobType == AppLocalizations.of(context)!.freelance) return 'Freelance';
    return localizedJobType;
  }

  String _getEnglishExperienceLevel(BuildContext context, String localizedExperienceLevel) {
    if (localizedExperienceLevel == AppLocalizations.of(context)!.entryLevel) return 'Entry-level';
    if (localizedExperienceLevel == AppLocalizations.of(context)!.midLevel) return 'Mid-level';
    if (localizedExperienceLevel == AppLocalizations.of(context)!.senior) return 'Senior';
    if (localizedExperienceLevel == AppLocalizations.of(context)!.lead) return 'Lead';
    if (localizedExperienceLevel == AppLocalizations.of(context)!.executive) return 'Executive';
    return localizedExperienceLevel;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_companyId == null) {
      final String companyIdStr = ModalRoute.of(context)!.settings.arguments as String;
      _companyId = int.parse(companyIdStr);
    }
    
    // Initialize localized values
    if (_localizedJobType.isEmpty) {
      _localizedJobType = _getLocalizedJobType(context, _jobType);
    }
    if (_localizedExperienceLevel.isEmpty) {
      _localizedExperienceLevel = _getLocalizedExperienceLevel(context, _experienceLevel);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _submitJobOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final jobOffer = JobOffer(
        id: null,
        companyId: _companyId,
        company: null,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        salary: _salaryController.text.trim().isNotEmpty
            ? double.tryParse(_salaryController.text.trim())
            : null,
        requirements: _requirementsController.text.trim().isNotEmpty ? _requirementsController.text.trim() : null,
        benefits: _benefitsController.text.trim().isNotEmpty ? _benefitsController.text.trim() : null,
        jobType: _jobType,
        experienceLevel: _experienceLevel,
        isActive: _isActive,
        createdAt: null,
      );

      await _jobOfferBll.createJobOffer(jobOffer);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.jobOfferCreatedSuccess),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorCreatingJobOffer(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
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
          AppLocalizations.of(context)!.createJobOfferTitle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: Colors.grey.shade50,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.jobDetails,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Job Title
                      _buildTextField(
                        controller: _titleController,
                        label: AppLocalizations.of(context)!.jobTitle,
                        icon: Icons.work,
                        required: true,
                        hint: AppLocalizations.of(context)!.jobTitleHint,
                      ),
                      const SizedBox(height: 20),

                      // Location
                      _buildTextField(
                        controller: _locationController,
                        label: AppLocalizations.of(context)!.location,
                        icon: Icons.location_on,
                        required: true,
                        hint: AppLocalizations.of(context)!.locationHint,
                      ),
                      const SizedBox(height: 20),

                      // Job Type and Experience Level
                      isMobile
                          ? Column(
                              children: [
                                _buildDropdownField(
                                  label: AppLocalizations.of(context)!.jobType,
                                  value: _localizedJobType,
                                  items: _getLocalizedJobTypes(context),
                                  onChanged: (value) {
                                    setState(() {
                                      _localizedJobType = value!;
                                      _jobType = _getEnglishJobType(context, value);
                                    });
                                  },
                                  icon: Icons.schedule,
                                ),
                                const SizedBox(height: 20),
                                _buildDropdownField(
                                  label: AppLocalizations.of(context)!.experienceLevel,
                                  value: _localizedExperienceLevel,
                                  items: _getLocalizedExperienceLevels(context),
                                  onChanged: (value) {
                                    setState(() {
                                      _localizedExperienceLevel = value!;
                                      _experienceLevel = _getEnglishExperienceLevel(context, value);
                                    });
                                  },
                                  icon: Icons.trending_up,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    label: AppLocalizations.of(context)!.jobType,
                                    value: _localizedJobType,
                                    items: _getLocalizedJobTypes(context),
                                    onChanged: (value) {
                                      setState(() {
                                        _localizedJobType = value!;
                                        _jobType = _getEnglishJobType(context, value);
                                      });
                                    },
                                    icon: Icons.schedule,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    label: AppLocalizations.of(context)!.experienceLevel,
                                    value: _localizedExperienceLevel,
                                    items: _getLocalizedExperienceLevels(context),
                                    onChanged: (value) {
                                      setState(() {
                                        _localizedExperienceLevel = value!;
                                        _experienceLevel = _getEnglishExperienceLevel(context, value);
                                      });
                                    },
                                    icon: Icons.trending_up,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 20),

                      // Salary (Optional)
                      _buildTextField(
                        controller: _salaryController,
                        label: AppLocalizations.of(context)!.salaryOptional,
                        icon: Icons.attach_money,
                        hint: AppLocalizations.of(context)!.salaryHint,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: AppLocalizations.of(context)!.jobDescription,
                        icon: Icons.description,
                        required: true,
                        maxLines: 6,
                        hint: AppLocalizations.of(context)!.jobDescriptionHint,
                      ),
                      const SizedBox(height: 20),

                      // Requirements
                      _buildTextField(
                        controller: _requirementsController,
                        label: AppLocalizations.of(context)!.requirementsOptional,
                        icon: Icons.checklist,
                        maxLines: 4,
                        hint: AppLocalizations.of(context)!.requirementsHint,
                      ),
                      const SizedBox(height: 20),

                      // Benefits
                      _buildTextField(
                        controller: _benefitsController,
                        label: AppLocalizations.of(context)!.benefitsOptional,
                        icon: Icons.star,
                        maxLines: 3,
                        hint: AppLocalizations.of(context)!.benefitsHint,
                      ),
                      const SizedBox(height: 24),

                      // Active Status
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.jobStatus,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.activeJobsVisible,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isActive,
                              onChanged: (value) => setState(() => _isActive = value),
                              activeColor: _primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitJobOffer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.publish),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(_isSubmitting ? AppLocalizations.of(context)!.creating : AppLocalizations.of(context)!.createJobOffer),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: _primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.fieldRequired(label);
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
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
            Icon(icon, size: 18, color: _primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}