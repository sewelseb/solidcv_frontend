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
      appBar: AppBar(
        title: const Text('👤 All Users'),
        backgroundColor: const Color(0xFF7B3FE4),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AdminBottomNavigationBar(),
      body: FutureBuilder<List<User>>(
        future: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF7B3FE4)),
                  SizedBox(height: 16),
                  Text('Loading users...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "❌ Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No users found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!;
          return Column(
            children: [
              // Stats header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Users',
                        value: users.length.toString(),
                        icon: Icons.people,
                        color: const Color(0xFF7B3FE4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Verified',
                        value: users.where((u) => u.isVerified == true).length.toString(),
                        icon: Icons.verified_user,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Configured',
                        value: users.where((u) => u.isFirstConfigurationDone == true).length.toString(),
                        icon: Icons.settings_suggest,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Users list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserListTile(user: user);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
    final isEmailVerified = user.isVerified ?? false;
    final isConfigured = user.isFirstConfigurationDone ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 1,
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Leading avatar with status indicator
              Stack(
                children: [
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
                  // Status indicator dot
                  if (!isEmailVerified || !isConfigured)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: !isEmailVerified ? Colors.red : Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with name
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
                    
                    // Email row with verification status
                    Row(
                      children: [
                        Icon(
                          isEmailVerified ? Icons.email : Icons.email_outlined,
                          size: 14,
                          color: isEmailVerified ? Colors.green.shade600 : Colors.red.shade600,
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
                        // Verification badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isEmailVerified ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEmailVerified ? "✓ Verified" : "✗ Unverified",
                            style: TextStyle(
                              color: isEmailVerified ? Colors.green.shade700 : Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Configuration status row
                    Row(
                      children: [
                        Icon(
                          isConfigured ? Icons.settings_suggest : Icons.settings_outlined,
                          size: 14,
                          color: isConfigured ? Colors.green.shade600 : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isConfigured ? "Profile configured" : "Setup incomplete",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        // Configuration badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isConfigured ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isConfigured ? "✓ Done" : "⚠ Pending",
                            style: TextStyle(
                              color: isConfigured ? Colors.green.shade700 : Colors.orange.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
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
                  
                  // Overall status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getOverallStatusColor(isEmailVerified, isConfigured).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getOverallStatusColor(isEmailVerified, isConfigured),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getOverallStatusText(isEmailVerified, isConfigured),
                      style: TextStyle(
                        color: _getOverallStatusColor(isEmailVerified, isConfigured),
                        fontSize: 9,
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

  Color _getOverallStatusColor(bool isEmailVerified, bool isConfigured) {
    if (isEmailVerified && isConfigured) {
      return Colors.green;
    } else if (isEmailVerified && !isConfigured) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getOverallStatusText(bool isEmailVerified, bool isConfigured) {
    if (isEmailVerified && isConfigured) {
      return "ACTIVE";
    } else if (isEmailVerified && !isConfigured) {
      return "SETUP";
    } else {
      return "PENDING";
    }
  }

  void _viewUserProfile(BuildContext context, User user) {
    // Navigate to user profile page
    Navigator.pushNamed(
      context,
      '/user/${user.id}',
    );
  }
}
