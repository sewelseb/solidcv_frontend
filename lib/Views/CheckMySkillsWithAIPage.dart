import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/Views/widgets/UserPageWidgets/DesktopView/DesignWidget/FeedbackDialog.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Question.dart';
import 'package:solid_cv/models/Skill.dart';

// Custom TextInputFormatter to prevent paste operations
class _NoPasteFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new text length is significantly larger than old + 1,
    // it's likely a paste operation
    if (newValue.text.length > oldValue.text.length + 1) {
      return oldValue; // Reject the paste
    }
    return newValue;
  }
}

class CheckMySkillsWithAIPage extends StatefulWidget {
  final String id;

  const CheckMySkillsWithAIPage({super.key, required this.id});

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
  final FocusNode _userMessageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _skillFuture = _userBLL.getSkill(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.checkMySkillsWithAI),
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      body: FutureBuilder<Skill>(
        future: _skillFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildSkillCheckUI(snapshot.data!);
          } else {
            return Center(child: Text(AppLocalizations.of(context)!.noDataFound));
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
                    AppLocalizations.of(context)!.answerQuestionsToCheckSkills(skill.name!),
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
                  child: Text(AppLocalizations.of(context)!.getFeedbacksOnMySkills),
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
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.android, color: Colors.white),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.aiWillAskQuestionsToTest,
                          style: const TextStyle(fontSize: 16),
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
                            label: Text(AppLocalizations.of(context)!.startTest,
                                style: const TextStyle(
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
          if (hasTestStarted) ...[
            const Divider(height: 1),
            
            // Information message about no pasting
            if (_currentQuestion != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.noPasteAllowed,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV): const DoNothingIntent(),
                        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV): const DoNothingIntent(),
                      },
                      child: TextField(
                        controller: userMessageController,
                        focusNode: _userMessageFocusNode,
                        onSubmitted: (_) => _handleSend(skill),
                        inputFormatters: [
                          _NoPasteFormatter(), // Prevent paste operations
                        ],
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.typeYourMessage,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Disable context menu (copy/paste menu)
                        contextMenuBuilder: (context, editableTextState) {
                          return const SizedBox.shrink(); // Return empty widget to hide context menu
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleSend(skill),
                    child: Text(AppLocalizations.of(context)!.send),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSend(Skill skill) async {
    if (_currentQuestion == null || userMessageController.text.isEmpty) return;

    final userResponse = userMessageController.text;

    setState(() {
      messages.add(_Message(text: userResponse, sender: 'User'));
      userMessageController.clear();
      isQuestionLoading = true;
    });

    _currentQuestion!.answer = userResponse;
    await _skillBll.sendAnswerToAI(_currentQuestion!);

    final newQuestion = await _skillBll.getAQuestionsForSkill(skill.id!);

    setState(() {
      _currentQuestion = newQuestion;
      messages.add(_Message(text: newQuestion.question, sender: 'AI'));
      isQuestionLoading = false;
      hasTestStarted = true;
    });
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
      builder: (_) => FeedbackDialog(feedbacks: feedbacks),
    );
  }
}

class _Message {
  String? text;
  String? sender;

  _Message({this.text, this.sender = 'AI'});
}
