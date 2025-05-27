import 'package:flutter/material.dart';
import 'package:solid_cv/Views/admin-views/AdminBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';

class AdminUsersPage extends StatelessWidget {
   AdminUsersPage({super.key});

  final IUserBLL _userService = UserBll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👤 All Users')),
      bottomNavigationBar: const AdminBottomNavigationBar(),
      body: FutureBuilder<List<User>>(
        future: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!;
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListTile(user: user);
            },
          );
        },
      ),
    );
  }
}

class UserListTile extends StatelessWidget {
  final User user;
  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(user.id),
      leading: const CircleAvatar(
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(user.getEasyName() ?? "Unnamed"),
      subtitle: Text(user.email ?? "-"),
      trailing: user.roles != null
          ? Chip(
              label: Text(user.roles!.contains("ROLE_ADMIN") ? "Admin" : "User"),
              backgroundColor: user.roles!.contains("ROLE_ADMIN")
                  ? Colors.deepPurpleAccent
                  : Colors.grey.shade300,
              labelStyle: const TextStyle(color: Colors.white),
            )
          : null,
    );
  }
}
