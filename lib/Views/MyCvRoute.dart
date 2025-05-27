import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/AddedManuallyWorkExperienceForm.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyEducation.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/Views/widgets/WorkExperienceCard.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class MyCvRoute extends StatefulWidget {
  const MyCvRoute({super.key});

  @override
  State<MyCvRoute> createState() => _MyCvRouteState();
}

class _MyCvRouteState extends State<MyCvRoute> {
  late final IBlockchainWalletBll _blockchainWalletBll;
  late final IUserBLL _userBLL;

  final ValueNotifier<int> _refreshTrigger = ValueNotifier(0);

  // Cache for experiences to avoid unnecessary network calls
  List<UnifiedExperienceViewModel>? _cachedExperiences;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _blockchainWalletBll = BlockchainWalletBll();
    _userBLL = UserBll();
  }

  @override
  void dispose() {
    _refreshTrigger.dispose();
    super.dispose();
  }

  // Combine both API calls and add caching
  Future<List<UnifiedExperienceViewModel>> _fetchAllExperiences() async {
    // Check cache validity
    if (_cachedExperiences != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedExperiences!;
    }

    try {
      // Use Future.wait for parallel execution instead of nested FutureBuilders
      final results = await Future.wait([
        _blockchainWalletBll.getEventsForCurrentUser(),
        _userBLL.getMyManuallyAddedExperiences(),
      ]);

      final cleanExperiences = results[0] as List<CleanExperience>;
      final manualExperiences = results[1] as List<ManualExperience>;

      final allExperiences = [
        ...cleanExperiences.map(UnifiedExperienceViewModel.fromClean),
        ...manualExperiences.map(UnifiedExperienceViewModel.fromManual),
      ];

      allExperiences.sort((a, b) {
        // If both are ongoing (null endDate), maintain current order
        if (a.endDate == null && b.endDate == null) return 0;

        // Ongoing experiences (null endDate) should come first
        if (a.endDate == null) return -1;
        if (b.endDate == null) return 1;

        // For experiences with end dates, sort by most recent first
        return b.endDate!.compareTo(a.endDate!);
      });

      // Update cache
      _cachedExperiences = allExperiences;
      _lastFetchTime = DateTime.now();

      return allExperiences;
    } catch (e) {
      debugPrint('Error fetching experiences: $e');
      rethrow;
    }
  }

  void _invalidateCache() {
    _cachedExperiences = null;
    _lastFetchTime = null;
  }

  void _refreshExperiences() {
    _invalidateCache();
    _refreshTrigger.value++;
  }

  Future<void> _showAddWorkExperienceModal() async {
    await showDialog(
      context: context,
      builder: (context) => AddedManuallyWorkExperienceForm(
        onSubmit: (manual) async {
          try {
            // Add the experience
            _userBLL.addManualExperience(manual);
            _refreshExperiences();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Work experience added successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding experience: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My CV'),
        elevation: 0,
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshExperiences();
          // Wait a bit for the rebuild to show loading state
          await Future.delayed(const Duration(milliseconds: 100));
        },
        child: ValueListenableBuilder<int>(
          valueListenable: _refreshTrigger,
          builder: (context, _, __) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildExperienceSection()),
                SliverToBoxAdapter(child: _buildSection(child: MyEducation())),
                SliverToBoxAdapter(
                    child: _buildSection(child: const MySkills())),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExperienceHeader(),
          const SizedBox(height: 16),
          FutureBuilder<List<UnifiedExperienceViewModel>>(
            future: _fetchAllExperiences(),
            builder: (context, snapshot) {
              return switch (snapshot.connectionState) {
                ConnectionState.waiting => const _LoadingIndicator(),
                ConnectionState.done => switch (snapshot.hasError) {
                    true => _ErrorWidget(
                        error: snapshot.error.toString(),
                        onRetry: _refreshExperiences,
                      ),
                    false => _ExperiencesList(
                        experiences: snapshot.data ?? [],
                        onPromotionAdded: _refreshExperiences,
                      ),
                  },
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const title = Text(
            'Work Experiences',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          );

          final addButton = ElevatedButton.icon(
            onPressed: _showAddWorkExperienceModal,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add manually'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );

          // Use MediaQuery for more reliable responsive design
          final isNarrow = MediaQuery.of(context).size.width < 600;

          return isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 12),
                    addButton,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [title, addButton],
                );
        },
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Extract widgets for better maintainability
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading experiences...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading experiences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperiencesList extends StatelessWidget {
  final List<UnifiedExperienceViewModel> experiences;
  final VoidCallback onPromotionAdded;

  const _ExperiencesList({
    required this.experiences,
    required this.onPromotionAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (experiences.isEmpty) {
      return const _EmptyExperiencesWidget();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: experiences.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return WorkExperienceCard(
          experience: experiences[index],
          onPromotionAdded: onPromotionAdded,
        );
      },
    );
  }
}

class _EmptyExperiencesWidget extends StatelessWidget {
  const _EmptyExperiencesWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No work experiences yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first work experience to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
