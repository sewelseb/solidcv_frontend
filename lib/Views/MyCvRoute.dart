import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyEducation.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';

class MyCvRoute extends StatefulWidget {
  const MyCvRoute({super.key});

  @override
  State<MyCvRoute> createState() => _MyCvRouteState();
}

class _MyCvRouteState extends State<MyCvRoute> {
  IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  late Future<List<ExperienceRecord>> _workExperiences;

  @override
  Widget build(BuildContext context) {
    _workExperiences = _blockchainWalletBll.getWorkExperiencesForCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My CV'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: ListView(
        shrinkWrap: true,
        children: [
          FutureBuilder<List<ExperienceRecord>>(
            future: _workExperiences,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No work experiences found.'));
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                      'Work Experiences',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      ),
                    ),
                    ...snapshot.data!.map((experience) {
                      return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                        experience.title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        ),
                        subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                          experience.company!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                          '${experience.startDate} - ${experience.endDate}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          ),
                        ],
                        ),
                      ),
                      );
                    }).toList(),
                  ],
                );
              }
            },
          ),
          MyEducation(),
        ],
      ),
    );
  }
}
