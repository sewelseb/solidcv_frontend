import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/Views/widgets/MainBottomNavigationBar.dart';
import 'package:solid_cv/business_layer/IWeeklyRecommendationBll.dart';
import 'package:solid_cv/business_layer/WeeklyRecommendationBll.dart';
import 'package:solid_cv/models/WeeklyRecommendation.dart';

class WeeklyRecommendationsPage extends StatefulWidget {
  @override
  _WeeklyRecommendationsPageState createState() => _WeeklyRecommendationsPageState();
}

class _WeeklyRecommendationsPageState extends State<WeeklyRecommendationsPage> {
  final IWeeklyRecommendationBll _weeklyRecommendationBll = WeeklyRecommendationBll(); 
  
  late Future<WeeklyRecommendation> _weeklyRecommendationFuture;
  late Future<WeeklyProgress> _weeklyProgressFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weeklyRecommendationFuture = _weeklyRecommendationBll.getCurrentWeekRecommendations();
    _weeklyProgressFuture = _weeklyRecommendationBll.getWeeklyProgress();
  }

  void _refreshRecommendations() {
    setState(() {
      _weeklyRecommendationFuture = _weeklyRecommendationBll.getCurrentWeekRecommendations();
      _weeklyProgressFuture = _weeklyRecommendationBll.getWeeklyProgress();
    });
  }

  Future<void> _markCourseAsCompleted(int courseId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _weeklyRecommendationBll.markCourseAsCompleted(courseId);
      _refreshRecommendations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking course as completed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmEventRegistration(int eventId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final success = await _weeklyRecommendationBll.registerForEvent(eventId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your registration has been confirmed!'), backgroundColor: Colors.green),
        );
        _refreshRecommendations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not confirm registration.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCourse(RecommendedCourse course) {
    Navigator.pushNamed(
      context,
      '/course-viewer',
      arguments: course,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<WeeklyRecommendation>(
                future: _weeklyRecommendationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading recommendations',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshRecommendations,
                            child: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00BCD4),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recommendations available',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back later for new recommendations',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildRecommendationsContent(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.trending_up,
                color: Color(0xFF00BCD4),
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Recommendations',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Boost your career this week',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Color(0xFF00BCD4)),
                onPressed: _refreshRecommendations,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsContent(WeeklyRecommendation recommendation) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekInfoCard(recommendation),
          SizedBox(height: 24),
          FutureBuilder<WeeklyProgress>(
            future: _weeklyProgressFuture,
            builder: (context, progressSnapshot) {
              if (progressSnapshot.hasData) {
                return _buildProgressCard(progressSnapshot.data!);
              }
              return Container(); // Don't show progress card if no data
            },
          ),
          SizedBox(height: 24),
          _buildCoursesSection(recommendation.courses ?? []),
          SizedBox(height: 24),
          _buildEventsSection(recommendation.events ?? []),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeekInfoCard(WeeklyRecommendation recommendation) {
    
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00BCD4).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Text(
            'Weekly Recommendations',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
         
        ],
      ),
    );
  }

  int _getWeekNumber(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
      return (dayOfYear / 7).ceil();
    } catch (e) {
      return DateTime.now().weekday;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildProgressCard(WeeklyProgress progress) {
    final totalTasks = (progress.totalCourses ?? 0) + (progress.totalEvents ?? 0);
    final completedTasks = (progress.completedCourses ?? 0) + (progress.registeredEvents ?? 0);
    final progressPercentage = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF00BCD4), size: 24),
              SizedBox(width: 12),
              Text(
                'Weekly Progress',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Color(0xFF4A4A4A),
            valueColor: AlwaysStoppedAnimation<Color>(
              progressPercentage >= 1.0 ? Colors.green : Color(0xFF00BCD4),
            ),
            minHeight: 8,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressPercentage * 100).toInt()}% Complete',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedTasks / $totalTasks tasks',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'Courses',
                  progress.completedCourses ?? 0,
                  progress.totalCourses ?? 0,
                  Icons.school,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildProgressStat(
                  'Events',
                  progress.registeredEvents ?? 0,
                  progress.totalEvents ?? 0,
                  Icons.event,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int completed, int total, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF00BCD4), size: 20),
          SizedBox(height: 8),
          Text(
            '$completed/$total',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(List<RecommendedCourse> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school, color: Color(0xFF00BCD4), size: 24),
            SizedBox(width: 12),
            Text(
              'Recommended Courses (${courses.length})',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (courses.isEmpty)
          _buildEmptyState('No courses available this week', Icons.school)
        else
          ...courses.map((course) => _buildCourseCard(course)).toList(),
      ],
    );
  }

  Widget _buildEventsSection(List<RecommendedEvent> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event, color: Color(0xFF00BCD4), size: 24),
            SizedBox(width: 12),
            Text(
              'Recommended Events (${events.length})',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (events.isEmpty)
          _buildEmptyState('No events available this week', Icons.event)
        else
          ...events.map((event) => _buildEventCard(event)).toList(),
      ],
    );
  }

  Widget _buildCourseCard(RecommendedCourse course) {
    final isCompleted = course.isCompleted ?? false;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Color(0xFF3A3A3A),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title ?? 'Untitled Course',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (course.provider?.isNotEmpty == true) ...[
                      SizedBox(height: 4),
                      Text(
                        'By ${course.provider}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (course.description?.isNotEmpty == true) ...[
            SizedBox(height: 8),
            Text(
              course.description!,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
          ],
          SizedBox(height: 12),
          Row(
            children: [
              if (course.duration?.isNotEmpty == true) ...[
                Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                SizedBox(width: 4),
                Text(
                  course.duration!,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(width: 16),
              ],
              if (course.difficulty?.isNotEmpty == true) ...[
                Icon(Icons.bar_chart, color: Colors.grey[400], size: 16),
                SizedBox(width: 4),
                Text(
                  course.difficulty!,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
              Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _navigateToCourse(course),
                    child: Text(isCompleted ? 'Review Course' : 'Start Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7B3FE4),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(RecommendedEvent event) {
    final isRegistered = event.isRegistered ?? false;
    DateTime? eventDate;
    
    // Try to parse the date
    if (event.date != null) {
      try {
        eventDate = DateTime.fromMillisecondsSinceEpoch(event.date! * 1000);
      } catch (e) {
        // If parsing fails, assume it's in the future
        eventDate = DateTime.now().add(Duration(days: 7));
      }
    } else {
      eventDate = DateTime.now().add(Duration(days: 7));
    }
    
    final isPastEvent = eventDate.isBefore(DateTime.now());
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRegistered ? Colors.green : Color(0xFF3A3A3A),
          width: isRegistered ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? 'Untitled Event',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (event.organizer?.isNotEmpty == true) ...[
                      SizedBox(height: 4),
                      Text(
                        'By ${event.organizer}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isRegistered)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Registered',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
            if (event.url?.isNotEmpty == true) ...[
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = event.url!;
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open event URL')),
                    );
                  }
                },
                icon: Icon(Icons.link),
                label: Text('Go to the event website'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          SizedBox(height: 12),
          Row(
            children: [
              Spacer(),
              if (!isRegistered && !isPastEvent)
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _confirmEventRegistration(event.id ?? 0),
                  child: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('I have registered to the event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF3A3A3A)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
