import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/WorkExperienceCard.dart';
import 'package:solid_cv/Views/widgets/userWidgets/WorkExperienceFromBlockchain.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/models/User.dart';

class WorkExperienceWidget extends StatefulWidget {
  final String userId;

  const WorkExperienceWidget({super.key, required this.userId});

  @override
  _WorkExperienceWidgetState createState() => _WorkExperienceWidgetState();
}

class _WorkExperienceWidgetState extends State<WorkExperienceWidget> {
  final IUserBLL _userBLL = UserBll();
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();

  late Future<User> _user;
  late Future<List<CleanExperience>> _workExperiences;

  @override
  void initState() {
    super.initState();
    _user = _userBLL.getUser(widget.userId);
    _workExperiences = _user.then((user) {
      if (user.ethereumAddress != null) {
        return _blockchainWalletBll.getEventsForUser(user.ethereumAddress!);
      } else {
        return Future.value([]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Work Experience',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        FutureBuilder<List<CleanExperience>>(
          future: _workExperiences,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No work experience found.'));
            } else {
              final experiences = snapshot.data!;
              experiences.sort((a, b) => (b.endDate ?? 0).compareTo(a.endDate ?? 0));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: experiences.map((experience) {
                  return WorkExperienceFromBlockchain(workExperience: experience);
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}
