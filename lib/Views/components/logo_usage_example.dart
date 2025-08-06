import 'package:flutter/material.dart';
import 'package:solid_cv/Views/components/solid_cv_logo.dart';

class LogoUsageExample extends StatelessWidget {
  const LogoUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solid CV Logo Examples'),
        backgroundColor: const Color(0xFF7B3FE4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Solid CV - Validation Focus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3FE4),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Professional CV Validation & Verification',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            
            // Large logo with text
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SolidCVLogo(size: 120, showText: true),
                SizedBox(width: 20),
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Validation Logo', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Emphasizes CV verification\nand professional validation'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Medium logo without text
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SolidCVLogo(size: 80, showText: false),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medium Logo', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Good for headers\nand navigation'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Small validation icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const SolidCVIcon(size: 40, showValidation: true),
                    const SizedBox(height: 8),
                    Text('Validated CV', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    const SolidCVIcon(size: 32, showValidation: true),
                    const SizedBox(height: 8),
                    Text('Verified', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    const SolidCVIcon(size: 24, showValidation: false),
                    const SizedBox(height: 8),
                    Text('Simple Icon', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Usage in AppBar example
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF7B3FE4),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  SolidCVIcon(size: 32, showValidation: true),
                  SizedBox(width: 12),
                  Text(
                    'Solid CV - Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.verified, color: Color(0xFF4CAF50), size: 24),
                  SizedBox(width: 16),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Usage in AppBar',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use in your existing AppBar
class ExampleAppBarUsage extends StatelessWidget implements PreferredSizeWidget {
  const ExampleAppBarUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF7B3FE4),
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SolidCVIcon(size: 32),
      ),
      title: const Text(
        'Solid CV',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
