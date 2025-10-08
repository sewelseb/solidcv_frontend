import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:solid_cv/Views/utils/PremiumHelper.dart';

class MyCvMobile extends StatefulWidget {
  const MyCvMobile({super.key});

  @override
  State<MyCvMobile> createState() => _MyCvMobileState();
}

class _MyCvMobileState extends State<MyCvMobile>
    with SingleTickerProviderStateMixin {
  late final IBlockchainWalletBll _blockchainWalletBll;
  late final IUserBLL _userBLL = UserBll();
  late Future<User> _userFuture;
  final ValueNotifier<bool> _isBioExpanded = ValueNotifier(false);
  final ValueNotifier<bool> _isDownloadingCv = ValueNotifier(false);
  late final ICompanyBll _company = CompanyBll();

  late final TabController _tabController;

  final ValueNotifier<int> _refreshTrigger = ValueNotifier(0);
  List<UnifiedExperienceViewModel>? _cachedExperiences;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _blockchainWalletBll = BlockchainWalletBll();
    _userFuture = _userBLL.getCurrentUser();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _refreshExperiences() {
    _cachedExperiences = null;
    _lastFetchTime = null;
    _refreshTrigger.value++;
  }

  @override
  void dispose() {
    _refreshTrigger.dispose();
    _isBioExpanded.dispose();
    _isDownloadingCv.dispose();
    _tabController.dispose();
    super.dispose();
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
    } else {
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
        final company =
            await _company.fetchCompanyByWallet(experience.companyWallet!);
        experience.companyLogoUrl = company?.getProfilePicture();
        experience.location =
            '${company?.addressCity}, ${company?.addressCountry}';
        experience.isCompanyVerified = company?.isVerified ?? false;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.getEasyName() ?? '',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          _premiumBadgeInline(user),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: _subscribeChip(onPressed: () {
                          Navigator.pushNamed(context, '/subscription');
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/user/first-configuration');
                            },
                            child: Tooltip(
                              message: AppLocalizations.of(context)!.setup,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Icon(Icons.settings_outlined,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () async {
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
                            child: Tooltip(
                              message: AppLocalizations.of(context)!.edit,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.edit_outlined,
                                    color: Colors.black87, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoTile(
                          icon: Icons.phone, text: user.phoneNumber ?? "-"),
                      const SizedBox(height: 8),
                      _infoTile(
                        icon: Icons.link,
                        text: user.linkedin ??
                            AppLocalizations.of(context)!.addYourLinkedin,
                      ),
                      const SizedBox(height: 8),
                      _infoTile(
                          icon: Icons.description,
                          text: user.biography ?? "",
                          expandable: true),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isDownloadingCv,
                          builder: (context, isLoading, child) {
                            return ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      try {
                                        _isDownloadingCv.value = true;
                                        var documentName =
                                            await _userBLL.getMyExportedCv();
                                        final Uri documentUrl = Uri.parse(
                                          BackenConnection().url +
                                              BackenConnection().getMyCvPlace +
                                              documentName,
                                        );
                                        await launchUrl(documentUrl);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${AppLocalizations.of(context)!.errorDownloadingCv}: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        _isDownloadingCv.value = false;
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
                              icon: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFF7B3FE4)),
                                      ),
                                    )
                                  : const Icon(Icons.download_outlined,
                                      size: 18),
                              label: Text(isLoading
                                  ? AppLocalizations.of(context)!.generating
                                  : AppLocalizations.of(context)!
                                      .exportMyCvPdf),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.only(left: 0, right: 16),
                      indicatorPadding: EdgeInsets.zero,
                      tabAlignment: TabAlignment.start,
                      labelColor: const Color(0xFF111111),
                      unselectedLabelColor: const Color(0xFF666666),
                      indicatorColor: const Color(0xFF7B3FE4),
                      tabs: [
                        Tab(
                            text: AppLocalizations.of(context)!
                                .workExperienceMobile),
                        Tab(text: AppLocalizations.of(context)!.education),
                        Tab(text: AppLocalizations.of(context)!.skills),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      if (_tabController.index == 0) ...[
                        _buildExperienceSection(),
                      ] else if (_tabController.index == 1) ...[
                        const MyEducationMobileView(),
                      ] else ...[
                        const MySkills(),
                      ],
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

  bool _isPremiumActive(User user) {
    return PremiumHelper.isPremiumActive(user.premiumSubscriptionDate);
  }

  Widget _premiumBadgeInline(User user) {
    if (!_isPremiumActive(user)) return const SizedBox.shrink();
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2ECC71),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
    );
  }

  Widget _subscribeChip({required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        backgroundColor: Colors.white.withOpacity(0.15),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.workspace_premium, size: 16),
      label: Text(AppLocalizations.of(context)!.premiumLabel),
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
                Text(AppLocalizations.of(context)!.workExperienceMobile,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: _showAddWorkExperienceModal,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: AppLocalizations.of(context)!.addExperience,
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
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: snapshot.data!
                        .map((e) => WorkExperienceCardMobile(
                            experience: e,
                            onPromotionAdded: _refreshExperiences))
                        .toList(),
                  );
                } else {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context)!.noWorkExperiencesYet));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
