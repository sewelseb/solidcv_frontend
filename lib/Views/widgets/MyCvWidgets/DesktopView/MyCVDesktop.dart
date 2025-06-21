import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/AddedManuallyWorkExperienceForm.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/WorkExperienceCard.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/MyEducation.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/config/BackenConnection.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';
import 'package:solid_cv/models/User.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCvDesktop extends StatefulWidget {
  const MyCvDesktop({super.key});

  @override
  State<MyCvDesktop> createState() => _MyCvDesktopState();
}

class _MyCvDesktopState extends State<MyCvDesktop> {
  late final IBlockchainWalletBll _blockchainWalletBll;
  late final IUserBLL _userBLL = UserBll();
  late final ICompanyBll _company = CompanyBll();
  late Future<User> _userFuture;

  final ValueNotifier<int> _refreshTrigger = ValueNotifier(0);
  final ValueNotifier<bool> _isBioExpanded = ValueNotifier(false);

  List<UnifiedExperienceViewModel>? _cachedExperiences;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  static const double desktopBreakpoint = 820;
  static const double tabletBreakpoint = 600;

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
    if (user.ethereumAddress == null) {
      return [];
    }

    if (_cachedExperiences != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedExperiences!;
    }

    final results = await Future.wait([
      _blockchainWalletBll.getEventsForCurrentUser(),
      _userBLL.getMyManuallyAddedExperiences(),
    ]);

    final cleanExperienceList = results[0] as List<CleanExperience>;
    final manualExperienceList = results[1] as List<ManualExperience>;

    final unifiedList = [
      ...cleanExperienceList.map(UnifiedExperienceViewModel.fromClean),
      ...manualExperienceList.map(UnifiedExperienceViewModel.fromManual),
    ];

    for (var experience in unifiedList) {
      if (experience.companyWallet != null) {
        final company =
            await _company.fetchCompanyByWallet(experience.companyWallet!);
        experience.companyLogoUrl = company?.getProfilePicture();
        experience.location =
            '${company?.addressCity}, ${company?.addressCountry}';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet =
        screenWidth < desktopBreakpoint && screenWidth >= tabletBreakpoint;
    final bool isMobile = screenWidth < tabletBreakpoint;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      bottomNavigationBar: const MainBottomNavigationBar(),
      drawer: isMobile ? Drawer(child: _buildSidebar(width: 220)) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) _buildSidebar(width: isTablet ? 200 : 280),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _refreshTrigger,
                      builder: (context, _, __) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildExperienceSection(),
                            const SizedBox(height: 32),
                            const MyEducation(),
                            const SizedBox(height: 32),
                            MySkills(
                              onSkillAdded: () {
                                _refreshTrigger
                                    .value++;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebar({double width = 280}) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5A69F1), Color(0xFF8A5CF0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data!;
        return Container(
          width: width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5A69F1), Color(0xFF8A5CF0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            backgroundImage:
                                NetworkImage(user.getProfilePicture()),
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
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.email ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoTile(
                            icon: Icons.phone,
                            text: user.phoneNumber ?? "Add your phone number"),
                        const SizedBox(height: 6),
                        _infoTile(
                          icon: Icons.link,
                          text: user.linkedin ?? "Add your LinkedIn",
                        ),
                        const SizedBox(height: 6),
                        _infoTile(
                            icon: Icons.description,
                            text: user.biography ?? '',
                            expandable: true),
                        const SizedBox(height: 18),
                        const Divider(color: Colors.white24),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                const Spacer(),
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
              ],
            ),
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
        Row(
          children: [
            const Text('Work Experience',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Text("Error: \${snapshot.error}");
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Column(
                children: snapshot.data!
                    .map((e) => WorkExperienceCard(
                          experience: e,
                          onPromotionAdded: _refreshExperiences,
                        ))
                    .toList(),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text("No work experiences yet.")),
              );
            }
          },
        ),
      ],
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
}
