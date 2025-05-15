import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyEducation.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/Views/widgets/WorkExperienceCard.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSCleanExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/IPFSPromotions.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/ManualExperience.dart';
import 'package:solid_cv/data_access_layer/BlockChain/IPFSModels/NewWorkExperience.dart/UnifiedExperienceViewModel.dart';

class MyCvRoute extends StatefulWidget {
  const MyCvRoute({super.key});

  @override
  State<MyCvRoute> createState() => _MyCvRouteState();
}

class _MyCvRouteState extends State<MyCvRoute> {
  final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  final IUserBLL _userBLL = UserBll();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _cleanFuture = _blockchainWalletBll.getEventsForCurrentUser();
    final _manualFuture = _userBLL.getMyManuallyAddedExperiences();

    return Scaffold(
      appBar: AppBar(title: const Text('My CV')),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: FutureBuilder(
        future: Future.wait([_cleanFuture, _manualFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cleanList = snapshot.data![0] as List<CleanExperience>;
          final manualList = snapshot.data![1] as List<ManualExperience>;

          final allExperiences = [
            ...cleanList.map(UnifiedExperienceViewModel.fromClean),
            ...manualList.map(UnifiedExperienceViewModel.fromManual),
          ];

          allExperiences
              .sort((a, b) => (b.endDate ?? 0).compareTo(a.endDate ?? 0));

          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Work Experiences',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showAddWorkExperienceModal(context);
                            },
                            child: const Text('+ Add manually'),
                          ),
                        ],
                      ),
                    ),
                    ...allExperiences.map((exp) => WorkExperienceCard(
                        experience: exp,
                        onPromotionAdded: () {
                          setState(() {});
                        })),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: MyEducation(),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const MySkills(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddWorkExperienceModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _title;
    String? _company;
    DateTime? _startDate;
    DateTime? _endDate;
    String? _description;
    String? _location;

    final _promotionList = <Map<String, dynamic>>[];
    final List<TextEditingController> _promotionTitleControllers = [];
    final List<TextEditingController> _promotionDateControllers = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Add Work Experience'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Experience fields
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter title' : null,
                      onSaved: (value) => _title = value,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Company'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter company'
                          : null,
                      onSaved: (value) => _company = value,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Location'),
                      onSaved: (value) => _location = value,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onSaved: (value) => _description = value,
                    ),
                    TextFormField(
                      controller: _startDateController,
                      decoration:
                          const InputDecoration(labelText: 'Start Date'),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            _startDate = picked;
                            _startDateController.text =
                                picked.toIso8601String().split('T')[0];
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(labelText: 'End Date'),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            _endDate = picked;
                            _endDateController.text =
                                picked.toIso8601String().split('T')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Promotions section

                    TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          _promotionList.add({'title': '', 'timestamp': null});
                          _promotionTitleControllers
                              .add(TextEditingController());
                          _promotionDateControllers
                              .add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add promotion'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final manual = ManualExperience(
                      title: _title,
                      company: _company,
                      location: _location,
                      description: _description,
                      startDateAsTimestamp:
                          (_startDate?.millisecondsSinceEpoch ?? 0) ~/ 1000,
                      endDateAsTimestamp: _endDate != null
                          ? _endDate!.millisecondsSinceEpoch ~/ 1000
                          : null,
                      promotions: _promotionList
                          .where((p) =>
                              p['title'] != null &&
                              p['title'].toString().isNotEmpty &&
                              p['timestamp'] != null)
                          .map((p) => Promotion(
                                newTitle: p['title'],
                                date: p['timestamp'],
                              ))
                          .toList(),
                    );

                    _userBLL.addManualExperience(manual);

                    setState(() {
                      _startDateController.clear();
                      _endDateController.clear();
                    });

                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }
}
