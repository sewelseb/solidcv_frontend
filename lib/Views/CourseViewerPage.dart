import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:solid_cv/business_layer/WeeklyRecommendationBll.dart';
import '../models/WeeklyRecommendation.dart';
import '../business_layer/IWeeklyRecommendationBll.dart';


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

  @override
  void initState() {
    super.initState();
    _weeklyRecommendationBll = WeeklyRecommendationBll();
    _courseFuture = _loadCourseContent();
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
          widget.course.title ?? 'Course',
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading course content...',
            style: TextStyle(
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
              'Failed to load course content',
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
                  _courseFuture = _loadCourseContent();
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
    return const Center(
      child: Text(
        'No course content available',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCourseContent(RecommendedCourse course) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                        course.title ?? 'Course',
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
                              course.difficulty ?? 'Beginner',
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
                              '${course.duration ?? '1-2'} hours',
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

                const SizedBox(height: 24),

                // Course Progress Indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Progress',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00BCD4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 0.0, // Start with 0% progress
                        backgroundColor: const Color(0xFF333333),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '0% Complete',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Course Description (if available)
                if (course.description?.isNotEmpty == true) ...[
                  Text(
                    'About this course',
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
                  'Course Content',
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
            'Course content is being generated...',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered course content will be available shortly. Please check back in a few moments.',
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
            label: const Text('Refresh Content'),
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
}
