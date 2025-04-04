import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class SkillsWidget extends StatefulWidget {
  final String userId;

  const SkillsWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _SkillsWidgetState createState() => _SkillsWidgetState();
}

class _SkillsWidgetState extends State<SkillsWidget> {
  IUserBLL _userBLL = UserBll();
  ISkillBll _skillBll = SkillBll();
  late Future<List<Skill>> _skills;
  bool showFormToGetFeedbackOnProfile = false;
  final TextEditingController jobDescriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    _skills = _userBLL.getSkillsFromUser(widget.userId);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const Divider(
            color: Colors.blueAccent,
            thickness: 2,
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Skill>>(
            future: _skills,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (snapshot.hasData) {
                final skills = snapshot.data!;
                return skills.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: skills.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            title: Text(
                              skills[index].name!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.feedback,
                                  color: Colors.blueAccent),
                              tooltip: 'Get AI Feedback',
                              onPressed: () async {
                                var feedbacks = await _skillBll
                                    .getFeedbacksOnSkills(skills[index].id!);
                                _showFeedbacksDialog(feedbacks);
                              },
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No skills found',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16),
                        ),
                      );
              } else {
                return const Center(
                  child: Text(
                    'No skills found',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Visibility(
            visible: showFormToGetFeedbackOnProfile,
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter the job description here...',
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                      controller: jobDescriptionController,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                            var feedback = await _userBLL.getFeedbacksOnProfile(
                                jobDescriptionController.text, widget.userId);
                            _showFeedbacksDialog(feedback);
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showFormToGetFeedbackOnProfile =
                    !showFormToGetFeedbackOnProfile;
              });
            },
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
            child: Text(
              showFormToGetFeedbackOnProfile
                  ? 'Hide Form'
                  : 'Describe your job to see if it is a good fit for you',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbacksDialog(feedbacks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedbacks'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(feedbacks),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
