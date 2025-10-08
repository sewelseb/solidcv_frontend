import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/SkillCard.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class MySkills extends StatefulWidget {
  final VoidCallback? onSkillAdded;
  const MySkills({super.key, this.onSkillAdded});

  @override
  _MySkillsState createState() => _MySkillsState();
}

class _MySkillsState extends State<MySkills> {
  final IUserBLL _userBLL = UserBll();
  late Future<List<Skill>> _skills;

  @override
  void initState() {
    super.initState();
    _skills = _userBLL.getMySkills();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        FutureBuilder<List<Skill>>(
          future: _skills,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(AppLocalizations.of(context)!.mySkillsError(snapshot.error.toString())),
              );
            }

            final skills = snapshot.data ?? [];
            if (skills.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.mySkillsNoSkillsFound,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: skills.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final skill = skills[index];
                return SkillCard(
                  skill: skill,
                  onCheckWithAI: () {
                    Navigator.pushNamed(
                        context, '/check-my-skill-with-ai/${skill.id}');
                  },
                  onDeleted: () {
                    setState(() {
                      _skills = _userBLL.getMySkills();
                    });
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.mySkillsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          onPressed: _showAddSkillDialog,
          icon: const Icon(Icons.add_circle_outline),
          tooltip: AppLocalizations.of(context)!.mySkillsAddTooltip,
        ),
      ],
    );
  }

  void _showAddSkillDialog() {
    final TextEditingController controller = TextEditingController();
    bool error = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final media = MediaQuery.of(context);
        final screenWidth = media.size.width;
        final bool isMobile = screenWidth < 600;
        final double horizontalInset = isMobile ? 16 : 24;
        final double maxDialogWidth = isMobile
            ? screenWidth - (horizontalInset * 2)
            : 520; // wider on desktop/tablet
        final double minDialogWidth = math.min(280, maxDialogWidth);
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(
                horizontal: horizontalInset,
                vertical: isMobile ? 16 : 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: AnimatedPadding(
              // Ensures dialog moves above keyboard on small screens
              padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxDialogWidth,
                  minWidth: minDialogWidth,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_circle_outline,
                                color: Color(0xFF7B3FE4), size: 28),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)!.mySkillsDialogTitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF7B3FE4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.mySkillsSkillNameLabel,
                            hintText: AppLocalizations.of(context)!.mySkillsSkillNameHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF7B3FE4), width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: error ? AppLocalizations.of(context)!.mySkillsSkillNameError : null,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                          ),
                onChanged: (_) => setState(() => error = false),
                onSubmitted: (_) => _onAddSkill(
                  setState, controller, context, () => setState(() => error = true)),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF7B3FE4),
                                  side: const BorderSide(
                                      color: Color(0xFF7B3FE4), width: 1.2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                child: Text(AppLocalizations.of(context)!.mySkillsCancel,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _onAddSkill(setState, controller, context,
                                        () => setState(() => error = true)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7B3FE4),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.mySkillsAdd,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAddSkill(
    void Function(void Function()) setDialogState,
    TextEditingController controller,
    BuildContext dialogContext,
    VoidCallback onValidationError,
  ) async {
    String skillName = controller.text.trim();
    if (skillName.isEmpty) {
      // Show field error inside the dialog when the input is empty
      onValidationError();
      return;
    }

    try {
  await _userBLL.addSkill(skillName);

      if (mounted) {
        setState(() {
          _skills = _userBLL.getMySkills();
        });
        Navigator.of(dialogContext).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mySkillsSkillAdded),
            backgroundColor: const Color(0xFF7B3FE4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        );
        if (widget.onSkillAdded != null) {
          widget.onSkillAdded!();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mySkillsError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
