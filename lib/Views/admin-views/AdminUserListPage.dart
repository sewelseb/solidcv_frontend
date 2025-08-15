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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    final isAdmin = user.roles?.contains("ROLE_ADMIN") ?? false;    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 1,
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Leading avatar
              CircleAvatar(
                backgroundColor: isAdmin ? Colors.deepPurpleAccent : const Color(0xFF7B3FE4),
                child: Text(
                  (user.getEasyName() ?? "U").substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with name and country
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.getEasyName() ?? "Unnamed",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Email row
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email ?? "-",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // ID row
                    if (user.id != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "ID: ${user.id}",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Trailing section with role and button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Role chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.deepPurpleAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAdmin ? "Admin" : "User",
                      style: TextStyle(
                        color: isAdmin ? Colors.white : Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // View Profile button
                  SizedBox(
                    width: 60,
                    height: 26,
                    child: ElevatedButton(
                      onPressed: () => _viewUserProfile(context, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B3FE4),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewUserProfile(BuildContext context, User user) {
    // Navigate to user profile page
    Navigator.pushNamed(
      context,
      '/user/${user.id}',
    );
  }
}
