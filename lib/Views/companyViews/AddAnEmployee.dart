import 'package:cryptography/helpers.dart';
import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkCreatEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkEndedEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSWorkPromotedEvent.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';
import 'package:intl/intl.dart';

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
  List<CleanExperience> _availableExperiences = [];

  @override
  void initState() {
    super.initState();
    var searchTherms = SearchTherms();
    searchTherms.term = searchController.text;
    _usersFromSearch = _userBLL.searchUsers(searchTherms);
    _workExperiences = _walletBll.getEventsForCurrentUser();
  }

  String? _selectedStreamEndEventId;
  String? _selectedStreamPromoteEventId;

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<CleanExperience> experiences) {
    _availableExperiences = experiences
        .where((e) =>
            e.title != null &&
            e.startDate != null &&
            e.experienceStreamId != null)
        .toList();

    return _availableExperiences.map<DropdownMenuItem<String>>((e) {
      final label =
          "${e.companyName ?? 'Company'} - ${e.title ?? 'Title'} (${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(e.startDate!))})";
      return DropdownMenuItem<String>(
        value: e.experienceStreamId!,
        child: Text(label),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final CompanyParameter args =
        ModalRoute.of(context)!.settings.arguments as CompanyParameter;
    _companyId = args.id;
    _company = _companyBll.getCompany(_companyId);

    return Scaffold(
      appBar: AppBar(title: const Text('Add an Employee')),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                  labelText: 'Search User', border: OutlineInputBorder()),
              controller: searchController,
              onChanged: (value) {
                var searchTherms = SearchTherms();
                searchTherms.term = value;
                setState(() {
                  _usersFromSearch = _userBLL.searchUsers(searchTherms);
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFromSearch,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error: \${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No user found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final user = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: Icon(Icons.person,
                                color: Theme.of(context).primaryColor),
                            title: Text(user.getEasyName()!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: Icon(Icons.add,
                                color: Theme.of(context).primaryColor),
                            onTap: () => _openAddEmployeeDialog(context, user),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEmployeeDialog(BuildContext context, User user) {
    final TextEditingController roleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController newTitleController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController promotionDateController =
        TextEditingController();
    final TextEditingController createPasswordController =
        TextEditingController();
    final TextEditingController endPasswordController = TextEditingController();
    final TextEditingController promotePasswordController =
        TextEditingController();

    DateTime? _startDate;
    DateTime? _endDate;
    DateTime? _promotionDate;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return LayoutBuilder(
  builder: (context, constraints) {
    double maxWidth;
    if (constraints.maxWidth < 600) {
      maxWidth = constraints.maxWidth * 0.98;
    } else {
      maxWidth = 540;
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: FutureBuilder<List<CleanExperience>>(
          future: _workExperiences,
          builder: (context, snapshot) {
            final dropdownItems = snapshot.hasData
                ? _buildDropdownItems(snapshot.data!)
                : [];

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add or Update Experience',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                          Card(
                            elevation: 0,
                            color: Colors.grey[50],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("▶️ Create Work Experience",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 14),
                                  TextField(
                                      decoration: const InputDecoration(
                                          labelText: 'Role',
                                          border: OutlineInputBorder()),
                                      controller: roleController),
                                  const SizedBox(height: 10),
                                  TextField(
                                      decoration: const InputDecoration(
                                          labelText: 'Description',
                                          border: OutlineInputBorder()),
                                      controller: descriptionController),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: startDateController,
                                    decoration: const InputDecoration(
                                        labelText: 'Start Date',
                                        border: OutlineInputBorder()),
                                    readOnly: true,
                                    onTap: () async {
                                      _startDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (_startDate != null) {
                                        startDateController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(_startDate!);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: createPasswordController,
                                    decoration: const InputDecoration(
                                        labelText: 'Wallet Password',
                                        border: OutlineInputBorder()),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple[300],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        final company = await _companyBll
                                            .getCompany(_companyId);
                                        final event = WorkCreatedEvent(
                                          id: randomBytesAsHexString(16),
                                          timestamp: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          title: roleController.text,
                                          startDate: _startDate
                                                  ?.millisecondsSinceEpoch ??
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                          description:
                                              descriptionController.text,
                                          companyName:
                                              company.name ?? 'Unknown',
                                          companyWallet:
                                              company.ethereumAddress ?? '',
                                          location: 'Unknown',
                                          experienceStreamId:
                                              randomBytesAsHexString(16),
                                        );
                                        await _companyBll.addEmployeeEvents(
                                            user,
                                            event,
                                            _companyId,
                                            createPasswordController.text);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('+ Create',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // End Experience
                          Card(
                            elevation: 0,
                            color: Colors.grey[50],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: const [
                                      Icon(Icons.stop_circle,
                                          color: Colors.red, size: 22),
                                      SizedBox(width: 6),
                                      Text("End Experience",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _selectedStreamEndEventId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: "Select Experience to End",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: dropdownItems
                                        .cast<DropdownMenuItem<String>>(),
                                    onChanged: (value) {
                                      // On set dans le scope de showDialog, donc StateSetter
                                      (context as Element).markNeedsBuild();
                                      _selectedStreamEndEventId = value;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: endDateController,
                                    decoration: const InputDecoration(
                                        labelText: 'End Date',
                                        border: OutlineInputBorder()),
                                    readOnly: true,
                                    onTap: () async {
                                      _endDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (_endDate != null) {
                                        endDateController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(_endDate!);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: endPasswordController,
                                    decoration: const InputDecoration(
                                        labelText: 'Wallet Password',
                                        border: OutlineInputBorder()),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[400],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.stop,
                                          color: Colors.white),
                                      onPressed: () async {
                                        final company = await _companyBll
                                            .getCompany(_companyId);
                                        final event = WorkEndedEvent(
                                          id: randomBytesAsHexString(16),
                                          timestamp: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          endDate: _endDate
                                                  ?.millisecondsSinceEpoch ??
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                          experienceStreamId:
                                              _selectedStreamEndEventId ?? '',
                                          companyName:
                                              company.name ?? 'Unknown',
                                          companyWallet:
                                              company.ethereumAddress ?? '',
                                        );
                                        await _companyBll.addEmployeeEvents(
                                            user,
                                            event,
                                            _companyId,
                                            endPasswordController.text);
                                        Navigator.of(context).pop();
                                      },
                                      label: const Text('End',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Promote Experience
                          Card(
                            elevation: 0,
                            color: Colors.grey[50],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: const [
                                      Icon(Icons.trending_up,
                                          color: Colors.blue, size: 22),
                                      SizedBox(width: 6),
                                      Text("Promote",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _selectedStreamPromoteEventId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: "Select Experience to Promote",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: dropdownItems
                                        .cast<DropdownMenuItem<String>>(),
                                    onChanged: (value) {
                                      (context as Element).markNeedsBuild();
                                      _selectedStreamPromoteEventId = value;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                      decoration: const InputDecoration(
                                          labelText: 'New Title',
                                          border: OutlineInputBorder()),
                                      controller: newTitleController),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: promotionDateController,
                                    decoration: const InputDecoration(
                                        labelText: 'Promotion Date',
                                        border: OutlineInputBorder()),
                                    readOnly: true,
                                    onTap: () async {
                                      _promotionDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (_promotionDate != null) {
                                        promotionDateController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(_promotionDate!);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: promotePasswordController,
                                    decoration: const InputDecoration(
                                        labelText: 'Wallet Password',
                                        border: OutlineInputBorder()),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[400],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.trending_up,
                                          color: Colors.white),
                                      onPressed: () async {
                                        final company = await _companyBll
                                            .getCompany(_companyId);
                                        final event = WorkPromotedEvent(
                                          id: randomBytesAsHexString(16),
                                          timestamp: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          newTitle: newTitleController.text,
                                          promotionDate: _promotionDate
                                                  ?.millisecondsSinceEpoch ??
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                          experienceStreamId:
                                              _selectedStreamPromoteEventId ??
                                                  '',
                                          companyName:
                                              company.name ?? 'Unknown',
                                          companyWallet:
                                              company.ethereumAddress ?? '',
                                        );
                                        await _companyBll.addEmployeeEvents(
                                            user,
                                            event,
                                            _companyId,
                                            promotePasswordController.text);
                                        Navigator.of(context).pop();
                                      },
                                      label: const Text('Promote',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
