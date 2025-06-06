import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyCompanies.dart';
import 'package:solid_cv/Views/widgets/MyEducationIstitutions.dart';

class MyOrganisationsRoute extends StatefulWidget {
  const MyOrganisationsRoute({super.key});

  @override
  _MyOrganisationRoutesState createState() => _MyOrganisationRoutesState();
}

class _MyOrganisationRoutesState extends State<MyOrganisationsRoute>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['tabIndex'] is int) {
      final index = args['tabIndex'] as int;
      if (index >= 0 && index < _tabController.length) {
        _tabController.index = index;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF7B3FE4),
              unselectedLabelColor: Colors.black54,
              indicatorColor: const Color(0xFF7B3FE4),
              tabs: const [
                Tab(text: 'My Companies'),
                Tab(text: 'My Education Institutions'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 0, right: 0),
                  child: Column(
                    children: [
                      const Expanded(child: MyCompanies()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: 220,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/add-a-company-form');
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
                      const Expanded(child: MyEducationInstitutions()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: 270,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/add-a-education-institution-form');
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
    );
  }
}
