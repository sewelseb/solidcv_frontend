import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';

class ExperienceEditStep extends StatefulWidget {
  final Function(List<ManualExperience>) onComplete;
  final bool isActive;

  const ExperienceEditStep({
    super.key,
    required this.onComplete,
    required this.isActive,
  });

  @override
  State<ExperienceEditStep> createState() => _ExperienceEditStepState();
}

class _ExperienceEditStepState extends State<ExperienceEditStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final IUserBLL _userBll = UserBll();
  
  // Keep the future for loading
  late Future<List<ManualExperience>> _experiencesFuture;
  // Use a regular list for editing
  List<ManualExperience> _experiences = [];
  bool _isInitialized = false; // Add this flag to prevent multiple initializations
  bool _buttonHidden = false;

  @override
  void initState() {
    super.initState();
    _experiencesFuture = _userBll.getMyManuallyAddedExperiences();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.isActive) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _animationController.forward();
      });
    }
  }

  void _addExperience() {
    setState(() {
      // Create a new ManualExperience object and add to the regular list
      _experiences.add(ManualExperience(
        title: '',
        company: '',
        startDateAsTimestamp: DateTime.now().millisecondsSinceEpoch,
        endDateAsTimestamp: DateTime.now().millisecondsSinceEpoch,
        description: '',
        promotions: [],
      ));
    });
  }

  void _removeExperience(int id) {
    _userBll.deleteManualExperience(id);
    setState(() {
      _experiences.removeWhere((exp) => exp.id == id);
    });
  }

  void _submitExperiences() {
    setState(() {
      _buttonHidden = true;
    });
    widget.onComplete(_experiences);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.work,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Message bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FutureBuilder<List<ManualExperience>>(
                  future: _experiencesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your experiences...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    if (snapshot.hasError) {
                      // Initialize empty list on error so user can still add experiences
                      if (!_isInitialized) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _experiences = [];
                            _isInitialized = true;
                          });
                        });
                      }
                      
                      return Column(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade400, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading experiences',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can still add experiences manually',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    // Initialize the editable list once when data loads
                    if (snapshot.hasData && !_isInitialized) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _experiences = List.from(snapshot.data!);
                          _isInitialized = true;
                        });
                      });
                    }
                    
                    return _buildExperienceContent();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Experience',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You have ${_experiences.length} work experience${_experiences.length != 1 ? 's' : ''}. Please review and edit them as needed.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        
        // Experience list
        if (_experiences.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.work_off, color: Colors.grey.shade400, size: 32),
                const SizedBox(height: 8),
                Text(
                  'No experience found',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...List.generate(_experiences.length, (index) {
            return _buildExperienceCard(index);
          }),
        ],
        
        
        
        const SizedBox(height: 16),
        
        // Continue button
        if (!_buttonHidden)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitExperiences,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B3FE4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Continue to Certificates'),
            ),
          ),
      ],
    );
  }

  Widget _buildExperienceCard(int index) {
    final experience = _experiences[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  experience.title?.isNotEmpty == true ? experience.title! : 'Position Title',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeExperience(experience.id!),
                icon: Icon(Icons.delete, color: Colors.red.shade400, size: 16),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (experience.company?.isNotEmpty == true) ...[
            Text(
              experience.company!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.blue.shade600,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${_formatDate(DateTime.fromMillisecondsSinceEpoch((experience.startDateAsTimestamp ?? 0)*1000))} - ${(experience.endDateAsTimestamp == null || experience.endDateAsTimestamp == 0) ? 'Present' : _formatDate(DateTime.fromMillisecondsSinceEpoch(experience.endDateAsTimestamp! *1000))}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          if (experience.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              experience.description ?? '',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _editExperience(index),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text('Edit Details', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editExperience(int index) {
    final experience = _experiences[index];
    
    showDialog(
      context: context,
      builder: (context) => _ExperienceEditDialog(
        experience: experience,
        onSave: (updatedExperience) {
          print('Saving updated experience: ${updatedExperience.title}'); // Debug line
          print('New start date: ${DateTime.fromMillisecondsSinceEpoch(updatedExperience.startDateAsTimestamp! * 1000)}'); // Debug line
          print('New end date: ${updatedExperience.endDateAsTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(updatedExperience.endDateAsTimestamp! * 1000) : 'Current job'}'); // Debug line
          setState(() {
            _experiences[index] = updatedExperience;
          });
          print('Experience updated in list'); // Debug line
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Add this new dialog class at the bottom of the file, outside the main class
class _ExperienceEditDialog extends StatefulWidget {
  final ManualExperience experience;
  final Function(ManualExperience) onSave;
  

  const _ExperienceEditDialog({
    required this.experience,
    required this.onSave,
  });

  @override
  State<_ExperienceEditDialog> createState() => _ExperienceEditDialogState();
}

class _ExperienceEditDialogState extends State<_ExperienceEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isCurrentJob = false;
  final UserBll _userBll = UserBll();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.experience.title ?? '');
    _companyController = TextEditingController(text: widget.experience.company ?? '');
    _descriptionController = TextEditingController(text: widget.experience.description ?? '');
    
    _startDate = widget.experience.startDateAsTimestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(widget.experience.startDateAsTimestamp!*1000)
        : DateTime.now();
    
    if (widget.experience.endDateAsTimestamp == null || widget.experience.endDateAsTimestamp == 0) {
      _isCurrentJob = true;
      _endDate = DateTime.now(); // Set to now if it's a current job
    } else {
      _isCurrentJob = false;
      _endDate = DateTime.fromMillisecondsSinceEpoch(widget.experience.endDateAsTimestamp! * 1000);
    }

    
    // Check if this is a current job (end date is very recent or in future)

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.work, color: Colors.blue.shade600, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Experience',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Update your work experience details',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Title
                    _buildTextField(
                      controller: _titleController,
                      label: 'Job Title *',
                      hint: 'e.g., Senior Software Engineer',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    
                    // Company
                    _buildTextField(
                      controller: _companyController,
                      label: 'Company *',
                      hint: 'e.g., Google, Microsoft, Apple',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Start Date *',
                            date: _startDate,
                            onDateSelected: (date) {
                              print('Start date selected: $date'); // Debug line
                              setState(() {
                                _startDate = date;
                                print('Start date updated to: $_startDate'); // Debug line
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _isCurrentJob 
                              ? Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.work, color: Colors.green.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Current Position',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _buildDateField(
                                  label: 'End Date *',
                                  date: _endDate,
                                  onDateSelected: (date) {
                                    print('End date selected: $date'); // Debug line
                                    setState(() {
                                      _endDate = date;
                                      print('End date updated to: $_endDate'); // Debug line
                                    });
                                  },
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Current job checkbox
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isCurrentJob,
                            onChanged: (value) {
                              setState(() {
                                _isCurrentJob = value ?? false;
                                if (_isCurrentJob) {
                                  _endDate = DateTime.now();
                                }
                              });
                            },
                            activeColor: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'I currently work here',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  'Check this if this is your current position',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Job Description',
                      hint: 'Describe your responsibilities, achievements, and key projects...',
                      icon: Icons.description_outlined,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    
                    // Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Writing Tips',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Use action verbs (developed, managed, implemented)\n• Include quantifiable achievements\n• Focus on results and impact',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.amber.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveExperience,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3FE4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1950),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary:  Color(0xFF7B3FE4),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              print('Date picked: $picked'); // Debug line
              onDateSelected(picked);
            }
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveExperience() {
    // Validate required fields
    if (_titleController.text.trim().isEmpty || _companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // Create updated experience
    final updatedExperience = ManualExperience(
      id: widget.experience.id,
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      startDateAsTimestamp: (_startDate.millisecondsSinceEpoch / 1000).round(),
      endDateAsTimestamp: _isCurrentJob ? 0 : (_endDate.millisecondsSinceEpoch / 1000).round(),
      description: _descriptionController.text.trim(),
      promotions: widget.experience.promotions, // Keep existing promotions
    );

    _userBll.updateManuallyAddedExperience(updatedExperience);

    widget.onSave(updatedExperience);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}