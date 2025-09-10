import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/CareerAdvice.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdviceResultsStep extends StatefulWidget {
  final Map<String, dynamic> careerData;
  final VoidCallback onRestart;

  const AdviceResultsStep({super.key, required this.careerData, required this.onRestart});

  @override
  State<AdviceResultsStep> createState() => _AdviceResultsStepState();
}

class _AdviceResultsStepState extends State<AdviceResultsStep> {
  final IUserBLL _userBll = UserBll();
  bool _isGenerating = true;
  CareerAdvice? _advice;
  String? _errorMessage;
  
  final Color _primaryColor = const Color(0xFF7B3FE4);

  @override
  void initState() {
    super.initState();
    _generateAdvice();
  }

  Future<void> _generateAdvice() async {
    try {
      setState(() {
        _isGenerating = true;
        _errorMessage = null;
      });

      // Create the request object
      final requestData = CareerAdviceRequest(
        careerGoal: widget.careerData['careerGoal'],
        skillRatings: Map<String, int>.from(widget.careerData['skillRatings'] ?? {}),
        selectedIndustries: List<String>.from(widget.careerData['selectedIndustries'] ?? []),
        workPreferences: Map<String, String>.from(widget.careerData['workPreferences'] ?? {}),
        cvCompleted: widget.careerData['cvCompleted'] ?? false,
        timestamp: DateTime.now(),
      );

      // Call the UserBLL method to get AI-generated advice
      final CareerAdvice careerAdvice = await _userBll.getCareerAdvice(requestData);
      
      setState(() {
        _advice = careerAdvice;
        _isGenerating = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
        // Fallback to local advice generation if API fails
        _advice = _createPersonalizedAdvice();
      });
    }
  }

  // Fallback method - now returns CareerAdvice object
  CareerAdvice _createPersonalizedAdvice() {
    final careerGoal = widget.careerData['careerGoal'] as String?;
    final skillRatings = widget.careerData['skillRatings'] as Map<String, int>? ?? {};
    final industries = widget.careerData['selectedIndustries'] as List<String>? ?? [];
    final workPrefs = widget.careerData['workPreferences'] as Map<String, String>? ?? {};

    // Find top skills and areas for improvement
    final topSkills = skillRatings.entries
        .where((entry) => entry.value >= 4)
        .map((entry) => entry.key)
        .toList();
    
    final improvementAreas = skillRatings.entries
        .where((entry) => entry.value <= 2)
        .map((entry) => entry.key)
        .toList();

    // Create CareerAdvice object with fallback data
    return CareerAdvice(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      summary: _generateSummary(careerGoal, topSkills, industries),
      recommendations: _generateRecommendations(careerGoal, topSkills, improvementAreas, industries),
      skillDevelopment: _generateSkillDevelopment(improvementAreas, careerGoal),
      nextSteps: _generateNextSteps(careerGoal, workPrefs),
      resources: _generateResources(careerGoal, industries),
      requestData: CareerAdviceRequest(
        careerGoal: careerGoal,
        skillRatings: skillRatings,
        selectedIndustries: industries,
        workPreferences: workPrefs,
        cvCompleted: widget.careerData['cvCompleted'] ?? false,
        timestamp: DateTime.now(),
      ),
      createdAt: DateTime.now(),
    );
  }

  String _generateSummary(String? goal, List<String> topSkills, List<String> industries) {
    final skillText = topSkills.isNotEmpty 
        ? "Your strongest skills are in ${topSkills.take(3).join(', ')}."
        : "You have a balanced skill set across multiple areas.";
    
    final industryText = industries.isNotEmpty
        ? " You're interested in ${industries.join(', ')} industries."
        : "";
    
    final goalText = goal != null 
        ? " Your primary goal is to $goal."
        : "";

    return "Based on your profile analysis:$goalText $skillText$industryText This positions you well for several exciting career opportunities.";
  }

  List<String> _generateRecommendations(String? goal, List<String> topSkills, List<String> improvements, List<String> industries) {
    List<String> recommendations = [];

    if (goal?.contains('promoted') == true) {
      recommendations.addAll([
        "Focus on developing leadership and management skills to demonstrate promotion readiness",
        "Seek mentorship opportunities and build relationships with senior colleagues",
        "Take on high-visibility projects that showcase your expertise",
      ]);
    } else if (goal?.contains('Switch') == true) {
      recommendations.addAll([
        "Network within your target industries through professional events and LinkedIn",
        "Consider obtaining industry-specific certifications or training",
        "Start building a portfolio that demonstrates transferable skills",
      ]);
    } else if (goal?.contains('salary') == true) {
      recommendations.addAll([
        "Research market salary benchmarks for your role and location",
        "Prepare a compelling case highlighting your achievements and value-add",
        "Consider additional certifications that command higher compensation",
      ]);
    }

    if (topSkills.contains('Technical & Digital')) {
      recommendations.add("Leverage your technical skills by staying current with emerging technologies");
    }

    if (topSkills.contains('Leadership & Management')) {
      recommendations.add("Consider management track opportunities or team lead positions");
    }

    return recommendations.take(4).toList();
  }

  List<String> _generateSkillDevelopment(List<String> improvements, String? goal) {
    if (improvements.isEmpty) return ["Continue maintaining your current skill levels"];

    List<String> suggestions = [];
    
    for (String skill in improvements.take(3)) {
      switch (skill) {
        case 'Leadership & Management':
          suggestions.add("Enroll in leadership training programs or pursue an MBA");
          break;
        case 'Technical & Digital':
          suggestions.add("Take online courses in relevant technologies or obtain certifications");
          break;
        case 'Communication & Interpersonal':
          suggestions.add("Join Toastmasters or take public speaking courses");
          break;
        case 'Problem Solving & Analytics':
          suggestions.add("Practice with analytical tools and data analysis platforms");
          break;
        default:
          suggestions.add("Seek training opportunities in $skill through workshops or online learning");
      }
    }

    return suggestions;
  }

  List<String> _generateNextSteps(String? goal, Map<String, String> workPrefs) {
    List<String> steps = [
      "Update your CV to highlight relevant achievements and skills",
      "Optimize your LinkedIn profile with keywords from your target roles",
    ];

    if (goal?.contains('Switch') == true) {
      steps.add("Start networking in your target industry through events and online communities");
      steps.add("Consider informational interviews with professionals in your desired field");
    } else {
      steps.add("Have a career development conversation with your current manager");
      steps.add("Identify internal opportunities that align with your goals");
    }

    if (workPrefs['Work Location'] == 'Remote') {
      steps.add("Focus on companies and roles that offer remote work opportunities");
    }

    return steps;
  }

  List<CareerResource> _generateResources(String? goal, List<String> industries) {
    List<CareerResource> resources = [
      CareerResource(
        title: 'LinkedIn Learning',
        description: 'Professional skill development courses',
        type: 'platform',
        url: 'https://linkedin.com/learning',
      ),
      CareerResource(
        title: 'Coursera',
        description: 'University-level courses and certifications',
        type: 'platform',
        url: 'https://coursera.org',
      ),
      CareerResource(
        title: 'Indeed Career Guide',
        description: 'Industry insights and salary information',
        type: 'tool',
        url: 'https://indeed.com/career-advice',
      ),
    ];

    if (industries.contains('Technology & Software')) {
      resources.addAll([
        CareerResource(
          title: 'GitHub',
          description: 'Showcase your technical projects and code',
          type: 'platform',
          url: 'https://github.com',
        ),
        CareerResource(
          title: 'Stack Overflow',
          description: 'Technical community and learning',
          type: 'platform',
          url: 'https://stackoverflow.com',
        ),
      ]);
    }

    if (industries.contains('Marketing & Advertising')) {
      resources.addAll([
        CareerResource(
          title: 'Google Analytics Academy',
          description: 'Digital marketing certification',
          type: 'certification',
          url: 'https://skillshop.withgoogle.com',
        ),
        CareerResource(
          title: 'HubSpot Academy',
          description: 'Marketing and sales training',
          type: 'certification',
          url: 'https://academy.hubspot.com',
        ),
      ]);
    }

    return resources;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isGenerating) {
      return _buildLoadingView(isMobile);
    }

    if (_errorMessage != null) {
      return _buildErrorView(isMobile);
    }

    if (_advice == null) {
      return _buildNoAdviceView(isMobile);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 24),
          _buildSummaryCard(isMobile),
          const SizedBox(height: 24),
          _buildRecommendationsCard(isMobile),
          const SizedBox(height: 24),
          _buildSkillDevelopmentCard(isMobile),
          const SizedBox(height: 24),
          _buildNextStepsCard(isMobile),
          const SizedBox(height: 24),
          _buildResourcesCard(isMobile),
          const SizedBox(height: 32),
          _buildActionButtons(isMobile),
        ],
      ),
    );
  }

  Widget _buildLoadingView(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
              ),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.analyzingYourProfile,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.aiCraftingAdvice,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.thisMayTakeMoments,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.connectionIssue,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.backupSystemAdvice,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _generateAdvice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.tryAgain),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isGenerating = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: BorderSide(color: _primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.continueButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAdviceView(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noAdviceAvailable,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noAdviceGenerated,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_fix_high, color: _primaryColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.personalizedCareerAdvice,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _errorMessage != null 
                        ? AppLocalizations.of(context)!.generatedWithBackup
                        : AppLocalizations.of(context)!.aiGeneratedInsights,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _errorMessage != null ? Colors.orange : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.backupSystemNote,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(bool isMobile) {
    return _buildAdviceCard(
      AppLocalizations.of(context)!.careerSummary,
      Icons.summarize,
      Colors.blue,
      [_advice?.summary ?? AppLocalizations.of(context)!.noItemsAvailable],
      isMobile,
    );
  }

  Widget _buildRecommendationsCard(bool isMobile) {
    final recommendations = _advice?.recommendations ?? [];
    return _buildAdviceCard(
      AppLocalizations.of(context)!.keyRecommendations,
      Icons.lightbulb_outline,
      Colors.orange,
      recommendations,
      isMobile,
    );
  }

  Widget _buildSkillDevelopmentCard(bool isMobile) {
    final skills = _advice?.skillDevelopment ?? [];
    return _buildAdviceCard(
      AppLocalizations.of(context)!.skillDevelopment,
      Icons.trending_up,
      Colors.green,
      skills,
      isMobile,
    );
  }

  Widget _buildNextStepsCard(bool isMobile) {
    final steps = _advice?.nextSteps ?? [];
    return _buildAdviceCard(
      AppLocalizations.of(context)!.nextSteps,
      Icons.checklist,
      _primaryColor,
      steps,
      isMobile,
    );
  }

  Widget _buildAdviceCard(String title, IconData icon, Color color, List<String> items, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              AppLocalizations.of(context)!.noItemsAvailable,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildResourcesCard(bool isMobile) {
    final resources = _advice?.resources ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.library_books, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.recommendedResources,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (resources.isEmpty)
            Text(
              AppLocalizations.of(context)!.noResourcesAvailable,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...resources.map((resource) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resource.title ?? AppLocalizations.of(context)!.untitledResource,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      if (resource.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            resource.type!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (resource.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resource.description!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  if (resource.url != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              resource.url!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.blue.shade600,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _copyToClipboard(resource.url!, context),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.copy,
                                size: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.urlCopiedToClipboard,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildActionButtons(bool isMobile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/my-cv');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_document),
            label: Text(AppLocalizations.of(context)!.updateMyCv),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onRestart,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: BorderSide(color: _primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.getNewAdvice),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/jobs');
          },
          child: Text(
            AppLocalizations.of(context)!.browseJobOpportunities,
            style: TextStyle(color: _primaryColor),
          ),
        ),
      ],
    );
  }
}