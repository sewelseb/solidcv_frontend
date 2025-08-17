import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Certificate.dart';
// Import your Certificate model here - adjust the path as needed
// import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/Certificate/ManualCertificate.dart';

class CertificateEditStep extends StatefulWidget {
  final Function(List<Certificate>) onComplete; // Changed to ManualCertificate
  final bool isActive;

  const CertificateEditStep({
    super.key,
    required this.onComplete,
    required this.isActive,
  });

  @override
  State<CertificateEditStep> createState() => _CertificateEditStepState();
}

class _CertificateEditStepState extends State<CertificateEditStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  IUserBLL _userBll = UserBll();

  // Keep the future for loading
  late Future<List<Certificate>> _certificatesFuture;
  // Use a regular list for editing
  List<Certificate> _certificates = [];
  bool _isInitialized = false;
  bool _buttonHidden = false;

  @override
  void initState() {
    super.initState();
    _certificatesFuture = _userBll
        .getMyManuallyAddedCertificates(); // Assuming this method exists

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

  void _removeCertificate(String id) {
    _userBll.deleteManualyAddedCertificate(int.parse(id));
    setState(() {
      _certificates.removeWhere((cert) => cert.id == id);
    });
  }

  void _submitCertificates() {
    setState(() {
      _buttonHidden = true;
    });
    widget.onComplete(_certificates);
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
                Icons.school,
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
                child: FutureBuilder<List<Certificate>>(
                  future: _certificatesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your certificates...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      // Initialize empty list on error so user can still add certificates
                      if (!_isInitialized) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _certificates = [];
                            _isInitialized = true;
                          });
                        });
                      }

                      return Column(
                        children: [
                          Icon(Icons.error,
                              color: Colors.red.shade400, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading certificates',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can still add certificates manually',
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
                          _certificates = List.from(snapshot.data!);
                          _isInitialized = true;
                        });
                      });
                    }

                    return _buildCertificateContent();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Certificates',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You have ${_certificates.length} certificate${_certificates.length != 1 ? 's' : ''}. Please review and edit them as needed.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Certificate list
        if (_certificates.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.school_outlined,
                    color: Colors.grey.shade400, size: 32),
                const SizedBox(height: 8),
                Text(
                  'No certificates found',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your professional certifications manually',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...List.generate(_certificates.length, (index) {
            return _buildCertificateCard(index);
          }),
        ],

        const SizedBox(height: 16),

        // Continue button
        if (!_buttonHidden)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitCertificates,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B3FE4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Continue to Skills'),
            ),
          ),
      ],
    );
  }

  Widget _buildCertificateCard(int index) {
    final certificate = _certificates[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: Colors.orange.shade600,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.title?.isNotEmpty == true
                          ? certificate.title!
                          : 'Certificate title',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    if (certificate.teachingInstitutionName?.isNotEmpty ==
                        true) ...[
                      Text(
                        'Issued by ${certificate.teachingInstitutionName}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeCertificate(certificate.id!),
                icon: Icon(Icons.delete, color: Colors.red.shade400, size: 16),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Certificate details
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (certificate.publicationDate != null) ...[
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(certificate),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (certificate.description?.isNotEmpty == true) ...[
                  Text(
                    certificate.description!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Edit button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _editCertificate(index),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              icon: const Icon(Icons.edit, size: 12),
              label: const Text('Edit Details', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(Certificate certificate) {
    String issueDate = '';
    String expiryDate = '';

    if (certificate.publicationDate != null) {
      final date = certificate.publicationDate!;
      issueDate = date;
    }

    if (issueDate.isNotEmpty) {
      try {
        final DateTime? parsedDate =
            DateTime.fromMillisecondsSinceEpoch(int.parse(issueDate) * 1000);
        if (parsedDate != null) {
          return 'Issued: ${parsedDate.month}/${parsedDate.year}';
        }
      } catch (e) {
        return 'Issued: $issueDate';
      }
    }
    return 'Issued: $issueDate';
  }

  void _editCertificate(int index) {
    final certificate = _certificates[index];

    showDialog(
      context: context,
      builder: (context) => _CertificateEditDialog(
        certificate: certificate,
        onSave: (updatedCertificate) {
          setState(() {
            _certificates[index] = updatedCertificate;
          });
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

// Certificate Edit Dialog - Updated to work with ManualCertificate
class _CertificateEditDialog extends StatefulWidget {
  final Certificate certificate;
  final Function(Certificate) onSave;

  const _CertificateEditDialog({
    required this.certificate,
    required this.onSave,
  });

  @override
  State<_CertificateEditDialog> createState() => _CertificateEditDialogState();
}

class _CertificateEditDialogState extends State<_CertificateEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _issuerController;
  late TextEditingController _credentialIdController;
  late TextEditingController _descriptionController;
  late DateTime _issueDate;
  final UserBll _userBll = UserBll();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.certificate.title ?? '');
    _issuerController = TextEditingController(
        text: widget.certificate.teachingInstitutionName ?? '');
    _credentialIdController =
        TextEditingController(text: widget.certificate.id ?? '');
    _descriptionController =
        TextEditingController(text: widget.certificate.description ?? '');

    var date = 0;
    try {
      date = int.parse(widget.certificate.publicationDate ?? '0');
    } catch (e) {
      date = 0;
    }

    _issueDate = widget.certificate.publicationDate != null
        ? DateTime.fromMillisecondsSinceEpoch(date * 1000)
        : DateTime.now();
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
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.school,
                      color: Colors.orange.shade600, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Certificate',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Update your certification details',
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
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Certificate Name *',
                      hint: 'e.g., AWS Certified Developer',
                      icon: Icons.workspace_premium,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _issuerController,
                      label: 'Issuing Organization *',
                      hint: 'e.g., Amazon Web Services',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),

                    // Date fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Issue Date *',
                            date: _issueDate,
                            onDateSelected: (date) {
                              setState(() {
                                _issueDate = date;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint:
                          'Brief description of skills and knowledge covered...',
                      icon: Icons.description,
                      maxLines: 3,
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
                    onPressed: _saveCertificate,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF7B3FE4),
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
                Icon(Icons.calendar_today,
                    size: 20, color: Colors.grey.shade500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${date.month}/${date.year}',
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

  void _saveCertificate() {
    // Validate required fields
    if (_nameController.text.trim().isEmpty ||
        _issuerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // Create updated certificate
    final updatedCertificate = Certificate(
      id: widget.certificate.id,
      title: _nameController.text.trim(),
      teachingInstitutionName: _issuerController.text.trim(),
      publicationDate: _issueDate.toIso8601String(),
      description: _descriptionController.text.trim(),
      // Add other required fields based on your ManualCertificate model
    );

    _userBll.updateManuallyAddedCertificate(updatedCertificate);

    widget.onSave(updatedCertificate);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _credentialIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
