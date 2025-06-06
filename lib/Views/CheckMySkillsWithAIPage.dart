import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Question.dart';
import 'package:solid_cv/models/Skill.dart';

class CheckMySkillsWithAIPage extends StatefulWidget {
  final String id;

  const CheckMySkillsWithAIPage({required this.id});

  @override
  _CheckMySkillsWithAIPageState createState() =>
      _CheckMySkillsWithAIPageState();
}

class _CheckMySkillsWithAIPageState extends State<CheckMySkillsWithAIPage> {
  final IUserBLL _userBLL = UserBll();
  final ISkillBll _skillBll = SkillBll();
  late Future<Skill> _skillFuture;
  List<_Message> messages = [];
  bool hasTestStarted = false;
  bool isQuestionLoading = false;
  Question? _currentQuestion;
  final TextEditingController userMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _skillFuture = _userBLL.getSkill(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check My Skills with AI'),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      body: FutureBuilder<Skill>(
        future: _skillFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildSkillCheckUI(snapshot.data!);
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildSkillCheckUI(Skill skill) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: Text(
                    'Answer the questions to check your skills in ${skill.name!}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    var feedbacks =
                        await _skillBll.getFeedbacksOnSkills(skill.id!);
                    _showFeedbacksDialog(feedbacks);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Feedbacks On My Skills'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
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
                      ...messages.map((message) => ListTile(
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
                            title: Text(message.text ?? '',
                                style: const TextStyle(fontSize: 16)),
                          )),
                      if (isQuestionLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 10),
                      if (!hasTestStarted)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _getNewAiQuestion(skill),
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.white),
                            label: const Text('Start Test',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: userMessageController,
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
                  onPressed: () async {
                    if (_currentQuestion == null ||
                        userMessageController.text.isEmpty) return;

                    final userResponse = userMessageController.text;

                    setState(() {
                      messages
                          .add(_Message(text: userResponse, sender: 'User'));
                      userMessageController.clear();
                      isQuestionLoading = true;
                    });

                    _currentQuestion!.answer = userResponse;
                    await _skillBll.sendAnswerToAI(_currentQuestion!);

                    final newQuestion =
                        await _skillBll.getAQuestionsForSkill(skill.id!);

                    setState(() {
                      _currentQuestion = newQuestion;
                      messages.add(
                          _Message(text: newQuestion.question, sender: 'AI'));
                      isQuestionLoading = false;
                      hasTestStarted = true;
                    });
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getNewAiQuestion(Skill skill) async {
    setState(() {
      isQuestionLoading = true;
    });
    final question = await _skillBll.getAQuestionsForSkill(skill.id!);
    setState(() {
      _currentQuestion = question;
      messages.add(_Message(text: question.question, sender: 'AI'));
      isQuestionLoading = false;
      hasTestStarted = true;
    });
  }

  void _showFeedbacksDialog(String feedbacks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedbacks'),
          content: SingleChildScrollView(
            child: ListBody(children: [Text(feedbacks)]),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class _Message {
  String? text;
  String? sender;

  _Message({this.text, this.sender = 'AI'});
}
