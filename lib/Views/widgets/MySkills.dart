import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/Skill.dart';

class MySkills extends StatefulWidget {
  const MySkills({Key? key}) : super(key: key);

  @override
  _MySkillsState createState() => _MySkillsState();
}

class _MySkillsState extends State<MySkills> {
  IUserBLL _userBLL = UserBll();
  late Future<List<Skill>> _skills;

  @override
  Widget build(BuildContext context) {
    _skills = _userBLL.getMySkills();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
          children: [
            const Text(
              'My Skills',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.blueAccent,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddSkillDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Skill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<List<Skill>>(
          future: _skills,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
            'No skills found. Add your first skill!',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
                ),
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
            final skill = snapshot.data![index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              title: Text(
                skill.name!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  //navigate to the CheckMySkillsWithAIPage with the skill ID
                  Navigator.pushNamed(
                    context,
                    '/check-my-skill-with-ai/${skill.id}',
                  );
                },
                child: const Text('Check with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            );
                },
              );
            }
          },
              ),
            ],
          ),
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
            onChanged: (value) {
              skillName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter skill name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
                onPressed: () {
                  if (skillName.isNotEmpty) {
                    // Add logic to save the skill
                    _userBLL.addSkill(skillName);
                    // Optionally, you can refresh the list of skills here
                    setState(() {
                      _skills = _userBLL.getMySkills();
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('+  Add')),
          ],
        );
      },
    );
  }
}
