import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/UserEducation.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/UserSkills.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/UserWorkExperienceCard.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';
import 'package:solid_cv/models/User.dart';

class UserCvDesktop extends StatefulWidget {
  final String userId;
  const UserCvDesktop({super.key, required this.userId});

  @override
  State<UserCvDesktop> createState() => _UserCvDesktopState();
}

class _UserCvDesktopState extends State<UserCvDesktop> {
  final IUserBLL _userBLL = UserBll();
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  final ICompanyBll _companyBll = CompanyBll();
  final ValueNotifier<bool> _isBioExpanded = ValueNotifier(false);

  late Future<User> _userFuture;
  late Future<List<UnifiedExperienceViewModel>> _experiencesFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userBLL.getUser(widget.userId);
    _experiencesFuture = _loadExperiences();
  }

  Future<List<UnifiedExperienceViewModel>> _loadExperiences() async {
    final user = await _userFuture;
    final cleanExperienceList = user.ethereumAddress != null
        ? await _blockchainWalletBll.getEventsForUser(user.ethereumAddress!)
        : <CleanExperience>[];
    final manualExperienceList =
        await _userBLL.getUsersManuallyAddedExperiences(widget.userId);

    final unifiedList = [
      ...cleanExperienceList.map(UnifiedExperienceViewModel.fromClean),
      ...manualExperienceList.map(UnifiedExperienceViewModel.fromManual),
    ];

    for (final experience in unifiedList) {
      if (experience.companyWallet != null) {
        final company =
            await _companyBll.fetchCompanyByWallet(experience.companyWallet!);
        experience.companyLogoUrl = company?.getProfilePicture();
        experience.location =
            '${company?.addressCity}, ${company?.addressCountry}';
      }
    }

    unifiedList.sort((a, b) =>
        (b.endDate ?? DateTime.now().millisecondsSinceEpoch)
            .compareTo(a.endDate ?? DateTime.now().millisecondsSinceEpoch));

    return unifiedList;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    double cvWidth;
    if (isMobile) {
      cvWidth = screenWidth * 0.95;
    } else if (screenWidth < 1200) {
      cvWidth = screenWidth * 0.90;
    } else {
      cvWidth = screenWidth * 0.85;
    }

    return Scaffold(
      appBar: AppBar(
          title: FutureBuilder<User>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading...');
              }
              final user = snapshot.data!;
              return Text(user.getEasyName() ?? 'User CV');
            },
          ),
          backgroundColor: const Color(0xFF7B3FE4)),
      backgroundColor: const Color(0xFFF9FBFC),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            width: cvWidth,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A69F1), Color(0xFF8A5CF0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) _buildSidebar(width: cvWidth * 0.28),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildExperienceSection(),
                            const SizedBox(height: 32),
                            UserEducation(userId: widget.userId),
                            const SizedBox(height: 32),
                            UserSkillsWidget(userId: widget.userId),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar({required double width}) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: width);
        }
        final user = snapshot.data!;
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  backgroundImage: NetworkImage(user.getProfilePicture()),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.getEasyName() ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.email ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _infoTile(icon: Icons.phone, text: user.phoneNumber ?? "-"),
              const SizedBox(height: 12),
              _infoTile(
                  icon: Icons.link,
                  text: user.linkedin ?? "Ajoutez votre lien LinkedIn"),
              const SizedBox(height: 12),
              _infoTile(
                  icon: Icons.description,
                  text: user.biography ?? '',
                  expandable: true),
              const SizedBox(height: 18),
              const Divider(color: Colors.white24),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(
      {required IconData icon, required String text, bool expandable = false}) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    if (!expandable) {
      return Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isBioExpanded,
      builder: (context, expanded, _) {
        return InkWell(
          onTap: () => _isBioExpanded.value = !expanded,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: expanded ? null : 2,
                  overflow:
                      expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white54,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
              height: 60, child: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(user.getEasyName() ?? '',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              value: 1,
              color: Color(0xFF5A69F1),
              backgroundColor: Color(0xFFE0E0E0),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Work Experience',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        FutureBuilder<List<UnifiedExperienceViewModel>>(
          future: _experiencesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No work experiences available.');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.data!
                  .map((e) => UserWorkExperienceCard(experience: e))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
