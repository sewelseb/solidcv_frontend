class BulkCertificateData {
  final String studentEmail;
  final String studentFirstname;
  final String studentLastname;
  final String certificateTitle;
  final String? issueDate;
  final String? description;
  final String? gardeScore;
  final String? certificateFileName;
  String? errorMessage;
  
  // File handling properties
  String? uploadedFilePath;
  String? uploadedFileName;
  bool get isExternalUrl => certificateFileName?.startsWith('http') ?? false;
  bool get hasUploadedFile => uploadedFilePath != null && uploadedFilePath!.isNotEmpty;
  
  BulkCertificateData({
    required this.studentEmail,
    required this.studentFirstname,
    required this.studentLastname,
    required this.certificateTitle,
    this.issueDate,
    this.description,
    this.gardeScore,
    this.certificateFileName,
    this.errorMessage,
    this.uploadedFilePath,
    this.uploadedFileName,
  });
  
  // Computed property for full name
  String get fullName => '$studentFirstname $studentLastname'.trim();
  
  bool get isValid {
    // Clear any previous error message
    errorMessage = null;
    
    // Validate required fields
    if (studentEmail.isEmpty) {
      errorMessage = 'Student email is required';
      return false;
    }
    
    if (studentFirstname.isEmpty) {
      errorMessage = 'Student firstname is required';
      return false;
    }
    
    if (studentLastname.isEmpty) {
      errorMessage = 'Student lastname is required';
      return false;
    }
    
    if (certificateTitle.isEmpty) {
      errorMessage = 'Certificate title is required';
      return false;
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(studentEmail)) {
      errorMessage = 'Invalid email format';
      return false;
    }
    
    // Validate date format if provided
    if (issueDate != null && issueDate!.isNotEmpty) {
      try {
        DateTime.parse(issueDate!);
      } catch (e) {
        errorMessage = 'Invalid date format. Use YYYY-MM-DD';
        return false;
      }
    }
    
    return true;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'studentEmail': studentEmail,
      'studentFirstname': studentFirstname,
      'studentLastname': studentLastname,
      'certificateTitle': certificateTitle,
      'issueDate': issueDate,
      'description': description,
      'gardeScore': gardeScore,
      'certificateFileName': certificateFileName,
    };
  }
  
  factory BulkCertificateData.fromJson(Map<String, dynamic> json) {
    return BulkCertificateData(
      studentEmail: json['studentEmail'] ?? '',
      studentFirstname: json['studentFirstname'] ?? '',
      studentLastname: json['studentLastname'] ?? '',
      certificateTitle: json['certificateTitle'] ?? '',
      issueDate: json['issueDate'],
      description: json['description'],
      gardeScore: json['gardeScore'],
      certificateFileName: json['certificateFileName'],
    );
  }
  
  // Method to create a copy with updated values
  BulkCertificateData copyWith({
    String? studentEmail,
    String? studentFirstname,
    String? studentLastname,
    String? certificateTitle,
    String? issueDate,
    String? description,
    String? gardeScore,
    String? certificateFileName,
    String? uploadedFilePath,
    String? uploadedFileName,
  }) {
    return BulkCertificateData(
      studentEmail: studentEmail ?? this.studentEmail,
      studentFirstname: studentFirstname ?? this.studentFirstname,
      studentLastname: studentLastname ?? this.studentLastname,
      certificateTitle: certificateTitle ?? this.certificateTitle,
      issueDate: issueDate ?? this.issueDate,
      description: description ?? this.description,
      gardeScore: gardeScore ?? this.gardeScore,
      certificateFileName: certificateFileName ?? this.certificateFileName,
      uploadedFilePath: uploadedFilePath ?? this.uploadedFilePath,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
    );
  }
  
  @override
  String toString() {
    return 'BulkCertificateData{studentEmail: $studentEmail, studentFirstname: $studentFirstname, studentLastname: $studentLastname, certificateTitle: $certificateTitle, issueDate: $issueDate, description: $description, gardeScore: $gardeScore, certificateFileName: $certificateFileName}';
  }
}

class BulkCertificateRequest {
  final int institutionId;
  final List<BulkCertificateData> certificates;
  
  BulkCertificateRequest({
    required this.institutionId,
    required this.certificates,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'institutionId': institutionId,
      'certificates': certificates.map((cert) => cert.toJson()).toList(),
    };
  }
}

class BulkCertificateResponse {
  final int totalProcessed;
  final int successCount;
  final int errorCount;
  final List<String> errors;
  final List<String> createdCertificateIds;
  
  BulkCertificateResponse({
    required this.totalProcessed,
    required this.successCount,
    required this.errorCount,
    required this.errors,
    required this.createdCertificateIds,
  });
  
  factory BulkCertificateResponse.fromJson(Map<String, dynamic> json) {
    return BulkCertificateResponse(
      totalProcessed: json['totalProcessed'] ?? 0,
      successCount: json['successCount'] ?? 0,
      errorCount: json['errorCount'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
      createdCertificateIds: List<String>.from(json['createdCertificateIds'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalProcessed': totalProcessed,
      'successCount': successCount,
      'errorCount': errorCount,
      'errors': errors,
      'createdCertificateIds': createdCertificateIds,
    };
  }
}