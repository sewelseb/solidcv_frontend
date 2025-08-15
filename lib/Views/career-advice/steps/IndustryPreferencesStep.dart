import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IndustryPreferencesStep extends StatefulWidget {
  final Function({Map<String, dynamic>? data}) onNext;
  final VoidCallback onPrevious;

  const IndustryPreferencesStep({super.key, required this.onNext, required this.onPrevious});

  @override
  State<IndustryPreferencesStep> createState() => _IndustryPreferencesStepState();
}

class _IndustryPreferencesStepState extends State<IndustryPreferencesStep> {
  final Set<String> _selectedIndustries = {};
  final Map<String, String> _workPreferences = {};
  
  final List<Map<String, dynamic>> _industries = [
    {'name': 'Technology & Software', 'icon': Icons.computer},
    {'name': 'Healthcare & Medicine', 'icon': Icons.local_hospital},
    {'name': 'Finance & Banking', 'icon': Icons.account_balance},
    {'name': 'Education & Training', 'icon': Icons.school},
    {'name': 'Marketing & Advertising', 'icon': Icons.campaign},
    {'name': 'Consulting', 'icon': Icons.business},
    {'name': 'Manufacturing', 'icon': Icons.precision_manufacturing},
    {'name': 'Retail & E-commerce', 'icon': Icons.shopping_cart},
    {'name': 'Media & Entertainment', 'icon': Icons.movie},
    {'name': 'Non-profit & NGO', 'icon': Icons.volunteer_activism},
    {'name': 'Government & Public Sector', 'icon': Icons.account_balance},
    {'name': 'Energy & Environment', 'icon': Icons.eco},
  ];

  final Map<String, List<String>> _workPreferenceOptions = {
    'Work Location': ['Remote', 'Hybrid', 'On-site', 'No preference'],
    'Company Size': ['Startup (1-50)', 'Medium (51-500)', 'Large (500+)', 'No preference'],
    'Work Schedule': ['Full-time', 'Part-time', 'Freelance/Contract', 'Flexible'],
  };

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
            'Industry & Work Preferences',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select industries you\'re interested in and your work preferences.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Industries Section
                  Text(
                    'Industries of Interest (Select up to 3)',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _industries.map((industry) {
                      final isSelected = _selectedIndustries.contains(industry['name']);
                      final canSelect = _selectedIndustries.length < 3 || isSelected;
                      
                      return GestureDetector(
                        onTap: canSelect ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndustries.remove(industry['name']);
                            } else {
                              _selectedIndustries.add(industry['name']);
                            }
                          });
                        } : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? _primaryColor.withOpacity(0.1) 
                                : canSelect 
                                    ? Colors.white 
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? _primaryColor 
                                  : canSelect 
                                      ? Colors.grey.shade300 
                                      : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                industry['icon'],
                                size: 20,
                                color: isSelected 
                                    ? _primaryColor 
                                    : canSelect 
                                        ? Colors.grey.shade600 
                                        : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                industry['name'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected 
                                      ? _primaryColor 
                                      : canSelect 
                                          ? Colors.black87 
                                          : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Work Preferences Section
                  Text(
                    'Work Preferences',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._workPreferenceOptions.entries.map((entry) {
                    final category = entry.key;
                    final options = entry.value;
                    final selectedOption = _workPreferences[category];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
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
                            category,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: options.map((option) {
                              final isSelected = selectedOption == option;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _workPreferences[category] = option;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? _primaryColor.withOpacity(0.1) 
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? _primaryColor : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? _primaryColor : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
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
                  onPressed: _selectedIndustries.isNotEmpty
                      ? () => widget.onNext(data: {
                          'selectedIndustries': _selectedIndustries.toList(),
                          'workPreferences': _workPreferences,
                        })
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Generate Advice'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}