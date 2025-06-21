import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/User.dart';

class AddCertificatePage extends StatefulWidget {
  final EducationInstitution educationInstitution;
  final User user;

  const AddCertificatePage({
    super.key,
    required this.educationInstitution,
    required this.user,
  });

  @override
  State<AddCertificatePage> createState() => _AddCertificatePageState();
}

class _AddCertificatePageState extends State<AddCertificatePage> {
  final _formKey = GlobalKey<FormState>();
  File? file;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController curiculumController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController publicationDateController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  DateTime? _publicationDate;

  final IEducationInstitutionBll _educationInstitutionBll =
      EducationInstitutionBll();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final ScrollController _outerScrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Certificate'),
        elevation: 1,
        backgroundColor: const Color(0xFF7B3FE4),
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      body: Scrollbar(
        controller: _outerScrollController,
        thumbVisibility: true,
        thickness: 7,
        radius: const Radius.circular(16),
        child: SingleChildScrollView(
          controller: _outerScrollController,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 24),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 34,
                    vertical: isMobile ? 24 : 38,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text(
                            "Create a Certificate",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                              color: Color(0xFF7B3FE4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        _styledField(
                          controller: titleController,
                          label: "Title",
                          validator: (v) => v == null || v.isEmpty
                              ? "Please enter a certificate title"
                              : null,
                        ),

                        _styledField(
                          controller: typeController,
                          label: "Type (e.g. Diploma, Certificate, etc.)",
                          validator: (v) => v == null || v.isEmpty
                              ? "Please enter a certificate type"
                              : null,
                        ),

                        _styledField(
                          controller: gradeController,
                          label: "Grade",
                          validator: (v) => v == null || v.isEmpty
                              ? "Please enter a grade"
                              : null,
                        ),

                        _styledField(
                          controller: curiculumController,
                          label: "Curriculum",
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty
                              ? "Please enter a curriculum"
                              : null,
                        ),

                        _styledField(
                          controller: descriptionController,
                          label: "Description",
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty
                              ? "Please enter a description"
                              : null,
                        ),

                        // Date field
                        _styledDateField(
                          context: context,
                          controller: publicationDateController,
                          label: "Publication Date",
                          date: _publicationDate,
                          onPick: (d) {
                            setState(() {
                              _publicationDate = d;
                              publicationDateController.text =
                                  "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                            });
                          },
                        ),

                        _styledField(
                          controller: passwordController,
                          label: "Password to open your Blockchain Wallet",
                          obscureText: true,
                        ),

                        // File picker
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.attach_file,
                                      size: 20, color: Colors.white),
                                  label: const Text(
                                    "Select a file",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7B3FE4),
                                    elevation: 1,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _selectQuoteFile,
                                ),
                                const SizedBox(width: 8),
                                if (file != null)
                                  Flexible(
                                    child: Text(
                                      file!.path.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B3FE4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "+ Add Certificate",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _styledDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required DateTime? date,
    required Function(DateTime) onPick,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.date_range),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          );
          if (picked != null) {
            onPick(picked);
          }
        },
        validator: (value) {
          if (date == null) return "Please pick a publication date";
          return null;
        },
      ),
    );
  }

  Future<void> _selectQuoteFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'doc',
        'docx',
        'txt',
        'rtf',
        'odt',
        'ods',
        'odp',
        'ppt',
        'pptx',
        'xls',
        'xlsx'
      ],
    );

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final certificate = Certificate();
      certificate.title = titleController.text;
      certificate.type = typeController.text;
      certificate.grade = gradeController.text;
      certificate.curriculum = curiculumController.text;
      certificate.description = descriptionController.text;
      certificate.publicationDate = publicationDateController.text;
      certificate.file = file;

      _educationInstitutionBll.createCertificate(
        widget.educationInstitution,
        widget.user,
        certificate,
        passwordController.text,
      );

      _formKey.currentState!.save();
      Navigator.pop(context);
    }
  }
}
