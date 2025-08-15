import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareerGoalsStep extends StatefulWidget {
  final Function({Map<String, dynamic>? data}) onNext;
  final VoidCallback onPrevious;

  const CareerGoalsStep({super.key, required this.onNext, required this.onPrevious});

  @override
  State<CareerGoalsStep> createState() => _CareerGoalsStepState();
}

class _CareerGoalsStepState extends State<CareerGoalsStep> {
  String? _selectedGoal;
  final List<String> _careerGoals = [
    'Get promoted in current role',
    'Switch to a new industry',
    'Find a better work-life balance',
    'Increase salary significantly',
    'Develop new skills',
    'Start my own business',
    'Find remote work opportunities',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final Color primaryColor = const Color(0xFF7B3FE4);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your main career goal?',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select your primary objective so I can tailor advice to your needs.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _careerGoals.length,
              itemBuilder: (context, index) {
                final goal = _careerGoals[index];
                final isSelected = _selectedGoal == goal;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedGoal = goal),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? primaryColor : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                goal,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? primaryColor : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
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
                  onPressed: _selectedGoal != null
                      ? () => widget.onNext(data: {'careerGoal': _selectedGoal})
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}