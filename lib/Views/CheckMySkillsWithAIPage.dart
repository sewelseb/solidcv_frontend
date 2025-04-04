import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class CheckMySkillsWithAIPage extends StatefulWidget {
  final String id;

  const CheckMySkillsWithAIPage({required this.id});

  @override
  _CheckMySkillsWithAIPageState createState() =>
      _CheckMySkillsWithAIPageState();
}

class _CheckMySkillsWithAIPageState extends State<CheckMySkillsWithAIPage> {
  IUserBLL _userBLL = UserBll();
  ISkillBll _skillBll = SkillBll();
  late Future<Skill> _skill;
  List<_Message> messages = [];
  bool hasTestStarted = false;
  bool isQuestionLoading = false;

  @override
  Widget build(BuildContext context) {
    var skillId = widget.id;
    _skill = _userBLL.getSkill(skillId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check My Skills with AI'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: FutureBuilder(
        future: _skill,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final skill = snapshot.data!;
            return _buildSkillCheckUI(skill);
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildSkillCheckUI(Skill skill) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Text(
                  'Answer the questions to check your skills in ' + skill.name!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.android, color: Colors.white),
                      ),
                      title: Text(
                        'AI: I will ask you some questions to test your skill',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    ...messages.map((message) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: message.sender == 'AI'
                              ? Colors.blueAccent
                              : Colors.green,
                          child: Icon(
                            message.sender == 'AI'
                                ? Icons.android
                                : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          message.text!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    if (isQuestionLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(height: 20),
                    if (!hasTestStarted)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add start test logic here
                            setState(() {
                              isQuestionLoading = true;
                            });
                            _skillBll
                                .getAQuestionsForSkill(skill.id!)
                                .then((question) {
                              var message = _Message(
                                text: question.question,
                                sender: 'AI',
                              );

                              setState(() {
                                messages.add(message);
                                hasTestStarted = true;
                                isQuestionLoading = false;
                              });
                            });
                          },
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text(
                            'Start Test',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Add send message logic here
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Message {
  String? text;
  String? sender;

  _Message({this.text, this.sender = 'AI'});
}
