import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Certificate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MyEducation extends StatefulWidget {
  @override
  _MyEducationState createState() => _MyEducationState();
}

class _MyEducationState extends State<MyEducation> {
  IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  IUserBLL _userBll = UserBll();
  late Future<List<Certificate>> _certificates;
  late Future<List<Certificate>> _manuallyAddedCertificates;
  File? file;
  late TextEditingController _publicationDateController;
  @override
  void initState() {
    super.initState();
    _publicationDateController = TextEditingController(); // 👈 Initialisé ici
  }

  @override
  void dispose() {
    _publicationDateController.dispose(); // 👈 N'oublie pas de le libérer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _certificates = _blockchainWalletBll.getCertificatesForCurrentUser();
    _manuallyAddedCertificates = _userBll.getMyManuallyAddedCertificates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 500;
              if (isSmallScreen) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Education',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showAddCertificateDialog();
                      },
                      child: const Text('+ Add manually a new certification'),
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Education',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showAddCertificateDialog();
                      },
                      child: const Text('+ Add manually a new certification'),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        const Text(
          "Validated by the blockchain",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        FutureBuilder<List<Certificate>>(
          future: _certificates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No certificates found.'));
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...snapshot.data!.map((certificate) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              certificate.title!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              certificate.description!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //   'Issued by: ${certificate.}',
                                //   style: const TextStyle(
                                //   fontSize: 14,
                                //   fontStyle: FontStyle.italic,
                                //   ),
                                // ),
                                Text(
                                  'Date: ${certificate.publicationDate}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const Text(
                    "Manually added",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  FutureBuilder<List<Certificate>>(
                    future: _manuallyAddedCertificates,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child:
                                Text('No manually added certificates found.'));
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!.map((certificate) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        certificate.title!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Text(
                                      //   certificate.description!,
                                      //   style: const TextStyle(
                                      //   fontSize: 18,
                                      //   color: Colors.black54,
                                      //   ),
                                      // ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Date: ${certificate.publicationDate}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              );
            }
          },
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
    String? _filePath;
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
                      onPressed: () => _selectQuoteFile(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text(
                        "Select a file",
                        style: TextStyle(color: Colors.white),
                      )),
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

  _selectQuoteFile() async {
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
}
