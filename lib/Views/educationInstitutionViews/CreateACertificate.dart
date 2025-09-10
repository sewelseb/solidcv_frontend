import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    //publicationDateController.text = "${_issueDate.day}-${_issueDate.month}-${_issueDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final EducationInstitutionParameter args = ModalRoute.of(context)!
        .settings
        .arguments as EducationInstitutionParameter;
    _educationInstitutionId = args.id;
    _educationInstitution = _educationInstitutionBll
        .getEducationInstitution(_educationInstitutionId);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.createCertificateTitle),
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: UserSearchList(
        hintText: localizations.searchUser,
        trailingIcon: Icons.add,
        cardTitle: localizations.searchUserCardTitle,
        cardSubtitle: localizations.searchUserCardSubtitle,
        emptyMessage: localizations.noUserFound,
        errorMessage: localizations.errorWhileSearching,
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
