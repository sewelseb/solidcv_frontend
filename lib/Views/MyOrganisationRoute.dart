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
        elevation: 1,
        backgroundColor: const Color(0xFF7B3FE4),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: const Color(0xFFF7F8FC),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFF7B3FE4),
                unselectedLabelColor: Colors.black54,
                indicatorColor: Color(0xFF7B3FE4),
                tabs: [
                  Tab(text: 'My Companies'),
                  Tab(text: 'My Education Institutions'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 0, right: 0),
                    child: Column(
                      children: [
                        Expanded(child: MyCompanies()),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            width: 220,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/add-a-company-form');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B3FE4),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.add_business_rounded),
                              label: const Text('Add Company'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 0, right: 0),
                    child: Column(
                      children: [
                        Expanded(child: MyEducationInstitutions()),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            width: 270,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/add-a-education-institution-form');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B3FE4),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.add_business_rounded),
                              label: const Text('Add Education Institution'),
                            ),
                          ),
                        ),
                      ],
                    ),
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
