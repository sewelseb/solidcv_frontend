import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';

class CreateACertificate extends StatefulWidget {
  @override
  _CreateACertificateState createState() => _CreateACertificateState();
}

class _CreateACertificateState extends State<CreateACertificate> {
  final _formKey = GlobalKey<FormState>();
  DateTime _issueDate = DateTime.now();

  final IUserBLL _userBLL = UserBll();
  int _companyId = 0;
  late Future<EducationInstitution> _educationInstitution;
  late Future<List<User>> _usersFromSearch;
  late Future<List<User>> _employees;
  final TextEditingController searchController = TextEditingController();

  File? file;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController curiculumController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController publicationDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var searchTherms = SearchTherms();
    searchTherms.term = searchController.text;
    _usersFromSearch = _userBLL.searchUsers(searchTherms);
    //publicationDateController.text = "${_issueDate.day}-${_issueDate.month}-${_issueDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    var searchTherms = SearchTherms();
    searchTherms.term = searchController.text;
    _usersFromSearch = _userBLL.searchUsers(searchTherms);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Certificate'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search User',
                        border: OutlineInputBorder(),
                      ),
                      controller: searchController,
                      onChanged: (value) {
                        var searchTherms = SearchTherms();
                        searchTherms.term = searchController.text;
                        _usersFromSearch = _userBLL.searchUsers(searchTherms);
                      },
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<User>>(
                      future: _usersFromSearch,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No user found.'));
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height -
                                200, //height of the screen - height of the other widgets
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final user = snapshot.data![index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: ListTile(
                                    leading: Icon(Icons.person,
                                        color: Theme.of(context).primaryColor),
                                    title: Text(
                                      user.getEasyName()!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Icon(Icons.add,
                                        color: Theme.of(context).primaryColor),
                                    onTap: () {
                                      // Handle onTap event if needed
                                      _addACertificateToUserDialog(
                                          context, user);
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  _addACertificateToUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a Certificate to User'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    controller: titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a certificate title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                    },
                  ),
                  SizedBox(
                    height: 10,
                    width: MediaQuery.of(context).size.width,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Type (e.g. Diploma, Certificate, etc.)',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    controller: typeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a certificate type';
                      }
                      return null;
                    },
                    onSaved: (value) {
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    controller: gradeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a grade';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Save the grade value
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Curriculum',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    controller: curiculumController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a curriculum';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Save the curriculum value
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    controller: descriptionController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Save the description value
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Publication Date',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    controller: publicationDateController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a publication date';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // Save the publication date value
                    },
                  ),
                  ElevatedButton(
                            onPressed: () => _selectQuoteFile(),
                            child: const Text("Select a file")),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('+ Add Certificate'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _selectQuoteFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt', 'rtf', 'odt', 'ods', 'odp', 'ppt', 'pptx', 'xls', 'xlsx'],
    );

    if (result != null) {
      file = File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }
}
