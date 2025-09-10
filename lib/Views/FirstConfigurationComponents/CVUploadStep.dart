import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';

class CVUploadStep extends StatefulWidget {
  final Function(String? cvPath, Map<String, dynamic>? extractedData) onComplete;
  final VoidCallback onSkip;
  final bool isActive;

  const CVUploadStep({
    super.key,
    required this.onComplete,
    required this.onSkip,
    required this.isActive,
  });

  @override
  State<CVUploadStep> createState() => _CVUploadStepState();
}

class _CVUploadStepState extends State<CVUploadStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final UserBll _userBll = UserBll();

  String? _uploadedFileName;
  String? _uploadedFilePath;
  Map<String, dynamic>? _extractedData;
  bool _isUploading = false;
  bool _isExtracting = false;
  bool _buttonsHidden = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickCV() async {
    try {
      setState(() {
        _isUploading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        PlatformFile file = result.files.single;
        
        // Use the userBll to upload the CV
        String uploadedPath = await _userBll.uploadCV(file);
        
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFilePath = uploadedPath;
          _isUploading = false;
          _isExtracting = true;
        });
        
        // Extract CV data
        await _extractCVData();
        
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadedFileName = null;
        _uploadedFilePath = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorUploadingCV} ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _extractCVData() async {
    try {
      // TODO: The uploadCV method already returns the extracted data
      // Parse the response from uploadCV to get the structured data
      // For now, using mock data structure
      Map<String, dynamic> extractedData = {
        'experiences': [], // TODO: Get from uploadCV response
        'certificates': [], // TODO: Get from uploadCV response  
        'skills': [], // TODO: Get from uploadCV response
      };
      
      setState(() {
        _extractedData = extractedData;
        _isExtracting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cvDataExtractedSuccessfully),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isExtracting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorExtractingCVData} ${e.toString()}'),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Still allow user to continue without extracted data
        setState(() {
          _extractedData = {
            'experiences': [],
            'certificates': [],
            'skills': [],
          };
        });
      }
    }
  }

  void _submitCV() {
    setState(() {
      _buttonsHidden = true;
    });
    widget.onComplete(_uploadedFilePath, _extractedData);
  }

  void _skipUpload() {
    setState(() {
      _buttonsHidden = true;
    });
    // Create empty data structure for manual entry
    Map<String, dynamic> emptyData = {
      'experiences': <Map<String, dynamic>>[],
      'certificates': <Map<String, dynamic>>[],
      'skills': <Map<String, dynamic>>[],
    };
    
    // Call onComplete with null CV path and empty data structure
    widget.onComplete(null, emptyData);
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
                Icons.upload_file,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.cvUploadOptional,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.cvUploadDescription,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Upload area
                    if (_uploadedFileName == null && !_isUploading) ...[
                      GestureDetector(
                        onTap: _pickCV,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B3FE4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload,
                                  color: Color(0xFF7B3FE4),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.clickToUploadCV,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.pdfOnlyAutoExtract,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    // Uploading state
                    if (_isUploading) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.uploadingYourCV,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Extracting data state
                    if (_isExtracting) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.extractingCVData,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.purple.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.extractionMayTakeMoments,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.purple.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Upload and extraction success
                    if (_uploadedFileName != null && _extractedData != null && !_isExtracting) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.cvProcessedSuccessfully,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      Text(
                                        _uploadedFileName!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.green.shade600,
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
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    if (!_buttonsHidden)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _skipUpload,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade600,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(AppLocalizations.of(context)!.skipForNow),
                            ),
                          ),
                          if (_extractedData != null && !_isExtracting) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _submitCV,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7B3FE4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text(AppLocalizations.of(context)!.reviewEditData),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}