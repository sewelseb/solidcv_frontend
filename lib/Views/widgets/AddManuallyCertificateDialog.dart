import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:solid_cv/models/Certificate.dart';

typedef OnAddCertificate = void Function(Certificate cert);

class AddManuallyCertificateDialog extends StatefulWidget {
  final OnAddCertificate onAdd;

  const AddManuallyCertificateDialog({Key? key, required this.onAdd}) : super(key: key);

  static Future<void> show(BuildContext context, {required OnAddCertificate onAdd}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddManuallyCertificateDialog(onAdd: onAdd),
    );
  }

  @override
  State<AddManuallyCertificateDialog> createState() => _AddManuallyCertificateDialogState();
}

class _AddManuallyCertificateDialogState extends State<AddManuallyCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _publicationDateController = TextEditingController();
  String? _title, _description, _certificateType, _teachingInstitution, _grade, _curriculum;
  DateTime? _publicationDate;
  File? file;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 400;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 22,
        vertical: isMobile ? 14 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        width: isMobile ? double.infinity : 420,
        padding: EdgeInsets.fromLTRB(24, 30, 24, 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.workspace_premium_outlined, color: Color(0xFF7B3FE4), size: isMobile ? 24 : 30),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        isMobile ? 'Add Certificate' : 'Add New Certificate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 17 : 23,
                          color: Color(0xFF7B3FE4),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _buildTextFormField(
                  label: 'Title',
                  onSaved: (v) => _title = v,
                ),
                _buildTextFormField(
                  label: 'Certificate Type',
                  onSaved: (v) => _certificateType = v,
                ),
                _buildTextFormField(
                  label: 'Grade',
                  onSaved: (v) => _grade = v,
                ),
                _buildTextFormField(
                  label: 'Teaching Institution',
                  onSaved: (v) => _teachingInstitution = v,
                ),
                _buildTextFormField(
                  label: 'Description',
                  onSaved: (v) => _description = v,
                  multiline: true,
                ),
                _buildTextFormField(
                  label: 'Curriculum',
                  onSaved: (v) => _curriculum = v,
                  multiline: true,
                ),
                const SizedBox(height: 10),
                // Date picker stylé
                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        _publicationDate = picked;
                        _publicationDateController.text = picked.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _publicationDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Publication Date',
                        prefixIcon: Icon(Icons.event, color: Color(0xFF7B3FE4)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                      validator: (value) {
                        if (_publicationDate == null) return 'Please select a date';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sélecteur de fichier stylé
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_file_outlined, color: Colors.white, size: 20),
                  onPressed: _selectQuoteFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7B3FE4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                    textStyle: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  label: Text("Select a file"),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF7B3FE4),
                          side: BorderSide(color: Color(0xFF7B3FE4), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            widget.onAdd(
                              Certificate(
                                title: _title,
                                description: _description,
                                curriculum: _curriculum,
                                publicationDate: _publicationDate?.toIso8601String(),
                                type: _certificateType,
                                teachingInstitutionName: _teachingInstitution,
                                grade: _grade,
                                file: file,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B3FE4),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required void Function(String?) onSaved,
    bool multiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        maxLines: multiline ? 3 : 1,
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }

  Future<void> _selectQuoteFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt', 'rtf',
        'odt', 'ods', 'odp', 'ppt', 'pptx', 'xls', 'xlsx'
      ],
    );
    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }
}
