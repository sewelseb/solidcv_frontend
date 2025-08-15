import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillsAssessmentStep extends StatefulWidget {
  final Function({Map<String, dynamic>? data}) onNext;
  final VoidCallback onPrevious;

  const SkillsAssessmentStep({super.key, required this.onNext, required this.onPrevious});

  @override
  State<SkillsAssessmentStep> createState() => _SkillsAssessmentStepState();
}

class _SkillsAssessmentStepState extends State<SkillsAssessmentStep> {
  final Map<String, int> _skillRatings = {};
  final List<String> _skillCategories = [
    'Leadership & Management',
    'Communication & Interpersonal',
    'Technical & Digital',
    'Problem Solving & Analytics',
    'Creativity & Innovation',
    'Project Management',
    'Sales & Marketing',
    'Financial Management',
  ];

  final Color _primaryColor = const Color(0xFF7B3FE4);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Your Skills',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rate yourself from 1 (beginner) to 5 (expert) in each skill category.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _skillCategories.length,
              itemBuilder: (context, index) {
                final skill = _skillCategories[index];
                final rating = _skillRatings[skill] ?? 0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (starIndex) {
                          final starRating = starIndex + 1;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _skillRatings[skill] = starRating;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: rating >= starRating 
                                      ? _primaryColor 
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: rating >= starRating 
                                          ? Colors.white 
                                          : Colors.grey.shade400,
                                      size: isMobile ? 16 : 20,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$starRating',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: rating >= starRating 
                                            ? Colors.white 
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Beginner',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            'Expert',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: BorderSide(color: _primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _skillRatings.length >= 3
                      ? () => widget.onNext(data: {'skillRatings': _skillRatings})
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_skillRatings.length < 3 
                      ? 'Rate at least 3 skills' 
                      : 'Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}