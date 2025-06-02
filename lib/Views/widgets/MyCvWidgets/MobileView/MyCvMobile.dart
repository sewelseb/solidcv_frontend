import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/AddedManuallyWorkExperienceForm.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/MyEducationMobileView.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/MobileView/WorkExperienceMobileCard.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class MyCvMobile extends StatefulWidget {
  const MyCvMobile({super.key});

  @override
  State<MyCvMobile> createState() => _MyCvMobileState();
}

class _MyCvMobileState extends State<MyCvMobile> {
  late final IBlockchainWalletBll _blockchainWalletBll;
  late final IUserBLL _userBLL= UserBll();

  final ValueNotifier<int> _refreshTrigger = ValueNotifier(0);
  List<UnifiedExperienceViewModel>? _cachedExperiences;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _blockchainWalletBll = BlockchainWalletBll();
  
  }

  void _refreshExperiences() {
    _cachedExperiences = null;
    _lastFetchTime = null;
    _refreshTrigger.value++;
  }

  Future<List<UnifiedExperienceViewModel>> _fetchAllExperiences() async {
    if (_cachedExperiences != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedExperiences!;
    }

    final results = await Future.wait([
      _blockchainWalletBll.getEventsForCurrentUser(),
      _userBLL.getMyManuallyAddedExperiences(),
    ]);

    final clean = results[0] as List<CleanExperience>;
    final manual = results[1] as List<ManualExperience>;

    final all = [
      ...clean.map(UnifiedExperienceViewModel.fromClean),
      ...manual.map(UnifiedExperienceViewModel.fromManual),
    ];

    all.sort((a, b) {
      if (a.endDate == null) return -1;
      if (b.endDate == null) return 1;
      return b.endDate!.compareTo(a.endDate!);
    });

    _cachedExperiences = all;
    _lastFetchTime = DateTime.now();

    return all;
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            _buildExperienceSection(),
            const SizedBox(height: 24),
            const MyEducationMobileView(),
            const SizedBox(height: 24),
            const MySkills(),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
    );
  }

  Widget _buildProfileHeader() {
    return const Column(
      children: [
        CircleAvatar(radius: 40),
        SizedBox(height: 12),
        Text('Alex Thompson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return const LinearProgressIndicator(
      value: 1,
      backgroundColor: Color(0xFFE0E0E0),
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A69F1)),
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
                const Text('Work Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  return Text("Error: \${snapshot.error}");
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: snapshot.data!
                        .map((e) => WorkExperienceCardMobile(
                            experience: e, onPromotionAdded: _refreshExperiences))
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
