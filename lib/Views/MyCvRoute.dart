import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
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
      body: FutureBuilder<List<ExperienceRecord>>(
        future: _workExperiences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No work experiences found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final experience = snapshot.data![index];
                return ListTile(
                  title: Text(experience.title!),
                  subtitle: Text('${experience.company} '),
                );
              },
            );
          }
        },
      ),
    );
  }
}
