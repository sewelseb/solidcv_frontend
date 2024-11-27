import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';

class MyOrganisationsRoute extends StatefulWidget {
  @override
  _MyOrganisationRoutesState createState() => _MyOrganisationRoutesState();
}

class _MyOrganisationRoutesState extends State<MyOrganisationsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Organisations'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-a-company-form');
                          },
                          child: Text('+ Add Company'),
                        ),
                      ),
                      // Add your list of companies here
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Add your education institution addition logic here
                          },
                          child: Text('+ Add Education Institution'),
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
