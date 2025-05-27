import 'package:flutter/material.dart';
import 'package:solid_cv/Views/admin-views/AdminBottomNavigationBar.dart';
import 'package:solid_cv/data_access_layer/IStatisticsService.dart';
import 'package:solid_cv/data_access_layer/StatisticsService.dart';
import 'package:solid_cv/models/Statistics.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final IStatisticsService _adminBLL = StatisticsService();
  late Future<Statistics> _stats;

  @override
  void initState() {
    super.initState();
    _stats = _adminBLL.getAdminStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Admin Dashboard')),
      bottomNavigationBar: const AdminBottomNavigationBar(),
      body: FutureBuilder<Statistics>(
        future: _stats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No statistics available."));
          }

          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.8,
                        children: [
                          _buildStatCard("👤 Users", stats.users),
                          _buildStatCard("🏢 Companies", stats.companies),
                          _buildStatCard("🎓 Institutions", stats.institutions),
                        ],
                      )
                    : Column(
                        children: [
                          _buildStatCard("👤 Users", stats.users),
                          _buildStatCard("🏢 Companies", stats.companies),
                          _buildStatCard("🎓 Institutions", stats.institutions),
                        ],
                      );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.bar_chart, color: Colors.indigo),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text('$value', style: const TextStyle(fontSize: 20)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
