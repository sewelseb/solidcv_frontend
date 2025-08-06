import 'package:flutter/material.dart';
import 'package:solid_cv/Views/components/logo_concepts.dart';

class LogoConceptsShowcase extends StatelessWidget {
  const LogoConceptsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solid CV Logo Concepts'),
        backgroundColor: const Color(0xFF7B3FE4),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF7F8FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Preferred Logo Concept',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3FE4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Each concept emphasizes CV validation in different ways',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Concept 1: Certificate
            _buildConceptCard(
              '1. Certificate Style',
              'Professional certificate with gold validation seal',
              'Best for: Corporate, formal environments',
              const SolidCVLogoCertificate(size: 120),
              Colors.amber.shade50,
            ),

            const SizedBox(height: 24),

            // Concept 2: Badge
            _buildConceptCard(
              '2. Verification Badge',
              'Circular badge with "VERIFIED" stamp effect',
              'Best for: Trust-focused, authentication services',
              const SolidCVLogoBadge(size: 120),
              Colors.green.shade50,
            ),

            const SizedBox(height: 24),

            // Concept 3: Minimal
            _buildConceptCard(
              '3. Modern Minimal',
              'Clean design with integrated checkmark',
              'Best for: Modern, tech-savvy audiences',
              const SolidCVLogoMinimal(size: 120),
              Colors.blue.shade50,
            ),

            const SizedBox(height: 24),

            // Concept 4: Tech
            _buildConceptCard(
              '4. Tech/Blockchain',
              'Hexagonal frame with circuit connections',
              'Best for: Blockchain, tech-focused branding',
              const SolidCVLogoTech(size: 120),
              Colors.cyan.shade50,
            ),

            const SizedBox(height: 24),

            // Concept 5: Shield
            _buildConceptCard(
              '5. Security Shield',
              'Protective shield with embedded CV document',
              'Best for: Security, protection emphasis',
              const SolidCVLogoShield(size: 120),
              Colors.indigo.shade50,
            ),

            const SizedBox(height: 40),

            // Size variations
            const Text(
              'Size Variations Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3FE4),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Example: Certificate Style in Different Sizes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const SolidCVLogoCertificate(size: 80, showText: false),
                            const SizedBox(height: 8),
                            Text('Large\n(80px)', 
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SolidCVLogoCertificate(size: 60, showText: false),
                            const SizedBox(height: 8),
                            Text('Medium\n(60px)', 
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SolidCVLogoCertificate(size: 40, showText: false),
                            const SizedBox(height: 8),
                            Text('Small\n(40px)', 
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SolidCVLogoCertificate(size: 24, showText: false),
                            const SizedBox(height: 8),
                            Text('Icon\n(24px)', 
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Usage recommendation
            Card(
              color: const Color(0xFF7B3FE4).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF7B3FE4),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B3FE4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For a CV validation service, we recommend either:\n'
                      '• Certificate Style (professional trust)\n'
                      '• Verification Badge (clear validation message)\n'
                      '• Security Shield (protection emphasis)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptCard(
    String title,
    String description,
    String bestFor,
    Widget logo,
    Color backgroundColor,
  ) {
    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Logo
              logo,
              const SizedBox(width: 20),
              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B3FE4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bestFor,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
