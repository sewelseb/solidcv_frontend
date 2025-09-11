import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:solid_cv/business_layer/WeeklyRecommendationBll.dart';
import '../models/WeeklyRecommendation.dart';
import '../business_layer/IWeeklyRecommendationBll.dart';
import 'CourseQuestionnairePage.dart';


class CourseViewerPage extends StatefulWidget {
  final RecommendedCourse course;

  const CourseViewerPage({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<CourseViewerPage> createState() => _CourseViewerPageState();
}

class _CourseViewerPageState extends State<CourseViewerPage> {
  late IWeeklyRecommendationBll _weeklyRecommendationBll;
  Future<RecommendedCourse>? _courseFuture;
  late ScrollController _scrollController;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _weeklyRecommendationBll = WeeklyRecommendationBll();
    _courseFuture = _loadCourseContent();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      
      if (maxScrollExtent > 0) {
        setState(() {
          _scrollProgress = (currentScroll / maxScrollExtent).clamp(0.0, 1.0);
        });
      }
    }
  }

  Future<RecommendedCourse> _loadCourseContent() async {
    try {
      // Get AI-generated course content from API
      if (widget.course.id != null) {
        return await _weeklyRecommendationBll.getAiGeneratedCourse(widget.course.id!);
      } else {
        return widget.course;
      }
    } catch (e) {
      // If API fails, return the original course data
      print('Failed to load AI-generated content: $e');
      return widget.course;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          widget.course.title ?? AppLocalizations.of(context)!.course,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<RecommendedCourse>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          } else if (snapshot.hasData) {
            return _buildCourseContent(snapshot.data!);
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loadingCourseContent,
            style: const TextStyle(
              color: Colors.white,
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
              AppLocalizations.of(context)!.failedToLoadCourse,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.pleaseTryAgainLater,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _courseFuture = _loadCourseContent();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noCourseContentAvailable,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCourseContent(RecommendedCourse course) {
    return Column(
      children: [
        // Progress Bar with Percentage
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _scrollProgress,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(_scrollProgress * 100).round()}%',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title ?? AppLocalizations.of(context)!.course,
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (course.provider?.isNotEmpty == true) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.school,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.provider!,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              course.difficulty ?? AppLocalizations.of(context)!.beginner,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${course.duration ?? '1-2'} ${AppLocalizations.of(context)!.hours}',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Course Description (if available)
                if (course.description?.isNotEmpty == true) ...[
                  Text(
                    AppLocalizations.of(context)!.aboutThisCourse,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Text(
                      course.description!,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Course Content Section
                Text(
                  AppLocalizations.of(context)!.courseContent,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Render Markdown Content or Placeholder
                if (course.courseContent?.isNotEmpty == true)
                  _buildMarkdownContent(course)
                else
                  _buildPlaceholderContent(),

                const SizedBox(height: 24),

                // Knowledge Test Button
                if (course.courseContent?.isNotEmpty == true)
                  _buildKnowledgeTestButton(course),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(RecommendedCourse course) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: MarkdownWidget(
        data: course.courseContent!,
        shrinkWrap: true,
        config: MarkdownConfig(
          configs: [
            // Dark theme configuration
            const PreConfig(
              theme: {
                'root': TextStyle(
                  backgroundColor: Color(0xFF2D2D2D),
                  color: Color(0xFFE0E0E0),
                ),
              },
            ),
            const CodeConfig(
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                backgroundColor: Color(0xFF2D2D2D),
                fontSize: 14,
              ),
            ),
            PConfig(
              textStyle: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            H1Config(
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00BCD4),
              ),
            ),
            H2Config(
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4FC3F7),
              ),
            ),
            H3Config(
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const BlockquoteConfig(
              sideColor: Color(0xFF00BCD4),
              textColor: Color(0xFFB0BEC5),
            ),
            const LinkConfig(
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.library_books_outlined,
            color: Color(0xFF666666),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.courseContentBeingGenerated,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.aiPoweredCourseContent,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _courseFuture = _loadCourseContent();
              });
            },
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.refreshContent),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeTestButton(RecommendedCourse course) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Color(0xFF00BCD4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.testYourKnowledge,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.takeQuizToTest,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseQuestionnairePage(
                      courseId: course.id!,
                      courseTitle: course.title ?? AppLocalizations.of(context)!.courseQuiz,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                AppLocalizations.of(context)!.startQuiz,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
