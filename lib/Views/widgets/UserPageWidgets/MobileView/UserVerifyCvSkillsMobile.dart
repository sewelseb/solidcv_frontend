import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class UserVerifyCvSkillsMobile extends StatefulWidget {
  final String userId;

  const UserVerifyCvSkillsMobile({Key? key, required this.userId}) : super(key: key);

  @override
  _UserVerifyCvSkillsMobileState createState() => _UserVerifyCvSkillsMobileState();
}

class _UserVerifyCvSkillsMobileState extends State<UserVerifyCvSkillsMobile> {
  final IUserBLL _userBLL = UserBll();
  final ISkillBll _skillBll = SkillBll();
  late Future<List<Skill>> _skills;
  bool showFormToGetFeedbackOnProfile = false;
  final TextEditingController jobDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _skills = _userBLL.getSkillsFromUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Skills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: skills.length,
                      itemBuilder: (context, index) {
                        final skill = skills[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF7B3FE4).withOpacity(0.18),
                              width: 1.4,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  skill.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.feedback,
                                    color: Colors.blueAccent),
                                tooltip: 'Get AI Feedback',
                                onPressed: () async {
                                  final feedbacks = await _skillBll
                                      .getFeedbacksOnSkills(skill.id!);
                                  _showFeedbacksDialog(feedbacks);
                                },
                              ),
                            ],
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

        // --- FORMULAIRE JOB DESCRIPTION ---
        Visibility(
          visible: showFormToGetFeedbackOnProfile,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF7B3FE4).withOpacity(0.16),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.deepPurple.shade100,
                          ),
                        ),
                        hintText: 'Enter the job description here...',
                        contentPadding: const EdgeInsets.all(14.0),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      controller: jobDescriptionController,
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final feedback = await _userBLL.getFeedbacksOnProfile(
                            jobDescriptionController.text,
                            widget.userId,
                          );
                          _showFeedbacksDialog(feedback);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: const Text(
                          'Submit',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 480,
            ),
            child: SizedBox(
              width: isMobile ? double.infinity : null,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.description, size: 23),
                label: Text(
                  showFormToGetFeedbackOnProfile
                      ? 'Hide form'
                      : 'Describe your job to see if it is a good fit for you',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B3FE4),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shadowColor: Colors.deepPurple.shade100,
                ),
                onPressed: () {
                  setState(() {
                    showFormToGetFeedbackOnProfile =
                        !showFormToGetFeedbackOnProfile;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFeedbacksDialog(String feedbacks) {
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
