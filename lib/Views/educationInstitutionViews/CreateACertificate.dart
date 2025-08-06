import 'dart:io';

import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/EducationInstitutionParameter.dart';
import 'package:solid_cv/Views/educationInstitutionViews/AddCertificatePage.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/UserSearchList.dart';
import 'package:solid_cv/business_layer/EducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IEducationInstitutionBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/EducationInstitution.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';

class CreateACertificate extends StatefulWidget {
  const CreateACertificate({super.key});

  @override
  _CreateACertificateState createState() => _CreateACertificateState();
}

class _CreateACertificateState extends State<CreateACertificate> {
  final IUserBLL _userBLL = UserBll();
  final IEducationInstitutionBll _educationInstitutionBll =
      EducationInstitutionBll();
  int _educationInstitutionId = 0;
  late Future<EducationInstitution> _educationInstitution;
  late Future<List<User>> _usersFromSearch;
  final TextEditingController searchController = TextEditingController();

  File? file;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController curiculumController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController publicationDateController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    final EducationInstitutionParameter args = ModalRoute.of(context)!
        .settings
        .arguments as EducationInstitutionParameter;
    _educationInstitutionId = args.id;
    _educationInstitution = _educationInstitutionBll
        .getEducationInstitution(_educationInstitutionId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Certificate'),
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: UserSearchList(
        hintText: "Search User",
        trailingIcon: Icons.add,
        cardTitle: "Search for a user to assign a certificate",
        cardSubtitle: "Start typing a name or email.",
        emptyMessage: "No user found.",
        errorMessage: "Error while searching.",
        onSearch: (term) => _userBLL.searchUsers(SearchTherms(term: term)),
        onUserTap: (user) async {
          final institution = await _educationInstitution;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCertificatePage(
                educationInstitution: institution,
                user: user,
              ),
            ),
          );
        },
      ),
    );
  }
}
