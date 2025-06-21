import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/SkillCard.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class MySkills extends StatefulWidget {
  final VoidCallback? onSkillAdded;
  const MySkills({Key? key,this.onSkillAdded}) : super(key: key);

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
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final skills = snapshot.data ?? [];
            if (skills.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No skills found. Add your first skill!',
                  style: TextStyle(
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
        const Text(
          'Skills',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          onPressed: _showAddSkillDialog,
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add skill',
        ),
      ],
    );
  }

  void _showAddSkillDialog() {
    final TextEditingController _controller = TextEditingController();
    bool _error = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Container(
              width: 370,
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      const Icon(Icons.add_circle_outline,
                          color: Color(0xFF7B3FE4), size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'Add a Skill',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF7B3FE4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Skill name',
                      hintText: 'E.g. Flutter, Project Management...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF7B3FE4), width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _error ? 'Please enter a skill name' : null,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                    ),
                    onChanged: (_) => setState(() => _error = false),
                    onSubmitted: (_) =>
                        _onAddSkill(setState, _controller, context),
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
                          child: const Text('Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _onAddSkill(setState, _controller, context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B3FE4),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: const Text(
                            '+ Add',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Future<void> _onAddSkill(
  void Function(void Function()) setState,
  TextEditingController controller,
  BuildContext dialogContext,
) async {
  String skillName = controller.text.trim();
  if (skillName.isEmpty) {
    setState(() => true);
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
          content: const Text('Skill added!'),
          backgroundColor: const Color(0xFF7B3FE4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}
