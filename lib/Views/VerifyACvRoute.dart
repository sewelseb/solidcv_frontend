import 'package:flutter/material.dart';
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
  final IUserBLL _userBLL = UserBll();
  late Future<List<User>> _usersFromSearch;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _usersFromSearch = Future.value([]);
  }

  void _search() {
    setState(() {
      var searchTerms = SearchTherms();
      searchTerms.term = searchController.text;
      _usersFromSearch = _userBLL.searchUsers(searchTerms);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify a CV')),
      bottomNavigationBar: const MainBottomNavigationBar(),
      backgroundColor: const Color(0xFFF7F8FC),
      body: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        radius: const Radius.circular(18),
        thickness: 7,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : 0, vertical: isMobile ? 10 : 32),
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 570),
                child: Card(
                  color: Colors.white,
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 34,
                        vertical: isMobile ? 24 : 38),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Search for a user and verify their CV",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                              color: Color(0xFF7B3FE4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Search User',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF7B3FE4), width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                          ),
                          controller: searchController,
                          onChanged: (value) => _search(),
                        ),
                        const SizedBox(height: 18),
                        FutureBuilder<List<User>>(
                          future: _usersFromSearch,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(22),
                                child: CircularProgressIndicator(),
                              ));
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                    child: Text(
                                  'No user found.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                      fontStyle: FontStyle.italic),
                                )),
                              );
                            } else {
                              final users = snapshot.data!;
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/user/${user.id}');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F7FF),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color: Colors.deepPurple.shade50,
                                              width: 1),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 10),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.deepPurple.shade50,
                                              radius: 21,
                                              child: const Icon(Icons.person,
                                                  color: Colors.deepPurple,
                                                  size: 25),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Text(
                                                user.getEasyName() ?? "-",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                            Icon(Icons.arrow_forward_ios,
                                                color:
                                                    Colors.deepPurple.shade200,
                                                size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
