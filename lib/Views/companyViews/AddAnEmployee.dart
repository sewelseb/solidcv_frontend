import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';
import 'package:solid_cv/models/User.dart';

class AddAnEmployee extends StatefulWidget {
  const AddAnEmployee({super.key});

  @override
  _AddAnEmployeeState createState() => _AddAnEmployeeState();
}

class _AddAnEmployeeState extends State<AddAnEmployee> {
  final ICompanyBll _companyBll = CompanyBll();
  late Future<Company> _company;
  late Future<List<User>> _employees;

  @override
  Widget build(BuildContext context) {
    _employees = Future.value([]);
    final CompanyParameter args =
        ModalRoute.of(context)!.settings.arguments as CompanyParameter;
    _company = _companyBll.getCompany(args.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an Employee'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: 
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
            onChanged: (value) {
              // Handle search logic here
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<User>>(
            future: _employees,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No user found.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
                        title: Text(
                          user.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.add, color: Theme.of(context).primaryColor),
                        onTap: () {
                          // Handle onTap event if needed
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    )
    );
  }
}