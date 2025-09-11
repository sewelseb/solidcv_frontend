import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/companyViews/AddEmployeeExperiencePage.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/UserSearchList.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';

class AddAnEmployee extends StatefulWidget {
  const AddAnEmployee({super.key});

  @override
  _AddAnEmployeeState createState() => _AddAnEmployeeState();
}

class _AddAnEmployeeState extends State<AddAnEmployee> {
  final ICompanyBll _companyBll = CompanyBll();
  final IUserBLL _userBLL = UserBll();
  final IBlockchainWalletBll _walletBll = BlockchainWalletBll();
  int _companyId = 0;
  late Future<Company> _company;
  late Future<List<User>> _usersFromSearch;
  late Future<List<CleanExperience>> _workExperiences;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var searchTherms = SearchTherms();
    searchTherms.term = searchController.text;
    _usersFromSearch = _userBLL.searchUsers(searchTherms);
    _workExperiences = _walletBll.getEventsForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final CompanyParameter args =
        ModalRoute.of(context)!.settings.arguments as CompanyParameter;
    _companyId = args.id;
    _company = _companyBll.getCompany(_companyId);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addAnEmployee)),
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: UserSearchList(
          cardTitle: AppLocalizations.of(context)!.searchUserToAddAsEmployee,
          cardSubtitle: AppLocalizations.of(context)!.clickUserToAddToCompany,
          onSearch: (term) => _userBLL.searchUsers(SearchTherms(term: term)),
          onUserTap: (user) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEmployeeExperiencePage(
                  user: user,
                  companyId: _companyId,
                  companyBll: _companyBll,
                  walletBll: _walletBll,
                  company: _company,
                ),
              ),
            );
          },
          trailingIcon: Icons.add,
        ),
      ),
    );
  }
}
