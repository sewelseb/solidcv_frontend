import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/MyEducation.dart';
import 'package:solid_cv/Views/widgets/MySkills.dart';
import 'package:solid_cv/business_layer/BlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IBlockchainWalletBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';

class MyCvRoute extends StatefulWidget {
  const MyCvRoute({super.key});

  @override
  State<MyCvRoute> createState() => _MyCvRouteState();
}

class _MyCvRouteState extends State<MyCvRoute> {
  IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
  IUserBLL _userBLL = UserBll();
  late Future<List<ExperienceRecord>> _workExperiences;
  late Future<List<ExperienceRecord>> _manuallyAddedWorkExperiences;

  @override
  Widget build(BuildContext context) {
    _workExperiences = _blockchainWalletBll.getWorkExperiencesForCurrentUser();
    _manuallyAddedWorkExperiences = _userBLL.getMyManuallyAddedWorkExperiences();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My CV'),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: ListView(
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
            child: FutureBuilder<List<ExperienceRecord>>(
              future: _workExperiences,
              builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No work experiences found.'));
              } else {
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                    const Text(
                      'Work Experiences',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                      _showAddWorkExperienceModal(context);
                      },
                      child: const Text('+ Add manually a new work experience'),
                    ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                  'Validated by the blockchain',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  ),
                  ...snapshot.data!.map((experience) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      experience.title!,
                      style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const SizedBox(height: 8),
                      Text(
                        experience.company!,
                        style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${experience.startDate} - ${experience.endDate}',
                        style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        ),
                      ),
                      ],
                    ),
                    ),
                  );
                  }).toList(),
                  const SizedBox(height: 8),
                  const Text(
                  'Manually added',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  ),
                  FutureBuilder(
                  future: _manuallyAddedWorkExperiences,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No manually added work experiences found.'));
                    } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      ...snapshot.data!.map((experience) {
                        return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                          experience.title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          ),
                          subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                            experience.company ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                            '${experience.startDate} - ${experience.endDate}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            ),
                          ],
                          ),
                        ),
                        );
                      }).toList(),
                      ],
                    );
                    }
                  },
                  ),
                ],
                );
              }
              },
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
            child: MySkills(),
          ),
        ],
      ),
    );
  }

  void _showAddWorkExperienceModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _title;
    String? _company;
    DateTime? _startDate;
    DateTime? _endDate;
    String? _descirption;
    String? _location;

    showDialog(
      context: context,
      builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Work Experience'),
        content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
              return 'Please enter a title';
              }
              return null;
            },
            onSaved: (value) {
              _title = value;
            },
            ),
            TextFormField(
            decoration: const InputDecoration(labelText: 'Company'),
            validator: (value) {
              if (value == null || value.isEmpty) {
              return 'Please enter a company';
              }
              return null;
            },
            onSaved: (value) {
              _company = value;
            },
            ),
            TextFormField(
            decoration: const InputDecoration(labelText: 'Location'),
            onSaved: (value) {
              _location = value;
            },
            ),
            TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              ),
            maxLines: 3,
            onSaved: (value) {
              _descirption = value;
            },
            ),
            TextFormField(
            decoration: const InputDecoration(labelText: 'Start Date'),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              _startDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              );
            },
            ),
            TextFormField(
            decoration: const InputDecoration(labelText: 'End Date'),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              _endDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              );
            },
            ),
          ],
          ),
        ),
        ),
        actions: [
        TextButton(
          onPressed: () {
          Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Save the new work experience
            ExperienceRecord newExperience = ExperienceRecord(
            title: _title,
            company: _company,
            startDate: _startDate.toString(),
            endDate: _endDate.toString(),
            description: _descirption,
            location: _location,
            );
            newExperience.setTimeStampsFromSelector();
            setState(() {
            //_workExperiences = _blockchainWalletBll.addWorkExperience(newExperience);
              _userBLL.addManuallyAddedWorkExperience(newExperience);
            });
            Navigator.of(context).pop();
          }
          },
          child: const Text('Save'),
        ),
        ],
      );
      },
    );
  }
}
