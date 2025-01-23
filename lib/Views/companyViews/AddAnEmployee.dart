import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
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
  int _companyId = 0;
  late Future<Company> _company;
  late Future<List<User>> _usersFromSearch;
  late Future<List<User>> _employees;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var searchTherms = SearchTherms();
    searchTherms.term = searchController.text;
    _usersFromSearch = _userBLL.searchUsers(searchTherms);
  }

  @override
  Widget build(BuildContext context) {
    _employees = Future.value([]);
    final CompanyParameter args =
        ModalRoute.of(context)!.settings.arguments as CompanyParameter;
    _companyId = args.id;
    _company = _companyBll.getCompany(_companyId);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add an Employee'),
        ),
        bottomNavigationBar: const MainBottomNavigationBar(),
        body: ListView(
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                    _openAddEmployeeDialog(context, user);
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
        ));
  }

  _openAddEmployeeDialog(BuildContext context, User user) {
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          titlePadding: const EdgeInsets.all(16.0),
          title: const Text('Add Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Start Date (dd/mm/yyyy)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                controller: startDateController,
              ),
              SizedBox(
                height: 10,
                width: MediaQuery.of(context).size.width, //screen width
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText:
                      'End Date (dd/mm/yyyy) (leave blank if still working)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                controller: endDateController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                controller: roleController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                controller: descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Password (to unlock your blockchain wallet)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                controller: passwordController,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Add the user as an employee
                var experienceRecord = ExperienceRecord(
                  title: roleController.text,
                  startDate: startDateController.text,
                  endDate: endDateController.text,
                  description: descriptionController.text,
                );
                await _companyBll.addEmployee(
                    user, experienceRecord, _companyId, passwordController.text);
              },
              child: const Text('+ Add'),
            ),
          ],
        );
      },
    );
  }
}
