import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  
  List<Map<String, dynamic>> _getIndustries(BuildContext context) {
    return [
      {'name': AppLocalizations.of(context)!.technologySoftware, 'icon': Icons.computer},
      {'name': AppLocalizations.of(context)!.healthcareMedicine, 'icon': Icons.local_hospital},
      {'name': AppLocalizations.of(context)!.financeBanking, 'icon': Icons.account_balance},
      {'name': AppLocalizations.of(context)!.educationTraining, 'icon': Icons.school},
      {'name': AppLocalizations.of(context)!.marketingAdvertising, 'icon': Icons.campaign},
      {'name': AppLocalizations.of(context)!.consulting, 'icon': Icons.business},
      {'name': AppLocalizations.of(context)!.manufacturing, 'icon': Icons.precision_manufacturing},
      {'name': AppLocalizations.of(context)!.retailEcommerce, 'icon': Icons.shopping_cart},
      {'name': AppLocalizations.of(context)!.mediaEntertainment, 'icon': Icons.movie},
      {'name': AppLocalizations.of(context)!.nonprofitNgo, 'icon': Icons.volunteer_activism},
      {'name': AppLocalizations.of(context)!.governmentPublicSector, 'icon': Icons.account_balance},
      {'name': AppLocalizations.of(context)!.energyEnvironment, 'icon': Icons.eco},
    ];
  }

  Map<String, List<String>> _getWorkPreferenceOptions(BuildContext context) {
    return {
      AppLocalizations.of(context)!.workLocation: [
        AppLocalizations.of(context)!.remote, 
        AppLocalizations.of(context)!.hybrid, 
        AppLocalizations.of(context)!.onsite, 
        AppLocalizations.of(context)!.noPreference
      ],
      AppLocalizations.of(context)!.companySize: [
        AppLocalizations.of(context)!.startup1to50, 
        AppLocalizations.of(context)!.medium51to500, 
        AppLocalizations.of(context)!.large500plus, 
        AppLocalizations.of(context)!.noPreference
      ],
      AppLocalizations.of(context)!.workSchedule: [
        AppLocalizations.of(context)!.fullTime, 
        AppLocalizations.of(context)!.partTime, 
        AppLocalizations.of(context)!.freelanceContract, 
        AppLocalizations.of(context)!.flexible
      ],
    };
  }

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
            AppLocalizations.of(context)!.industryWorkPreferences,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectIndustriesDescription,
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
                    AppLocalizations.of(context)!.industriesOfInterest,
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
                    children: _getIndustries(context).map((industry) {
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
                    AppLocalizations.of(context)!.workPreferences,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._getWorkPreferenceOptions(context).entries.map((entry) {
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
                  child: Text(AppLocalizations.of(context)!.back),
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
                  child: Text(AppLocalizations.of(context)!.generateAdvice),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}