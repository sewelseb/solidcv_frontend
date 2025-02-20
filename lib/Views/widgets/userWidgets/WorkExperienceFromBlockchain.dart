import 'package:flutter/material.dart';
import 'package:solid_cv/models/ExperienceRecord.dart';

class WorkExperienceFromBlockchain extends StatelessWidget {
  final ExperienceRecord workExperience;

  const WorkExperienceFromBlockchain({Key? key, required this.workExperience}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Stack(
      children: [
        Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            workExperience.company!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 8),
          Text(
            workExperience.title!,
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            workExperience.startDate! + ' - ' + workExperience.endDate!,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            workExperience.description ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          ],
        ),
        ),
        Positioned(
        top: 10,
        right: 10,
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 24),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
              'Verified on the Blockchain',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ),
      ],
      ),
    );
  }
}
