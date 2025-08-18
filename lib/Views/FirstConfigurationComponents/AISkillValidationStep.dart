// Create a new file: FirstConfigurationComponents/AISkillValidationStep.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Question.dart';

class AISkillValidationStep extends StatefulWidget {
  final List<Map<String, dynamic>> skills;
  final Function(List<Map<String, dynamic>>) onComplete;
  final bool isActive;

  const AISkillValidationStep({
    super.key,
    required this.skills,
    required this.onComplete,
    required this.isActive,
  });

  @override
  State<AISkillValidationStep> createState() => _AISkillValidationStepState();
}

class _AISkillValidationStepState extends State<AISkillValidationStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final ISkillBll _skillBll = SkillBll();
  final IUserBLL _userBll = UserBll();
  int _currentSkillIndex = 0;
  List<Map<String, dynamic>> _skillsWithValidation = [];
  
  // Chat state
  List<_ChatMessage> _messages = [];
  Question? _currentQuestion;
  bool _isLoadingQuestion = false;
  bool _hasTestStarted = false;
  int _questionsAnswered = 0;
  final int _maxQuestions = 3; // Limit questions per skill
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _skillsWithValidation = List.from(widget.skills);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.isActive) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B3FE4), Color(0xFFB57AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Message bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildValidationContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationContent() {
    if (_currentSkillIndex >= widget.skills.length) {
      return _buildCompletionSummary();
    }

    final currentSkill = widget.skills[_currentSkillIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.quiz,
                color: Colors.blue.shade600,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Skill Test',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentSkillIndex + 1}/${widget.skills.length}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Explanation about why we perform these tests
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Why do we test your skills?',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We use this data to provide you with personalized feedback about your skills, help recruiters understand how well applicants match their job offers, and eventually provide you with tailored career advice to advance your professional growth. You can always do it or continue to answer questions on your CV page',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Current skill info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Testing: ${currentSkill['name']}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Answer questions to validate your skill level',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Chat messages
        if (_messages.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Chat header showing conversation history
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Conversation History',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Text(
                        '${_messages.length} messages',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: _messages.map((message) => _buildChatMessage(message)).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Loading indicator
        if (_isLoadingQuestion) ...[
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI is preparing a question...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Input field (when test is active)
        if (_hasTestStarted && !_isLoadingQuestion && _questionsAnswered < _maxQuestions) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CallbackShortcuts(
                  bindings: <ShortcutActivator, VoidCallback>{
                    const SingleActivator(LogicalKeyboardKey.enter, control: true): _submitAnswer,
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Type your answer...\nPress Ctrl+Enter to submit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) {
                        // Only submit on Ctrl+Enter, not just Enter
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    onPressed: _submitAnswer,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3FE4),
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Submit answer (Ctrl+Enter)',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ctrl+\nEnter',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        // Action buttons
        Row(
          children: [
            if (!_hasTestStarted) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3FE4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Start AI Test'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            if (_hasTestStarted && _questionsAnswered >= _maxQuestions) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _completeCurrentSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Complete Test'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            // Skip button
            OutlinedButton.icon(
              onPressed: _skipCurrentSkill,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.skip_next, size: 16),
              label: const Text('Skip'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatMessage(_ChatMessage message) {
    final isAI = message.sender == 'AI';
    final isSystem = message.sender == 'System';
    
    // System messages (skill separators) get special styling
    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isAI ? Colors.blue.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isAI ? Icons.smart_toy : Icons.person,
              color: isAI ? Colors.blue.shade600 : Colors.green.shade600,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAI ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAI ? Colors.blue.shade200 : Colors.green.shade200,
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isAI ? Colors.blue.shade700 : Colors.green.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSummary() {
    final validatedCount = _skillsWithValidation.where((s) => s['isValidated'] == true).length;
    final skippedCount = _skillsWithValidation.where((s) => s['isValidated'] == false).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Validation Complete! 🎉',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Validation Summary',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$validatedCount',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'Validated',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$skippedCount',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Skipped',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _completeValidation, // Changed this line
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B3FE4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Complete Setup'),
          ),
        ),
      ],
    );
  }

  void _startTest() async {
    setState(() {
      _isLoadingQuestion = true;
      _hasTestStarted = true;
    });
    
    try {
      final skillId = widget.skills[_currentSkillIndex]['id'];
      final question = await _skillBll.getAQuestionsForSkill(skillId);
      
      setState(() {
        _currentQuestion = question;
        _messages.add(_ChatMessage(
          text: question.question ?? 'No question available',
          sender: 'AI',
        ));
        _isLoadingQuestion = false;
      });
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingQuestion = false;
        _messages.add(_ChatMessage(
          text: 'Sorry, I couldn\'t generate a question for this skill. Let\'s move to the next one.',
          sender: 'AI',
        ));
      });
    }
  }

  void _submitAnswer() async {
    if (_messageController.text.isEmpty || _currentQuestion == null) return;
    
    final userAnswer = _messageController.text;
    
    setState(() {
      _messages.add(_ChatMessage(text: userAnswer, sender: 'User'));
      _messageController.clear();
      _isLoadingQuestion = true;
      _questionsAnswered++;
    });
    
    // Auto-scroll to bottom after user message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    try {
      _currentQuestion!.answer = userAnswer;
      await _skillBll.sendAnswerToAI(_currentQuestion!);
      
      if (_questionsAnswered < _maxQuestions) {
        final skillId = widget.skills[_currentSkillIndex]['id'];
        final nextQuestion = await _skillBll.getAQuestionsForSkill(skillId);
        
        setState(() {
          _currentQuestion = nextQuestion;
          _messages.add(_ChatMessage(
            text: nextQuestion.question ?? 'No question available',
            sender: 'AI',
          ));
          _isLoadingQuestion = false;
        });
        
        // Auto-scroll to bottom after AI response
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          _isLoadingQuestion = false;
          _messages.add(_ChatMessage(
            text: 'Great! You\'ve completed the test for this skill. You can continue to the next skill or review your answers.',
            sender: 'AI',
          ));
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingQuestion = false;
        _messages.add(_ChatMessage(
          text: 'There was an issue processing your answer. Let\'s continue.',
          sender: 'AI',
        ));
      });
    }
  }

  void _completeCurrentSkill() {
    setState(() {
      _skillsWithValidation[_currentSkillIndex]['isValidated'] = true;
      _skillsWithValidation[_currentSkillIndex]['validationScore'] = _questionsAnswered; // Simple scoring
      _moveToNextSkill();
    });
  }

  void _skipCurrentSkill() {
    setState(() {
      _skillsWithValidation[_currentSkillIndex]['isValidated'] = false;
      _skillsWithValidation[_currentSkillIndex]['validationScore'] = 0;
      _moveToNextSkill();
    });
  }

  void _moveToNextSkill() {
    setState(() {
      _currentSkillIndex++;
      // Add a separator message to distinguish between skills
      if (_messages.isNotEmpty) {
        _messages.add(_ChatMessage(
          text: '--- Moving to next skill: ${_currentSkillIndex < widget.skills.length ? widget.skills[_currentSkillIndex]['name'] : 'Completed'} ---',
          sender: 'System',
        ));
      }
      _currentQuestion = null;
      _hasTestStarted = false;
      _questionsAnswered = 0;
      _isLoadingQuestion = false;
    });
    
    // Auto-scroll to bottom after separator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _completeValidation() {
    // Call the onComplete callback to trigger the next step
    widget.onComplete(_skillsWithValidation);
    _userBll.setFirstConfigurationDone();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String text;
  final String sender;

  _ChatMessage({required this.text, required this.sender});
}