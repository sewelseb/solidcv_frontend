import 'package:flutter/material.dart';
import 'package:solid_cv/Views/widgets/MyCvWidgets/DesktopView/SkillCard.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class MySkills extends StatefulWidget {
  const MySkills({Key? key}) : super(key: key);

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String skillName = '';
        return AlertDialog(
          title: const Text('Add a New Skill'),
          content: TextField(
            onChanged: (value) => skillName = value,
            decoration: const InputDecoration(hintText: 'Enter skill name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (skillName.isNotEmpty) {
                  _userBLL.addSkill(skillName);
                  setState(() {
                    _skills = _userBLL.getMySkills();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('+ Add'),
            ),
          ],
        );
      },
    );
  }
}

