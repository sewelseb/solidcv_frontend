import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/AddedManuallyWorkExperienceForm.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/MyEducationMobileView.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/WorkExperienceMobileCard.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';
import 'package:solid_cv/models/User.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solid_cv/config/BackenConnection.dart';

class MyCvMobile extends StatefulWidget {
  const MyCvMobile({super.key});

  @override
  State<MyCvMobile> createState() => _MyCvMobileState();
}

class _MyCvMobileState extends State<MyCvMobile> {
  late final IBlockchainWalletBll _blockchainWalletBll;
  late final IUserBLL _userBLL = UserBll();
  late Future<User> _userFuture;
  final ValueNotifier<bool> _isBioExpanded = ValueNotifier(false);
  late final ICompanyBll _company = CompanyBll();

  final ValueNotifier<int> _refreshTrigger = ValueNotifier(0);
  List<UnifiedExperienceViewModel>? _cachedExperiences;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _blockchainWalletBll = BlockchainWalletBll();
    _userFuture = _userBLL.getCurrentUser();
  }

  void _refreshExperiences() {
    _cachedExperiences = null;
    _lastFetchTime = null;
    _refreshTrigger.value++;
  }

  Future<List<UnifiedExperienceViewModel>> _fetchAllExperiences() async {

    final user = await _userFuture;

    if (_cachedExperiences != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedExperiences!;
    }

    List<dynamic> results;

    if (user.ethereumAddress == null) {
      results = await Future.wait([
        Future.value(<CleanExperience>[]),
        _userBLL.getMyManuallyAddedExperiences(),
      ]);
    }
    else {
      results = await Future.wait([
        _blockchainWalletBll.getEventsForCurrentUser(),
        _userBLL.getMyManuallyAddedExperiences(),
      ]);
    }

    final cleanExperienceList = results[0] as List<CleanExperience>;
    final manualExperienceList = results[1] as List<ManualExperience>;

    final unifiedList = [
      ...cleanExperienceList.map(UnifiedExperienceViewModel.fromClean),
      ...manualExperienceList.map(UnifiedExperienceViewModel.fromManual),
    ];

    for (var experience in unifiedList) {
      if (experience.companyWallet != null) {
        final company = await _company.fetchCompanyByWallet(experience.companyWallet!);
        experience.companyLogoUrl = company?.getProfilePicture();
        experience.location = '${company?.addressCity}, ${company?.addressCountry}';
      }
    }
    unifiedList.sort((a, b) {
      if (a.endDate == null) return -1;
      if (b.endDate == null) return 1;
      return b.endDate!.compareTo(a.endDate!);
    });

    _cachedExperiences = unifiedList;
    _lastFetchTime = DateTime.now();

    return unifiedList;
  }

  Future<void> _showAddWorkExperienceModal() async {
    await showDialog(
      context: context,
      builder: (context) => AddedManuallyWorkExperienceForm(
        onSubmit: (manual) async {
          _userBLL.addManualExperience(manual);
          _refreshExperiences();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: SafeArea(
        child: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = snapshot.data!;
            return ListView(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5A69F1), Color(0xFF8A5CF0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(user.getProfilePicture()),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.getEasyName() ?? '',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final updated = await Navigator.pushNamed(
                            context,
                            '/user/edit-profile',
                            arguments: user,
                          );
                          if (updated == true) {
                            setState(() {
                              _userFuture = _userBLL.getCurrentUser();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Edit profile'),
                      ),
                      const SizedBox(height: 12),
                      _infoTile(
                          icon: Icons.phone, text: user.phoneNumber ?? "-"),
                      const SizedBox(height: 8),
                      _infoTile(
                          icon: Icons.link,
                          text: user.linkedin ?? "Add your LinkedIn",),
                      const SizedBox(height: 8),
                      _infoTile(
                          icon: Icons.description,
                          text: user.biography ?? "",
                          expandable: true),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          var documentName = await _userBLL.getMyExportedCv();
                          final Uri documentUrl = Uri.parse(
                            BackenConnection().url +
                                BackenConnection().getMyCvPlace +
                                documentName,
                          );
                          launchUrl(documentUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Download CV'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildExperienceSection(),
                      const SizedBox(height: 24),
                      const MyEducationMobileView(),
                      const SizedBox(height: 24),
                      const MySkills(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String text,
    bool expandable = false,
  }) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    if (!expandable) {
      return Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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

  Widget _buildExperienceSection() {
    return ValueListenableBuilder<int>(
      valueListenable: _refreshTrigger,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Work Experience',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: _showAddWorkExperienceModal,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add experience',
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<UnifiedExperienceViewModel>>(
              future: _fetchAllExperiences(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text("Error: \${snapshot.error}");
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: snapshot.data!
                        .map((e) => WorkExperienceCardMobile(
                            experience: e,
                            onPromotionAdded: _refreshExperiences))
                        .toList(),
                  );
                } else {
                  return const Center(child: Text("No work experiences yet."));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
