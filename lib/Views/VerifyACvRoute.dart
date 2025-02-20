import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/SearchTherms.dart';
import 'package:solid_cv/models/User.dart';

class VerifyACvRoute extends StatefulWidget {
  const VerifyACvRoute({super.key});

  @override
  _VerifyACvRouteState createState() => _VerifyACvRouteState();
}

class _VerifyACvRouteState extends State<VerifyACvRoute> {
  IUserBLL _userBLL = UserBll();
  late Future<List<User>> _usersFromSearch;
  final TextEditingController searchController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    var searchTherms = SearchTherms();
    searchTherms.term = searchController.text;
    _usersFromSearch = _userBLL.searchUsers(searchTherms);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify a CV'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
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
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      color: Theme.of(context).primaryColor),
                                  onTap: () async {
                                    // Handle onTap event if needed
                                    Navigator.pushNamed(
                                      context,
                                      '/user/${user.id}',
                                    );
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
}