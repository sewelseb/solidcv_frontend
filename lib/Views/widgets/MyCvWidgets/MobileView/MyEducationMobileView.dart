import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/MyEducationMobileCard.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MyEducationMobileView extends StatefulWidget {
  const MyEducationMobileView({Key? key}) : super(key: key);

  @override
  _MyEducationMobileViewState createState() => _MyEducationMobileViewState();
}

class _MyEducationMobileViewState extends State<MyEducationMobileView> {
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  final IUserBLL _userBll = UserBll();
  final IEducationInstitutionBll _educationInstitutionBll =
      EducationInstitutionBll();

  late Future<List<Certificate>> _certificates;
  late Future<List<Certificate>> _manuallyAddedCertificates;
  late TextEditingController _publicationDateController;
  File? file;

  @override
  void initState() {
    super.initState();
    _publicationDateController = TextEditingController();
    _certificates = _blockchainWalletBll
        .getCertificatesForCurrentUser()
        .then((certs) async {
      for (final cert in certs) {
        if (cert.issuerBlockCahinWalletAddress != null) {
          final institution =
              await _educationInstitutionBll.getEducationInstitutionByWallet(
                  cert.issuerBlockCahinWalletAddress!);
          cert.logoUrl = institution?.getProfilePicture();
        }
      }
      return certs;
    });
    _manuallyAddedCertificates = _userBll.getMyManuallyAddedCertificates();
  }

  @override
  void dispose() {
    _publicationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        FutureBuilder<List<Certificate>>(
          future: _certificates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final blockchainCerts = snapshot.data ?? [];

            return Column(
              children: blockchainCerts
                  .map(
                    (c) => EducationMobileCard(
                      certificate: c,
                      isValidated: true,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        FutureBuilder<List<Certificate>>(
          future: _manuallyAddedCertificates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final manualCerts = snapshot.data ?? [];

            return Column(
              children: manualCerts
                  .map(
                    (c) => EducationMobileCard(
                      certificate: c,
                      isValidated: false,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Education',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _showAddCertificateDialog,
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add education',
        ),
      ],
    );
  }

  void _showAddCertificateDialog() {
    final _formKey = GlobalKey<FormState>();
    String? _title;
    String? _description;
    DateTime? _publicationDate;
    String? _certificateType;
    String? _teachingInstitution;
    String? _grade;
    String? _curriculum;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Certificate'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _title = value;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Certificate Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a certificate type';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _certificateType = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Grade'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a grade';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _grade = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Teaching Institution'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a teaching institution';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _teachingInstitution = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Curriculum'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a curriculum';
                      }
                      return null;
                    },
                    maxLines: 3,
                    onSaved: (value) {
                      _curriculum = value;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Publication Date'),
                    controller: _publicationDateController,
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          _publicationDate = picked;
                          _publicationDateController.text =
                              picked.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                    validator: (value) {
                      if (_publicationDate == null) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _selectQuoteFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "Select a file",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Add the new certificate to the list
                  setState(() {
                    _userBll.addMyCertificateManually(
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
                    _manuallyAddedCertificates =
                        _userBll.getMyManuallyAddedCertificates();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _selectQuoteFile() async {
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
      file = File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  BoxDecoration glassCardDecoration() => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B3FE4).withOpacity(0.18),
          width: 1.4,
        ),
      );
}
