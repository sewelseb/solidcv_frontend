// Create a new file: FirstConfigurationComponents/AISkillValidationStep.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/ISkillBll.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/SkillBll.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Question.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';

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
  
  // Speech-to-text state
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechListening = false;
  String _speechResult = '';
  double _speechConfidence = 0;
  String _selectedLocale = 'en_US';
  bool _isMobileBrowser = false;
  bool _speechInitialized = false;
  String? _speechUnavailableReason;
  
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
    
    // Initialize speech-to-text
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      // Detect mobile browser
      _isMobileBrowser = kIsWeb && (
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS
      );
      
      // For mobile browsers, check if speech is actually available
      if (_isMobileBrowser) {
        // Test if speech recognition is available in mobile browser
        final isAvailable = await _speechToText.initialize(
          onStatus: (status) {
            if (mounted) {
              setState(() {
                _speechListening = status == 'listening';
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _speechListening = false;
                _speechUnavailableReason = error.errorMsg;
              });
            }
            _showSpeechError('Mobile browser: ${error.errorMsg}');
          },
        );
        
        if (!isAvailable) {
          setState(() {
            _speechUnavailableReason = 'Speech recognition not supported in this mobile browser. Please use the desktop version or type your answers.';
          });
          return;
        }
      } else {
        // Desktop or native app - request microphone permission first
        if (!kIsWeb) {
          final status = await Permission.microphone.request();
          if (status != PermissionStatus.granted) {
            setState(() {
              _speechUnavailableReason = 'Microphone permission denied. Please enable microphone access in settings.';
            });
            return;
          }
        }
        
        // Initialize speech-to-text for desktop/native
        _speechEnabled = await _speechToText.initialize(
          onStatus: (status) {
            if (mounted) {
              setState(() {
                _speechListening = status == 'listening';
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _speechListening = false;
                _speechUnavailableReason = error.errorMsg;
              });
            }
            _showSpeechError(error.errorMsg);
          },
        );
      }
      
      _speechInitialized = true;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _speechUnavailableReason = 'Speech recognition initialization failed: ${e.toString()}';
      });
      print('Speech initialization error: $e');
    }
  }
  
  void _startListening() async {
    if (!_speechEnabled && !_isMobileBrowser) return;
    
    try {
      setState(() {
        _speechResult = '';
      });
      
      // Different configurations for mobile vs desktop
      if (_isMobileBrowser) {
        // Mobile browser - more conservative settings
        await _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _speechResult = result.recognizedWords;
                _speechConfidence = result.confidence;
                _messageController.text = _speechResult;
              });
            }
          },
          listenFor: const Duration(seconds: 15), // Shorter for mobile
          pauseFor: const Duration(seconds: 2),   // Shorter pause
          localeId: _selectedLocale,
          listenOptions: SpeechListenOptions(
            partialResults: false,               // Disable for mobile stability
            cancelOnError: true,
            listenMode: ListenMode.confirmation,
          ),
        );
      } else {
        // Desktop/native - full features
        await _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _speechResult = result.recognizedWords;
                _speechConfidence = result.confidence;
                _messageController.text = _speechResult;
              });
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          localeId: _selectedLocale,
          listenOptions: SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
            listenMode: ListenMode.confirmation,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _speechListening = false;
      });
      _showSpeechError('Failed to start listening: ${e.toString()}');
    }
  }
  
  void _stopListening() async {
    await _speechToText.stop();
  }
  
  void _showSpeechError(String error) {
    // Don't show redundant errors if we already have an unavailable reason
    if (_speechUnavailableReason != null) return;
    
    String userFriendlyMessage = error;
    
    // Provide more helpful error messages
    if (error.toLowerCase().contains('not supported')) {
      userFriendlyMessage = _isMobileBrowser 
        ? 'Speech recognition is not fully supported in mobile browsers. Please use a desktop browser or type your answer.'
        : 'Speech recognition is not supported on this device.';
    } else if (error.toLowerCase().contains('permission')) {
      userFriendlyMessage = 'Microphone permission required. Please enable microphone access and try again.';
    } else if (error.toLowerCase().contains('network')) {
      userFriendlyMessage = 'Network error during speech recognition. Please check your connection.';
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFriendlyMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
  
  String _getInputHintText() {
    if (_isMobileBrowser && (_speechEnabled || _speechInitialized)) {
      return 'Type your answer or try the mic button (limited on mobile)...\nPress Ctrl+Enter to submit';
    } else if (_speechEnabled) {
      return 'Type or tap mic to speak...\nPress Ctrl+Enter to submit';
    } else {
      return 'Type your answer...\nPress Ctrl+Enter to submit';
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
                      color: Colors.black.withValues(alpha: 0.08),
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
          // Speech status indicator
          if (_speechListening)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Listening... (${(_speechConfidence * 100).toStringAsFixed(1)}% confidence)',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Speech not available warning
          if (!_speechEnabled || _speechUnavailableReason != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _isMobileBrowser ? Colors.blue.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isMobileBrowser ? Colors.blue.shade200 : Colors.orange.shade200
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isMobileBrowser ? Icons.info : Icons.warning, 
                    color: _isMobileBrowser ? Colors.blue.shade700 : Colors.orange.shade700, 
                    size: 20
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _speechUnavailableReason ?? 
                          (_isMobileBrowser 
                            ? 'Limited speech support on mobile browsers'
                            : 'Speech recognition not available'),
                          style: TextStyle(
                            color: _isMobileBrowser ? Colors.blue.shade700 : Colors.orange.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_isMobileBrowser) ...[
                          const SizedBox(height: 4),
                          Text(
                            'For best speech experience, use a desktop browser or type your answers below.',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Speech button with glow effect
              if (_speechEnabled || (_isMobileBrowser && _speechInitialized && _speechUnavailableReason == null))
                AvatarGlow(
                  animate: _speechListening,
                  glowColor: Colors.red,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _speechListening ? _stopListening : _startListening,
                    backgroundColor: _speechListening ? Colors.red : (_isMobileBrowser ? Colors.green : Colors.blue),
                    child: Icon(
                      _speechListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                    tooltip: _isMobileBrowser 
                      ? 'Tap to speak (Mobile browser - may be limited)'
                      : 'Tap to speak',
                  ),
                ),
              
              if (_speechEnabled || (_isMobileBrowser && _speechInitialized && _speechUnavailableReason == null)) 
                const SizedBox(width: 12),
              
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
                        hintText: _getInputHintText(),
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
          
          // Quick actions for speech
          if (_speechEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _messageController.clear(),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _messageController.text.isNotEmpty ? _submitAnswer : null,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Submit'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF7B3FE4),
                    ),
                  ),
                ],
              ),
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