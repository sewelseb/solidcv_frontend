import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/userWidgets/EducationWidget.dart';
import 'package:solid_cv/Views/widgets/userWidgets/SkillsWidget.dart';
import 'package:solid_cv/Views/widgets/userWidgets/WorkExperienceWidget.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';

class UserPage extends StatefulWidget {
  final String id;

  UserPage({required this.id});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  IUserBLL _userBLL = UserBll();
  late Future<User> user;

  @override
  void initState() {
    super.initState();
    user = _userBLL.getUser(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<User>(
          future: user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${user.getEasyName()}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    WorkExperienceWidget(userId: user.id.toString()),
                    const SizedBox(height: 16),
                    EducationWidget(userId: user.id.toString()),
                    const SizedBox(height: 16),
                    SkillsWidget(userId: user.id.toString()),
                  ],
                ),
              );
            } else {
              return Center(child: Text('No user found.'));
            }
          },
        ),
      ),
    );
  }
}