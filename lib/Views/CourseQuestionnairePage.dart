import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/IWeeklyRecommendationBll.dart';
import 'package:solid_cv/business_layer/WeeklyRecommendationBll.dart';
import 'package:solid_cv/models/CourseQuestion.dart';
import 'package:solid_cv/models/QuizSubmission.dart';

class CourseQuestionnairePage extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const CourseQuestionnairePage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<CourseQuestionnairePage> createState() => _CourseQuestionnairePageState();
}

class _CourseQuestionnairePageState extends State<CourseQuestionnairePage> {
  late IWeeklyRecommendationBll _weeklyRecommendationBll;
  Future<List<CourseQuestion>>? _questionsFuture;
  Map<int, int> _selectedAnswers = {}; // questionId -> optionId
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _weeklyRecommendationBll = WeeklyRecommendationBll();
    _questionsFuture = _loadQuestions();
  }

  Future<List<CourseQuestion>> _loadQuestions() async {
    try {
      return await _weeklyRecommendationBll.getCourseQuestions(widget.courseId);
    } catch (e) {
      print('Failed to load course questions: $e');
      throw e;
    }
  }

  void _selectAnswer(int questionId, int optionId) {
    setState(() {
      _selectedAnswers[questionId] = optionId;
    });
  }

  Future<void> _submitQuiz() async {
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Submit answers to API (backend handles course completion automatically)
      QuizResult result = await _weeklyRecommendationBll.submitCourseQuiz(
        widget.courseId,
        _selectedAnswers,
      );
      
      setState(() {
        _isSubmitted = true;
        _isSubmitting = false;
      });
      
      // Show result dialog
      _showQuizResultDialog(result);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit quiz: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQuizResultDialog(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                result.passed == true ? Icons.check_circle : Icons.cancel,
                color: result.passed == true ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.passed == true ? 'Quiz Passed!' : 'Quiz Failed',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.score != null && result.totalQuestions != null) ...[
                Text(
                  'Score: ${result.score}/${result.totalQuestions}',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00BCD4),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (result.message != null) ...[
                Text(
                  result.message!,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
          actions: [
            if (result.passed == true) ...[
              // Quiz passed - offer to go back to weekly recommendations
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate back to weekly recommendations and refresh the page
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/weekly-recommendations',
                    (route) => false, // Remove all previous routes
                  );
                },
                child: Text(
                  'Back to Recommendations',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF00BCD4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              // Quiz failed - offer retry or go back to course
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close questionnaire page
                },
                child: Text(
                  'Back to Course',
                  style: GoogleFonts.nunito(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Reset quiz state for retry
                  setState(() {
                    _selectedAnswers.clear();
                    _isSubmitted = false;
                    _isSubmitting = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Knowledge Test',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<CourseQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          
          return _buildQuestionsContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF00BCD4),
          ),
          SizedBox(height: 16),
          Text(
            'Loading questions...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load questions',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _questionsFuture = _loadQuestions();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz_outlined,
              color: Color(0xFF666666),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No questions available',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This course doesn\'t have any questions yet',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsContent(List<CourseQuestion> questions) {
    final answeredQuestions = _selectedAnswers.length;
    final totalQuestions = questions.length;
    final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Column(
      children: [
        // Header with course info and progress
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            border: Border(
              bottom: BorderSide(color: Color(0xFF333333)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.courseTitle,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Progress: $answeredQuestions of $totalQuestions questions answered',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF333333),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
              ),
            ],
          ),
        ),

        // Questions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(question, index + 1);
            },
          ),
        ),

        // Submit button
        if (!_isSubmitted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(
                top: BorderSide(color: Color(0xFF333333)),
              ),
            ),
            child: ElevatedButton(
              onPressed: (_selectedAnswers.length == questions.length && !_isSubmitting) ? _submitQuiz : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                disabledBackgroundColor: const Color(0xFF555555),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Submitting...',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Submit Quiz',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionCard(CourseQuestion question, int questionNumber) {
    final isAnswered = _selectedAnswers.containsKey(question.id);
    final selectedOptionId = _selectedAnswers[question.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnswered ? const Color(0xFF00BCD4) : const Color(0xFF333333),
          width: isAnswered ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isAnswered ? const Color(0xFF00BCD4) : const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    questionNumber.toString(),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question.questionText ?? 'Question not available',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Options
          if (question.options != null)
            ...question.options!.map((option) {
              final isSelected = selectedOptionId == option.id;
              return GestureDetector(
                onTap: _isSubmitted ? null : () => _selectAnswer(question.id!, option.id!),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.1) : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00BCD4) : const Color(0xFF444444),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? const Color(0xFF00BCD4) : const Color(0xFF666666),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.optionText ?? 'Option not available',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
