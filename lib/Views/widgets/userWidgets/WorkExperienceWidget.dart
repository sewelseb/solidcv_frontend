import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/userWidgets/WorkExperienceFromBlockchain.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';
import 'package:solid_cv/models/User.dart';

class WorkExperienceWidget extends StatefulWidget {
  final String userId;

  WorkExperienceWidget({required this.userId});

  @override
  _WorkExperienceWidgetState createState() => _WorkExperienceWidgetState();
}

class _WorkExperienceWidgetState extends State<WorkExperienceWidget> {
  IUserBLL _userBLL = UserBll();
  late Future<User> _user;
  IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  late Future<List<ExperienceRecord>> _workExperiences;
  
  @override
  Widget build(BuildContext context) {
    _user = _userBLL.getUser(widget.userId).then((value) {
      if (value.ethereumAddress != null) _workExperiences = Future.value([]);

      _workExperiences = _blockchainWalletBll.getWorkExperience(value.ethereumAddress!);
      return value;
    });
      
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Work Experience',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          FutureBuilder<User>(
            future: _user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return FutureBuilder<List<ExperienceRecord>>(
                  future: _workExperiences,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No work experience found.'));
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...snapshot.data!.map((experience) {
                            return WorkExperienceFromBlockchain(workExperience: experience);
                          }).toList(),
                        ],
                      );
                    }
                  },
                );
              } else {
                return const Center(child: Text('No user found.'));
              }
            },
          ),
        ],
      ),
    );
  }
}