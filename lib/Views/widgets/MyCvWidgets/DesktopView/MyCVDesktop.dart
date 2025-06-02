import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/AddedManuallyWorkExperienceForm.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/WorkExperienceCard.dart';
import 'package:solid_cv/Views/widgets/MyEducation.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class MyCvDesktop extends StatefulWidget {
  const MyCvDesktop({super.key});

  @override
  State<MyCvDesktop> createState() => _MyCvDesktopState();
}

class _MyCvDesktopState extends State<MyCvDesktop> {
  late final IBlockchainWalletBll _blockchainWalletBll;
  late final IUserBLL _userBLL = UserBll();

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
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(),
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
                            MyEducation(),
                            const SizedBox(height: 32),
                            const MySkills(),
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
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Column(
                children: snapshot.data!
                    .map((e) => WorkExperienceCard(
                        experience: e, onPromotionAdded: _refreshExperiences))
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Alex Thompson',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Edit profile'),
            )
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
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A69F1), Color(0xFF8A5CF0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: CircleAvatar(radius: 60)),
          SizedBox(height: 16),
          Center( child :Text("Informations",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))),
          SizedBox(height: 4),
          Center( child :Text("alex.thompson@example.com",
              style: TextStyle(color: Colors.white70, fontSize: 13))),
          SizedBox(height: 4),
         Center( child : Text("+1 234 567 890",
              style: TextStyle(color: Colors.white70, fontSize: 13))),
          SizedBox(height: 4),
        Center( child :  Text("San Francisco, CA",
              style: TextStyle(color: Colors.white70, fontSize: 13))),
          SizedBox(height: 24),
          Divider(height: 32, color: Colors.white24),
        ],
      ),
    );
  }
}
