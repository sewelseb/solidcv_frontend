import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/JobOfferBll.dart';
import 'package:solid_cv/business_layer/IJobOfferBll.dart';
import 'package:solid_cv/models/JobOffer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditJobOffer extends StatefulWidget {
  const EditJobOffer({super.key});

  @override
  State<EditJobOffer> createState() => _EditJobOfferState();
}

class _EditJobOfferState extends State<EditJobOffer> {
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
  int? _jobOfferId;
  JobOffer? _originalJobOffer;
  Future<JobOffer>? _jobOfferFuture;
  bool _isSubmitting = false;
  bool _isActive = true;
  String _jobType = 'Full-time';
  String _experienceLevel = 'Mid-level';
  bool _isLoaded = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_jobOfferFuture == null) {
      final String jobOfferIdStr = ModalRoute.of(context)!.settings.arguments as String;
      _jobOfferId = int.parse(jobOfferIdStr);
      _jobOfferFuture = _jobOfferBll.getJobOfferById(_jobOfferId!);
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

  void _populateForm(JobOffer jobOffer) {
    if (_isLoaded) return;
    
    _originalJobOffer = jobOffer;
    _titleController.text = jobOffer.title ?? '';
    _descriptionController.text = jobOffer.description ?? '';
    _locationController.text = jobOffer.location ?? '';
    _salaryController.text = jobOffer.salary != null ? jobOffer.salary!.toString() : '';
    _requirementsController.text = jobOffer.requirements ?? '';
    _benefitsController.text = jobOffer.benefits ?? '';
    
    // Remove setState and update variables directly
    _isActive = jobOffer.isActive ?? true;
    _jobType = jobOffer.jobType ?? 'Full-time';
    _experienceLevel = jobOffer.experienceLevel ?? 'Mid-level';
    _isLoaded = true;
  }

  Future<void> _updateJobOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedJobOffer = JobOffer(
        id: _jobOfferId,
        companyId: _originalJobOffer!.companyId,
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
        createdAt: _originalJobOffer!.createdAt,
      );

      await _jobOfferBll.updateJobOffer(updatedJobOffer);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job offer updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating job offer: $e'),
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

  Future<void> _deleteJobOffer() async {
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
        await _jobOfferBll.deleteJobOffer(_jobOfferId!);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job offer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting job offer: $e'),
            backgroundColor: Colors.red,
          ),
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
          AppLocalizations.of(context)!.editJobOfferTitle,
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
            icon: const Icon(Icons.delete),
            onPressed: _deleteJobOffer,
            tooltip: AppLocalizations.of(context)!.deleteJobOfferTooltip,
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
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
                  Text('${AppLocalizations.of(context)!.errorText}: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _jobOfferFuture = _jobOfferBll.getJobOfferById(_jobOfferId!);
                        _isLoaded = false;
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.retryText),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Job offer not found'),
            );
          }

          final jobOffer = snapshot.data!;
          
          // Use WidgetsBinding to schedule the form population after the build
          if (!_isLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateForm(jobOffer);
              setState(() {}); // Trigger a rebuild after populating the form
            });
          }

          return Form(
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.editJobOfferTitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isActive ? Colors.green.shade100 : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _isActive ? Colors.green.shade700 : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Only show the form content if data is loaded
                          if (_isLoaded) ...[
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
                                        value: _jobType,
                                        items: _jobTypes,
                                        onChanged: (value) => setState(() => _jobType = value!),
                                        icon: Icons.schedule,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildDropdownField(
                                        label: AppLocalizations.of(context)!.experienceLevel,
                                        value: _experienceLevel,
                                        items: _experienceLevels,
                                        onChanged: (value) => setState(() => _experienceLevel = value!),
                                        icon: Icons.trending_up,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _buildDropdownField(
                                          label: AppLocalizations.of(context)!.jobType,
                                          value: _jobType,
                                          items: _jobTypes,
                                          onChanged: (value) => setState(() => _jobType = value!),
                                          icon: Icons.schedule,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDropdownField(
                                          label: AppLocalizations.of(context)!.experienceLevel,
                                          value: _experienceLevel,
                                          items: _experienceLevels,
                                          onChanged: (value) => setState(() => _experienceLevel = value!),
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

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isSubmitting ? null : _deleteJobOffer,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.delete),
                                    label: Text(AppLocalizations.of(context)!.delete),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: _isSubmitting ? null : _updateJobOffer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryColor,
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                                        : const Icon(Icons.save),
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(_isSubmitting ? AppLocalizations.of(context)!.updating : AppLocalizations.of(context)!.updateJobOffer),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            // Show loading indicator while form is being populated
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
                    return '$label is required';
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