import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/BulkCertificateData.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/User.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:url_launcher/url_launcher.dart';

class BulkCertificateUploadPage extends StatefulWidget {
  final EducationInstitution educationInstitution;

  const BulkCertificateUploadPage({
    super.key,
    required this.educationInstitution,
  });

  @override
  _BulkCertificateUploadPageState createState() => _BulkCertificateUploadPageState();
}

class _BulkCertificateUploadPageState extends State<BulkCertificateUploadPage> {
  final IEducationInstitutionBll _educationInstitutionBll = EducationInstitutionBll();
  final IUserBLL _userBll = UserBll();
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  
  List<BulkCertificateData> _certificateData = [];
  bool _isLoading = false;
  bool _hasFileSelected = false;
  String? _fileName;
  String? _errorMessage;
  
  // Certificate creation state
  bool _isCreatingCertificates = false;
  int _currentCertificateIndex = 0;
  List<String> _creationErrors = [];
  int _successfulCreations = 0;
  
  // Certificate processing status tracking
  Map<int, CertificateStatus> _certificateStatuses = {};
  
  // Store matched PlatformFile objects for certificate creation
  Map<int, PlatformFile> _matchedFiles = {};
  
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Certificate Upload'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Excel File Requirements',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your Excel file should contain the following columns:\n'
                        '• Student Email (required)\n'
                        '• Student Firstname (required)\n'
                        '• Student Lastname (required)\n'
                        '• Certificate Title (required)\n'
                        '• Issue Date (YYYY-MM-DD format)\n'
                        '• Description (optional)\n'
                        '• Garde/Score (optional)\n'
                        '• Certificate File Name (optional)\n\n'
                        'Download the template below for the correct format.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kIsWeb ? Colors.blue.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: kIsWeb ? Colors.blue.shade200 : Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              kIsWeb ? Icons.language : Icons.desktop_windows,
                              color: kIsWeb ? Colors.blue.shade700 : Colors.green.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getPlatformInfo(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kIsWeb ? Colors.blue.shade700 : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _downloadTemplate,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Excel Template'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // File Upload Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (!_hasFileSelected) ...[
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select Excel File',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose an Excel file (.xlsx) containing student and certificate data',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickExcelFile,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Select Excel File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(Icons.file_present, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _fileName ?? 'File selected',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: _clearFile,
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_certificateData.length} certificates found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ExpansionTile(
                                title: const Text(
                                  'Troubleshooting Tips',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _getPlatformTroubleshootingTips(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (_isLoading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Processing file...'),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Data Table Section
              if (_certificateData.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 600, // Set a maximum height instead of using Expanded
                  ),
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Certificate Data Preview & Editor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_certificateData.length} records',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // File Upload Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                              left: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text(
                                'Certificate Files:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _uploadBulkFiles,
                                icon: const Icon(Icons.file_upload, size: 18),
                                label: const Text('Upload Multiple Files'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getFileUploadStats(),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 16,
                                horizontalMargin: 16,
                                columns: const [
                                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Last Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Certificate Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Issue Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Grade/Score', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Certificate File', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _certificateData.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final cert = entry.value;
                                  final status = _certificateStatuses[index];
                                  
                                  Color? rowColor;
                                  if (status == CertificateStatus.success) {
                                    rowColor = Colors.green.shade200; // Strong green for success
                                  } else if (status == CertificateStatus.failed) {
                                    rowColor = Colors.red.shade200; // Red for failure
                                  } else if (status == CertificateStatus.processing) {
                                    rowColor = Colors.blue.shade100; // Blue for processing
                                  } else if (cert.isValid) {
                                    rowColor = Colors.green.shade50; // Light green for valid
                                  } else {
                                    rowColor = Colors.red.shade50; // Light red for invalid
                                  }
                                  
                                  return DataRow(
                                    color: MaterialStateProperty.all(rowColor),
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            cert.studentEmail,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            cert.studentFirstname,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            cert.studentLastname,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            cert.certificateTitle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            cert.issueDate ?? '',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            cert.description ?? '',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            cert.gardeScore ?? '',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: _buildFileCell(cert, index),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (status == CertificateStatus.processing)
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            else
                                              Icon(
                                                _getStatusIcon(status, cert.isValid),
                                                color: _getStatusColor(status, cert.isValid),
                                                size: 16,
                                              ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getStatusText(status, cert.isValid),
                                              style: TextStyle(
                                                color: _getStatusColor(status, cert.isValid),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 18),
                                              onPressed: () => _editCertificate(index),
                                              tooltip: 'Edit',
                                              color: Colors.blue,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 18),
                                              onPressed: () => _deleteCertificate(index),
                                              tooltip: 'Delete',
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        if (_certificateData.any((cert) => !cert.isValid)) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Some records have errors. Only valid records will be processed.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
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
                  ),
                ),
              ],
              
              // Action Buttons
              if (_hasFileSelected && _certificateData.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isCreatingCertificates ? null : _canCreateCertificates() 
                            ? () => _showGasFeeConfirmation()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canCreateCertificates() ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isCreatingCertificates
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Creating ${_currentCertificateIndex + 1}/${_getValidCertificatesWithFiles().length}'),
                                ],
                              )
                            : Text(
                                _getCreateButtonText(),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _pickExcelFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
        withData: kIsWeb, // Ensure bytes are loaded on web
        withReadStream: !kIsWeb, // Use streams on desktop for better memory management
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        try {
          Uint8List? fileBytes = await _readFileBytes(file);
          
          if (fileBytes != null) {
            await _parseExcelFile(fileBytes, file.name);
          }
          // Error handling is already done in _readFileBytes method
        } catch (fileError) {
          setState(() {
            _errorMessage = 'Unexpected error reading file: ${fileError.toString()}\n\nPlease try again or contact support.';
          });
        }
      } else {
        // User cancelled file selection
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('User canceled')) {
          _errorMessage = null; // Don't show error for user cancellation
        } else if (e.toString().contains('Permission denied')) {
          _errorMessage = 'Permission denied. Please check file permissions and try again.';
        } else if (e.toString().contains('No such file')) {
          _errorMessage = 'File not found. Please ensure the file exists and try again.';
        } else {
          _errorMessage = kIsWeb 
            ? 'Error selecting file: ${e.toString()}\n\nWeb Platform - Try:\n• Refreshing the page\n• Using a different browser\n• Clearing browser cache'
            : 'Error selecting file: ${e.toString()}\n\nDesktop Platform - Try:\n• Running as administrator\n• Checking file permissions\n• Selecting from a different location';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _parseExcelFile(Uint8List bytes, String fileName) async {
    try {
      // File size validation with platform-specific limits
      final maxSizeMB = kIsWeb ? 5 : 10; // Web has more restrictive limits
      final maxSizeBytes = maxSizeMB * 1024 * 1024;
      
      if (bytes.length > maxSizeBytes) {
        setState(() {
          _errorMessage = 'File too large (${(bytes.length / (1024 * 1024)).toStringAsFixed(1)}MB). Maximum allowed size is ${maxSizeMB}MB${kIsWeb ? ' on web platform' : ' on desktop'}. Please reduce the file size and try again.';
        });
        return;
      }
      
      // File format validation
      final validExtensions = ['.xlsx', '.xls'];
      final fileExtension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
      if (!validExtensions.contains(fileExtension)) {
        setState(() {
          _errorMessage = 'Invalid file format ($fileExtension). Please upload an Excel file with .xlsx or .xls extension.';
        });
        return;
      }
      
      final excel = excel_lib.Excel.decodeBytes(bytes);
      final List<BulkCertificateData> certificates = [];
      
      // Check if file has any sheets
      if (excel.tables.isEmpty) {
        setState(() {
          _errorMessage = 'Excel file contains no worksheets. Please ensure your file has at least one worksheet with data.';
        });
        return;
      }
      
      // Get the first sheet
      final sheet = excel.tables.values.first;
      
      if (sheet.rows.isEmpty) {
        setState(() {
          _errorMessage = 'Excel worksheet is empty. Please add data to your Excel file and try again.';
        });
        return;
      }
      
      if (sheet.rows.length < 2) {
        setState(() {
          _errorMessage = 'Excel file must contain at least a header row and one data row. Found only ${sheet.rows.length} row(s).';
        });
        return;
      }
      
      // Assume first row contains headers
      final headerRow = sheet.rows.first;
      final headers = headerRow.map((cell) => cell?.value?.toString().toLowerCase() ?? '').toList();
      
      // Check for completely empty header row
      if (headers.every((h) => h.trim().isEmpty)) {
        setState(() {
          _errorMessage = 'First row appears to be empty. Please ensure the first row contains column headers.';
        });
        return;
      }
      
      // Use fixed column indices based on known Excel structure
      final emailIndex = 0;          // Student Email
      final firstnameIndex = 1;      // Student Firstname  
      final lastnameIndex = 2;       // Student Lastname
      final titleIndex = 3;          // Certificate title
      final dateIndex = 4;           // Issue Date
      final descriptionIndex = 5;    // Description
      final gradeIndex = 6;          // Garde/Score
      final fileNameIndex = 7;       // Certificate file name
      
      // Debug: Show column detection results for successful parsing
      print('DEBUG: Using fixed column indices:');
      print('  emailIndex: $emailIndex');
      print('  firstnameIndex: $firstnameIndex');
      print('  lastnameIndex: $lastnameIndex');
      print('  titleIndex: $titleIndex');
      print('  dateIndex: $dateIndex');
      print('  descriptionIndex: $descriptionIndex');
      print('  gradeIndex: $gradeIndex');
      print('  fileNameIndex: $fileNameIndex');
      
      // Parse data rows (skip header)
      int validRows = 0;
      int skippedRows = 0;
      List<String> rowErrors = [];
      
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        
        // Skip completely empty rows
        if (row.isEmpty || row.every((cell) => cell?.value == null || cell!.value.toString().trim().isEmpty)) {
          skippedRows++;
          continue;
        }
        
        final email = _getCellValue(row, emailIndex);
        final firstname = _getCellValue(row, firstnameIndex);
        final lastname = _getCellValue(row, lastnameIndex);
        final title = _getCellValue(row, titleIndex);
        final date = _getCellValue(row, dateIndex);
        final description = _getCellValue(row, descriptionIndex);
        final grade = _getCellValue(row, gradeIndex);
        final fileName = _getCellValue(row, fileNameIndex);
        
        // Validate required fields for this row
        List<String> missingFields = [];
        if (email.isEmpty) missingFields.add('Email');
        if (firstname.isEmpty) missingFields.add('Firstname');
        if (lastname.isEmpty) missingFields.add('Lastname');
        if (title.isEmpty) missingFields.add('Certificate Title');
        
        if (missingFields.isNotEmpty) {
          rowErrors.add('Row ${i + 1}: Missing required fields: ${missingFields.join(', ')}');
          continue;
        }
        
        // Validate email format
        if (!_isValidEmail(email)) {
          rowErrors.add('Row ${i + 1}: Invalid email format: $email');
          continue;
        }
        
        final certData = BulkCertificateData(
          studentEmail: email,
          studentFirstname: firstname,
          studentLastname: lastname,
          certificateTitle: title,
          issueDate: date,
          description: description,
          gardeScore: grade,
          certificateFileName: fileName,
        );
        
        // Debug: Print what we're actually setting
        print('DEBUG: Row ${i + 1}');
        print('  Certificate Title: "$title"');
        print('  Certificate File Name: "$fileName"');
        print('  fileNameIndex: $fileNameIndex');
        
        certificates.add(certData);
        validRows++;
      }
      
      // Provide detailed feedback about parsing results
      if (certificates.isEmpty) {
        String errorMsg = 'No valid certificate data found in Excel file.\n\n';
        if (rowErrors.isNotEmpty) {
          errorMsg += 'Issues found:\n${rowErrors.take(5).join('\n')}';
          if (rowErrors.length > 5) {
            errorMsg += '\n... and ${rowErrors.length - 5} more issues.';
          }
        }
        if (skippedRows > 0) {
          errorMsg += '\n\nSkipped $skippedRows empty rows.';
        }
        setState(() {
          _errorMessage = errorMsg;
        });
        return;
      }
      
      setState(() {
        _certificateData = certificates;
        _hasFileSelected = true;
        _fileName = fileName;
        _errorMessage = null;
      });
      
      // Show success message with details
      if (mounted) {
        String successMsg = 'Successfully loaded $validRows certificate(s)';
        if (skippedRows > 0) successMsg += ' (skipped $skippedRows empty rows)';
        if (rowErrors.isNotEmpty) successMsg += ' (${rowErrors.length} rows had issues)';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = 'Invalid Excel file format. The file may be corrupted or not a valid Excel file.\n\nTechnical details: ${e.message}';
      });
    } on OutOfMemoryError {
      setState(() {
        _errorMessage = 'File is too large to process in memory. Please try with a smaller file or reduce the number of rows.';
      });
    } on UnsupportedError catch (e) {
      setState(() {
        _errorMessage = 'Unsupported Excel file format. Please save your file as .xlsx or .xls format and try again.\n\nError: ${e.message}';
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('Invalid argument')) {
          _errorMessage = 'Invalid Excel file. Please ensure the file is not password-protected and saved in a standard Excel format.';
        } else if (e.toString().contains('RangeError')) {
          _errorMessage = 'Error reading Excel file structure. The file may have formatting issues or be corrupted.';
        } else {
          _errorMessage = 'Unexpected error while reading Excel file: ${e.toString()}\n\nPlease try:\n1. Re-saving the file as .xlsx format\n2. Ensuring the file is not corrupted\n3. Checking that the file is not password-protected';
        }
      });
    }
  }
  
  String _getCellValue(List<excel_lib.Data?> row, int index) {
    if (index == -1 || index >= row.length) return '';
    final cell = row[index];
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }
  
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  /// Platform-specific file reading method
  Future<Uint8List?> _readFileBytes(PlatformFile file) async {
    try {
      if (file.bytes != null) {
        // Bytes are available - works on both web and desktop
        return file.bytes!;
      } else {
        // Handle case where bytes are not available
        setState(() {
          if (kIsWeb) {
            _errorMessage = 'Cannot read file on web platform. Please try:\n\n• Refreshing the page and trying again\n• Using a different browser\n• Ensuring the file is not corrupted\n\nSupported browsers: Chrome, Firefox, Safari, Edge';
          } else {
            _errorMessage = 'Cannot access file data. This may happen if:\n\n• The file is too large\n• The file is locked by another application\n• Insufficient permissions\n\nPlease close the file in other applications and try again.';
          }
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accessing file: ${e.toString()}\n\nPlease ensure:\n• The file is not open in another application\n• You have permission to read the file\n• The file is not corrupted';
      });
      return null;
    }
  }
  
  /// Get platform-specific information for user guidance
  String _getPlatformInfo() {
    if (kIsWeb) {
      return 'Web Platform - Upload files directly from your browser';
    } else {
      return 'Desktop Platform - Select files from your computer';
    }
  }
  
  /// Get platform-specific troubleshooting tips
  String _getPlatformTroubleshootingTips() {
    if (kIsWeb) {
      return '''
Web Platform Tips:
• Use Chrome, Firefox, Safari, or Edge for best compatibility
• Refresh the page if file upload fails
• Check your internet connection
• Try incognito/private browsing mode if issues persist
• Maximum file size: 10MB (browsers may have lower limits)''';
    } else {
      return '''
Desktop Platform Tips:
• Ensure the file is not open in another application
• Check file permissions (try running as administrator if needed)
• Verify the file path is accessible
• Try copying the file to your desktop and upload from there
• Close Excel/LibreOffice before uploading''';
    }
  }
  
  /// Build file cell with URL links or file upload options
  Widget _buildFileCell(BulkCertificateData cert, int index) {
    // Debug: Show what values we're working with
    print('DEBUG: _buildFileCell for ${cert.fullName}:');
    print('  certificateTitle: "${cert.certificateTitle}"');
    print('  certificateFileName: "${cert.certificateFileName}"');
    print('  isExternalUrl: ${cert.isExternalUrl}');
    print('  hasUploadedFile: ${cert.hasUploadedFile}');
    
    if (cert.isExternalUrl && cert.certificateFileName != null) {
      // External URL - show as clickable link
      return InkWell(
        onTap: () => _launchUrl(cert.certificateFileName!),
        child: Row(
          children: [
            const Icon(Icons.link, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                cert.certificateFileName!,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else if (cert.hasUploadedFile) {
      // File uploaded - show file name with remove option
      return Row(
        children: [
          const Icon(Icons.attach_file, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              cert.uploadedFileName ?? 'File uploaded',
              style: const TextStyle(color: Colors.green),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => _removeUploadedFile(index),
            tooltip: 'Remove file',
            color: Colors.red,
          ),
        ],
      );
    } else if (cert.certificateFileName != null && cert.certificateFileName!.isNotEmpty) {
      // Local file name - show with upload option
      return Row(
        children: [
          const Icon(Icons.description, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              cert.certificateFileName!,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, size: 16),
            onPressed: () => _uploadFileForCertificate(index),
            tooltip: 'Upload file',
            color: Colors.blue,
          ),
        ],
      );
    } else {
      // No file specified - show upload option
      return Row(
        children: [
          const Icon(Icons.file_upload, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'No file',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, size: 16),
            onPressed: () => _uploadFileForCertificate(index),
            tooltip: 'Upload file',
            color: Colors.blue,
          ),
        ],
      );
    }
  }
  
  /// Launch external URL
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch URL: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Remove uploaded file from certificate
  void _removeUploadedFile(int index) {
    setState(() {
      _certificateData[index] = _certificateData[index].copyWith(
        uploadedFilePath: '',
        uploadedFileName: '',
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  /// Upload file for specific certificate
  Future<void> _uploadFileForCertificate(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
        withData: kIsWeb,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        setState(() {
          _certificateData[index] = _certificateData[index].copyWith(
            uploadedFilePath: kIsWeb ? file.name : (file.path ?? file.name),
            uploadedFileName: file.name,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File "${file.name}" uploaded for ${_certificateData[index].fullName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// Get file upload statistics
  String _getFileUploadStats() {
    final totalFiles = _certificateData.length;
    final filesWithUploads = _certificateData.where((cert) => cert.hasUploadedFile).length;
    final externalUrls = _certificateData.where((cert) => cert.isExternalUrl).length;
    
    if (totalFiles == 0) return 'No certificates';
    
    return '$filesWithUploads uploaded, $externalUrls URLs, ${totalFiles - filesWithUploads - externalUrls} pending';
  }
  
  /// Upload multiple files for bulk matching
  Future<void> _uploadBulkFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
        withData: kIsWeb,
      );
      
      if (result != null && result.files.isNotEmpty) {
        await _showFileMatchingDialog(result.files);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// Show dialog to match uploaded files with certificates
  Future<void> _showFileMatchingDialog(List<PlatformFile> files) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _FileMatchingDialog(
          files: files,
          certificates: _certificateData,
          onFilesMatched: (Map<int, PlatformFile> matches) {
            setState(() {
              // Store the PlatformFile objects for later use
              _matchedFiles = Map.from(matches);
              
              // Update certificate data with file paths
              matches.forEach((certIndex, file) {
                _certificateData[certIndex] = _certificateData[certIndex].copyWith(
                  uploadedFilePath: kIsWeb ? file.name : (file.path ?? file.name),
                  uploadedFileName: file.name,
                );
              });
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${matches.length} files matched to certificates'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }
  
  void _clearFile() {
    setState(() {
      _certificateData = [];
      _hasFileSelected = false;
      _fileName = null;
      _errorMessage = null;
      _matchedFiles.clear(); // Clear matched files
    });
  }
  
  
  void _downloadTemplate() async {
    try {
      final templateUrl = '${BackenConnection().url}/assets/excel-template/certificate-bulk-template.xlsx';
      
      if (await canLaunchUrl(Uri.parse(templateUrl))) {
        await launchUrl(
          Uri.parse(templateUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not download template file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _deleteCertificate(int index) {
    setState(() {
      _certificateData.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate record deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _editCertificate(int index) {
    final cert = _certificateData[index];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _EditCertificateDialog(
          certificate: cert,
          onSave: (updatedCert) {
            setState(() {
              _certificateData[index] = updatedCert;
            });
          },
        );
      },
    );
  }
  
  // Check if certificates can be created (valid certificates with files)
  bool _canCreateCertificates() {
    if (_isCreatingCertificates) return false;
    final validCertsWithFiles = _getValidCertificatesWithFiles();
    return validCertsWithFiles.isNotEmpty;
  }

  // Get valid certificates that have files (either uploaded or external URLs)
  List<BulkCertificateData> _getValidCertificatesWithFiles() {
    return _certificateData.where((cert) => 
      cert.isValid && (cert.hasUploadedFile || cert.isExternalUrl)
    ).toList();
  }

  // Get the text for the create button
  String _getCreateButtonText() {
    final validCerts = _certificateData.where((cert) => cert.isValid).toList();
    final validCertsWithFiles = _getValidCertificatesWithFiles();
    
    if (validCerts.isEmpty) {
      return 'No Valid Certificates';
    } else if (validCertsWithFiles.isEmpty) {
      return 'Match Files First (${validCerts.length} certificates)';
    } else {
      return 'Create ${validCertsWithFiles.length} Certificates';
    }
  }

  // Show gas fee confirmation dialog
  Future<void> _showGasFeeConfirmation() async {
    final validCertsWithFiles = _getValidCertificatesWithFiles();
    final gasFeeCost = (validCertsWithFiles.length * 0.01).toStringAsFixed(2);
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _GasFeeConfirmationDialog(
          certificateCount: validCertsWithFiles.length,
          gasFeeCost: gasFeeCost,
        );
      },
    );

    if (result != null && result['confirmed'] == true) {
      final password = result['password'] as String;
      await _createCertificatesWithProgress(password);
    }
  }

  /// Get status icon based on certificate processing status
  IconData _getStatusIcon(CertificateStatus? status, bool isValid) {
    switch (status) {
      case CertificateStatus.success:
        return Icons.check_circle;
      case CertificateStatus.failed:
        return Icons.error;
      case CertificateStatus.processing:
        return Icons.hourglass_empty;
      case null:
        return isValid ? Icons.pending : Icons.error;
    }
  }

  /// Get status color based on certificate processing status
  Color _getStatusColor(CertificateStatus? status, bool isValid) {
    switch (status) {
      case CertificateStatus.success:
        return Colors.green.shade700;
      case CertificateStatus.failed:
        return Colors.red.shade700;
      case CertificateStatus.processing:
        return Colors.blue.shade700;
      case null:
        return isValid ? Colors.orange : Colors.red;
    }
  }

  /// Get status text based on certificate processing status
  String _getStatusText(CertificateStatus? status, bool isValid) {
    switch (status) {
      case CertificateStatus.success:
        return 'Minted';
      case CertificateStatus.failed:
        return 'Failed';
      case CertificateStatus.processing:
        return 'Minting...';
      case null:
        return isValid ? 'Ready' : 'Error';
    }
  }

  // Create certificates with progress tracking
  Future<void> _createCertificatesWithProgress(String password) async {
    final validCertsWithFiles = _getValidCertificatesWithFiles();
    
    setState(() {
      _isCreatingCertificates = true;
      _currentCertificateIndex = 0;
      _creationErrors.clear();
      _successfulCreations = 0;
      _certificateStatuses.clear();
    });

    try {
      for (int i = 0; i < validCertsWithFiles.length; i++) {
        final cert = validCertsWithFiles[i];
        final certIndex = _certificateData.indexOf(cert);
        
        setState(() {
          _currentCertificateIndex = i;
          _certificateStatuses[certIndex] = CertificateStatus.processing;
        });

        try {
          // Step 1: Get blockchain public key of the user receiving the certificate
          final String? userPublicKey = await _getUserBlockchainPublicKey(cert.studentEmail);
          
          if (userPublicKey == null || userPublicKey.isEmpty) {
            throw Exception('No blockchain wallet found for user ${cert.studentEmail}');
          }

          // Step 2: Mint the certificate on the blockchain
          final platformFile = _matchedFiles[certIndex]; // Get the matched PlatformFile
          final String? tokenAddress = await _mintCertificateOnBlockchain(
            cert,
            userPublicKey,
            password,
            platformFile,
          );
          
          if (tokenAddress == null || tokenAddress.isEmpty) {
            throw Exception('Failed to mint certificate on blockchain');
          }

          // Step 3: Save certificate record to backend with blockchain reference
          await _saveCertificateToBackend(cert, tokenAddress);
          
          setState(() {
            _certificateStatuses[certIndex] = CertificateStatus.success;
            _successfulCreations++;
          });
          
          // Small delay to show progress
          await Future.delayed(const Duration(milliseconds: 800));
          
        } catch (e) {
          setState(() {
            _certificateStatuses[certIndex] = CertificateStatus.failed;
            _creationErrors.add('${cert.fullName}: ${e.toString()}');
          });
          
          // Continue with next certificate even if this one failed
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      // Show completion dialog
      await _showCompletionDialog();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during certificate creation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingCertificates = false;
        _currentCertificateIndex = 0;
      });
    }
  }

  /// Get blockchain public key for user by email
  Future<String?> _getUserBlockchainPublicKey(String email) async {
    try {
      final user = await _userBll.getUserBlockchainPublicKeyForBulk(email);
      
      return user.ethereumAddress;
    } catch (e) {
      throw Exception('Failed to get blockchain public key for $email: ${e.toString()}');
    }
  }

  /// Mint certificate as NFT on blockchain
  Future<String?> _mintCertificateOnBlockchain(
    BulkCertificateData certificate,
    String recipientPublicKey,
    String password,
    PlatformFile? platformFile,
  ) async {
    Certificate? cert;
    try {
      // Create Certificate object from BulkCertificateData
      cert = Certificate();
      cert.title = certificate.certificateTitle;
      cert.description = certificate.description ?? 'Certificate issued by ${widget.educationInstitution.name}';
      cert.grade = certificate.gardeScore;
      cert.publicationDate = certificate.issueDate ?? DateTime.now().toIso8601String().split('T')[0];
      
      // Add the file to the certificate object
      if (platformFile != null) {
        cert.fielPath = certificate.uploadedFilePath;
        
        if (kIsWeb && platformFile.bytes != null) {
          // For web platforms, store bytes directly in the certificate
          cert.fielPath = platformFile.name;
          cert.fileBytes = platformFile.bytes!;
          
          print('Web platform: Stored ${platformFile.bytes!.length} bytes for IPFS upload');
        } else if (!kIsWeb && platformFile.path != null) {
          // For non-web platforms, use the file path directly
          try {
            cert.file = File(platformFile.path!);
          } catch (e) {
            print('Warning: Could not create File object from path: ${platformFile.path}');
          }
        }
      } else if (certificate.uploadedFilePath != null && certificate.uploadedFilePath!.isNotEmpty) {
        // Fallback: use the stored file path
        cert.fielPath = certificate.uploadedFilePath;
        if (!kIsWeb) {
          try {
            cert.file = File(certificate.uploadedFilePath!);
          } catch (e) {
            print('Warning: Could not create File object from stored path: ${certificate.uploadedFilePath}');
          }
        }
      }

      // Create User object for recipient
      final user = User();
      user.email = certificate.studentEmail;
      user.firstName = certificate.studentFirstname;
      user.lastName = certificate.studentLastname;
      user.ethereumAddress = recipientPublicKey;

      // Use the existing createCertificateToken function that handles both IPFS upload and minting
      final String? tokenAddress = await _blockchainWalletBll.createCertificateToken(
        cert,
        user,
        widget.educationInstitution,
        password,
      );

      return tokenAddress;
    } catch (e) {
      throw Exception('Blockchain minting failed: ${e.toString()}');
    }
  }

  /// Save certificate record to backend database
  Future<void> _saveCertificateToBackend(
    BulkCertificateData certificate,
    String tokenAddress,
  ) async {
    try {
      // For now, we'll use the existing bulk certificate creation method
      // The tokenAddress can be stored in the certificate data or handled separately
      await _educationInstitutionBll.createBulkCertificates(
        widget.educationInstitution.id!,
        [certificate],
      );
      
      // TODO: Store the tokenAddress/blockchain reference separately if needed
      // This might require a new method in the backend to associate the blockchain token
    } catch (e) {
      throw Exception('Failed to save certificate to database: ${e.toString()}');
    }
  }

  // Show completion dialog with results
  Future<void> _showCompletionDialog() async {
    final totalProcessed = _certificateStatuses.length;
    final successful = _certificateStatuses.values.where((s) => s == CertificateStatus.success).length;
    final failed = _certificateStatuses.values.where((s) => s == CertificateStatus.failed).length;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                failed == 0 ? Icons.check_circle : Icons.warning,
                color: failed == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text('Blockchain Certificate Creation Complete'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.link, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Blockchain Results', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('✅ Successfully minted: $successful NFT certificates'),
                    Text('📊 Total processed: $totalProcessed certificates'),
                    if (failed > 0) Text('❌ Failed to mint: $failed certificates'),
                    const SizedBox(height: 8),
                    const Text(
                      'Successfully minted certificates are now permanently recorded on the blockchain and visible in student wallets.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              if (_creationErrors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _creationErrors.map((error) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(error, style: const TextStyle(fontSize: 12)),
                        )
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (failed > 0)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _retryFailedCertificates();
                },
                child: const Text('Retry Failed'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (successful > 0) {
                  _clearSuccessfulCertificates();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Retry failed certificate creations
  Future<void> _retryFailedCertificates() async {
    final failedIndices = _certificateStatuses.entries
        .where((entry) => entry.value == CertificateStatus.failed)
        .map((entry) => entry.key)
        .toList();

    if (failedIndices.isEmpty) return;

    // Show password dialog for retry
    final failedCertificates = failedIndices
        .map((index) => _certificateData[index])
        .where((cert) => cert.isValid && (cert.hasUploadedFile || cert.isExternalUrl))
        .toList();

    if (failedCertificates.isEmpty) return;

    final gasFeeCost = (failedCertificates.length * 0.01).toStringAsFixed(2);
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _GasFeeConfirmationDialog(
          certificateCount: failedCertificates.length,
          gasFeeCost: gasFeeCost,
        );
      },
    );

    if (result != null && result['confirmed'] == true) {
      final password = result['password'] as String;
      
      // Clear failed statuses and retry
      for (final index in failedIndices) {
        _certificateStatuses.remove(index);
      }

      // Reset error list for retry
      _creationErrors.clear();
      await _createCertificatesWithProgress(password);
    }
  }

  // Remove successfully created certificates from the list
  void _clearSuccessfulCertificates() {
    if (_successfulCreations > 0) {
      setState(() {
        final successfulIndices = _certificateStatuses.entries
            .where((entry) => entry.value == CertificateStatus.success)
            .map((entry) => entry.key)
            .toList()
            ..sort((a, b) => b.compareTo(a)); // Sort in descending order to remove from end

        // Remove successful certificates from the list
        for (final index in successfulIndices) {
          _certificateData.removeAt(index);
        }

        // Clear status tracking
        _certificateStatuses.clear();
        
        // Reset error state if all certificates were processed
        if (_certificateData.where((cert) => cert.isValid).isEmpty) {
          _clearFile();
        }
      });
    }
  }
}

/// Enum for tracking certificate processing status
enum CertificateStatus {
  processing,
  success,
  failed,
}

class _EditCertificateDialog extends StatefulWidget {
  final BulkCertificateData certificate;
  final Function(BulkCertificateData) onSave;

  const _EditCertificateDialog({
    required this.certificate,
    required this.onSave,
  });

  @override
  _EditCertificateDialogState createState() => _EditCertificateDialogState();
}

class _EditCertificateDialogState extends State<_EditCertificateDialog> {
  late TextEditingController _emailController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _gradeController;
  late TextEditingController _fileNameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.certificate.studentEmail);
    _firstnameController = TextEditingController(text: widget.certificate.studentFirstname);
    _lastnameController = TextEditingController(text: widget.certificate.studentLastname);
    _titleController = TextEditingController(text: widget.certificate.certificateTitle);
    _dateController = TextEditingController(text: widget.certificate.issueDate ?? '');
    _descriptionController = TextEditingController(text: widget.certificate.description ?? '');
    _gradeController = TextEditingController(text: widget.certificate.gardeScore ?? '');
    _fileNameController = TextEditingController(text: widget.certificate.certificateFileName ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _gradeController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Certificate'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstnameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _lastnameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Certificate Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Issue Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade/Score',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'Certificate File Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCertificate,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveCertificate() {
    final updatedCert = BulkCertificateData(
      studentEmail: _emailController.text.trim(),
      studentFirstname: _firstnameController.text.trim(),
      studentLastname: _lastnameController.text.trim(),
      certificateTitle: _titleController.text.trim(),
      issueDate: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      gardeScore: _gradeController.text.trim().isEmpty ? null : _gradeController.text.trim(),
      certificateFileName: _fileNameController.text.trim().isEmpty ? null : _fileNameController.text.trim(),
    );

    widget.onSave(updatedCert);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Dialog for matching uploaded files with certificate records
class _FileMatchingDialog extends StatefulWidget {
  final List<PlatformFile> files;
  final List<BulkCertificateData> certificates;
  final Function(Map<int, PlatformFile>) onFilesMatched;

  const _FileMatchingDialog({
    required this.files,
    required this.certificates,
    required this.onFilesMatched,
  });

  @override
  _FileMatchingDialogState createState() => _FileMatchingDialogState();
}

class _FileMatchingDialogState extends State<_FileMatchingDialog> {
  late Map<int, PlatformFile?> _matches;
  late List<PlatformFile> _unmatchedFiles;

  @override
  void initState() {
    super.initState();
    _matches = {};
    _unmatchedFiles = List.from(widget.files);
    _autoMatchFiles();
  }

  /// Auto-match files based on name similarity
  void _autoMatchFiles() {
    for (int i = 0; i < widget.certificates.length; i++) {
      final cert = widget.certificates[i];
      
      // Skip if certificate already has a file or is external URL
      if (cert.hasUploadedFile || cert.isExternalUrl) continue;
      
      // Try to find matching file
      PlatformFile? matchedFile;
      
      // First try exact filename match
      if (cert.certificateFileName != null) {
        matchedFile = _unmatchedFiles.where(
          (file) => file.name.toLowerCase() == cert.certificateFileName!.toLowerCase(),
        ).firstOrNull;
      }
      
      // If no exact match, try partial name matching
      if (matchedFile == null) {
        final searchTerms = [
          cert.studentFirstname.toLowerCase(),
          cert.studentLastname.toLowerCase(),
          // Only use certificate file name for partial matching, not title
          if (cert.certificateFileName != null && cert.certificateFileName!.isNotEmpty)
            cert.certificateFileName!.toLowerCase().split('.').first, // Remove extension for partial match
        ];
        
        for (final file in _unmatchedFiles) {
          final fileName = file.name.toLowerCase();
          if (searchTerms.any((term) => fileName.contains(term) && term.length > 2)) {
            matchedFile = file;
            break;
          }
        }
      }
      
      if (matchedFile != null) {
        _matches[i] = matchedFile;
        _unmatchedFiles.remove(matchedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Match Files to Certificates'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            Text(
              'Auto-matched ${_getValidMatches().length} files. Drag and drop or select to match remaining files.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // Certificates column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certificates',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.certificates.length,
                            itemBuilder: (context, index) {
                              final cert = widget.certificates[index];
                              final hasMatch = _matches.containsKey(index) && _matches[index] != null;
                              
                              return Card(
                                color: hasMatch ? Colors.green.shade50 : Colors.grey.shade50,
                                child: ListTile(
                                  title: Text(
                                    cert.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Certificate: ${cert.certificateTitle}'),
                                      if (cert.certificateFileName != null && cert.certificateFileName!.isNotEmpty)
                                        Text('Expected file: ${cert.certificateFileName}',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      if (hasMatch)
                                        Text(
                                          'Matched: ${_matches[index]!.name}',
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                    ],
                                  ),
                                  trailing: hasMatch
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.red),
                                        onPressed: () => _unmatchFile(index),
                                      )
                                    : DropdownButton<PlatformFile>(
                                        hint: const Text('Select file'),
                                        value: null,
                                        items: _unmatchedFiles.map((file) {
                                          return DropdownMenuItem(
                                            value: file,
                                            child: Text(file.name),
                                          );
                                        }).toList(),
                                        onChanged: (file) => _matchFile(index, file!),
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Unmatched files column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unmatched Files (${_unmatchedFiles.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _unmatchedFiles.length,
                            itemBuilder: (context, index) {
                              final file = _unmatchedFiles[index];
                              return Card(
                                color: Colors.orange.shade50,
                                child: ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(file.name),
                                  subtitle: Text(_formatFileSize(file.size)),
                                ),
                              );
                            },
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _getValidMatches().isNotEmpty
            ? () {
                widget.onFilesMatched(_getValidMatches());
                Navigator.of(context).pop();
              }
            : null,
          child: Text('Match ${_getValidMatches().length} Files'),
        ),
      ],
    );
  }

  // Get only valid matches (non-null values)
  Map<int, PlatformFile> _getValidMatches() {
    final validMatches = <int, PlatformFile>{};
    _matches.forEach((key, value) {
      if (value != null) {
        validMatches[key] = value;
      }
    });
    return validMatches;
  }

  void _matchFile(int certIndex, PlatformFile file) {
    setState(() {
      _matches[certIndex] = file;
      _unmatchedFiles.remove(file);
    });
  }

  void _unmatchFile(int certIndex) {
    setState(() {
      final file = _matches.remove(certIndex);
      if (file != null) {
        _unmatchedFiles.add(file);
      }
    });
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Gas fee confirmation dialog with password input
class _GasFeeConfirmationDialog extends StatefulWidget {
  final int certificateCount;
  final String gasFeeCost;

  const _GasFeeConfirmationDialog({
    required this.certificateCount,
    required this.gasFeeCost,
  });

  @override
  State<_GasFeeConfirmationDialog> createState() => _GasFeeConfirmationDialogState();
}

class _GasFeeConfirmationDialogState extends State<_GasFeeConfirmationDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPasswordValid = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Confirm Certificate Creation'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to create ${widget.certificateCount} certificates.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Gas Fee Information', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('• Estimated cost: \$${widget.gasFeeCost} USD'),
                  const Text('• Rate: ~\$0.01 per certificate'),
                  const Text('• This fee covers blockchain transaction costs'),
                  const Text('• Fee will be deducted from your wallet'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Wallet Authentication Required', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Enter your wallet password to decrypt and authorize the blockchain transactions.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) => _validatePassword(),
              decoration: InputDecoration(
                labelText: 'Wallet Password *',
                hintText: 'Enter your wallet password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                errorText: _passwordController.text.isEmpty && _passwordController.text.length > 0 
                    ? 'Password is required' 
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. Each certificate will be permanently recorded on the blockchain.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop({'confirmed': false}),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isPasswordValid
              ? () => Navigator.of(context).pop({
                    'confirmed': true,
                    'password': _passwordController.text,
                  })
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPasswordValid ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm & Pay Gas Fee'),
        ),
      ],
    );
  }
}