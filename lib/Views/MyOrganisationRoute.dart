import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyCompanies.dart';
import 'package:solid_cv/Views/widgets/MyEducationIstitutions.dart';

class MyOrganisationsRoute extends StatefulWidget {
  const MyOrganisationsRoute({super.key});

  @override
  _MyOrganisationRoutesState createState() => _MyOrganisationRoutesState();
}

class _MyOrganisationRoutesState extends State<MyOrganisationsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Organisations'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(text: 'My Companies'),
                Tab(text: 'My Education Institutions'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        //screen size minus the app bar and the bottom navigation bar
                        height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - 100,
                        child: const MyCompanies()
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-a-company-form');
                          },
                          child: const Text('+ Add Company'),
                        ),
                      ),
                      // Add your list of companies here
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        //screen size minus the app bar and the bottom navigation bar
                        height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - 100,
                        child: MyEducationInstitutions(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-a-education-institution-form');
                          },
                          child: const Text('+ Add Education Institution'),
                        ),
                      ),
                      // Add your list of education institutions here
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
