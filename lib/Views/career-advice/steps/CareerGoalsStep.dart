import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CareerGoalsStep extends StatefulWidget {
  final Function({Map<String, dynamic>? data}) onNext;
  final VoidCallback onPrevious;

  const CareerGoalsStep({super.key, required this.onNext, required this.onPrevious});

  @override
  State<CareerGoalsStep> createState() => _CareerGoalsStepState();
}

class _CareerGoalsStepState extends State<CareerGoalsStep> {
  String? _selectedGoal;
  final TextEditingController _customGoalController = TextEditingController();
  final FocusNode _customGoalFocus = FocusNode();
  
  List<String> _getCareerGoals(BuildContext context) {
    return [
      AppLocalizations.of(context)!.getPromotedCurrentRole,
      AppLocalizations.of(context)!.switchToNewIndustry,
      AppLocalizations.of(context)!.findBetterWorkLifeBalance,
      AppLocalizations.of(context)!.increaseSalarySignificantly,
      AppLocalizations.of(context)!.developNewSkills,
      AppLocalizations.of(context)!.startMyOwnBusiness,
      AppLocalizations.of(context)!.findRemoteWorkOpportunities,
      AppLocalizations.of(context)!.other,
    ];
  }

  @override
  void dispose() {
    _customGoalController.dispose();
    _customGoalFocus.dispose();
    super.dispose();
  }

  bool _canContinue(BuildContext context) {
    if (_selectedGoal == null) return false;
    if (_selectedGoal == AppLocalizations.of(context)!.other) {
      return _customGoalController.text.trim().isNotEmpty;
    }
    return true;
  }

  String _getFinalGoal(BuildContext context) {
    if (_selectedGoal == AppLocalizations.of(context)!.other) {
      return _customGoalController.text.trim();
    }
    return _selectedGoal ?? '';
  }

  void _onGoalSelected(String goal, BuildContext context) {
    setState(() {
      _selectedGoal = goal;
    });
    
    // If "Other" is selected, focus on the text field
    if (goal == AppLocalizations.of(context)!.other) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _customGoalFocus.requestFocus();
      });
    }
  }

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
            AppLocalizations.of(context)!.whatsYourMainCareerGoal,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectPrimaryObjective,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _getCareerGoals(context).length,
                    itemBuilder: (context, index) {
                      final goal = _getCareerGoals(context)[index];
                      final isSelected = _selectedGoal == goal;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _onGoalSelected(goal, context),
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
                
                // Custom goal input field - shows only when "Other" is selected
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _selectedGoal == AppLocalizations.of(context)!.other ? null : 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _selectedGoal == AppLocalizations.of(context)!.other ? 1.0 : 0.0,
                    child: _selectedGoal == AppLocalizations.of(context)!.other 
                        ? Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.describeYourCareerGoal,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _customGoalController,
                                  focusNode: _customGoalFocus,
                                  maxLines: 3,
                                  maxLength: 200,
                                  onChanged: (value) => setState(() {}), // Trigger rebuild for button state
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.careerGoalHintText,
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                    counterStyle: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.beSpecificCareerGoal,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
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
                  onPressed: _canContinue(context)
                      ? () => widget.onNext(data: {'careerGoal': _getFinalGoal(context)})
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_selectedGoal == AppLocalizations.of(context)!.other && _customGoalController.text.trim().isEmpty
                      ? AppLocalizations.of(context)!.enterYourGoalAbove
                      : AppLocalizations.of(context)!.continueButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}