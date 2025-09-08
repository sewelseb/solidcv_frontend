import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/LanguageProvider.dart';
import 'widgets/LanguageSelector.dart';

class MultilingualTestPage extends StatefulWidget {
  const MultilingualTestPage({super.key});

  @override
  State<MultilingualTestPage> createState() => _MultilingualTestPageState();
}

class _MultilingualTestPageState extends State<MultilingualTestPage> {
  final LanguageProvider _languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    _languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      // Rebuild when language changes
    });
  }

  void _changeLanguage(Locale locale) {
    _languageProvider.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          LanguageSelector(
            onLanguageChanged: _changeLanguage,
            currentLocale: _languageProvider.locale,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌍 ${localizations.appTitle}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.welcomeMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${localizations.language}: ${_getCurrentLanguageName(context)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.professionalProfile,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDemoField(localizations.firstName, 'John'),
                    _buildDemoField(localizations.lastName, 'Doe'),
                    _buildDemoField(localizations.email, 'john.doe@example.com'),
                    _buildDemoField(localizations.phoneNumber, '+1 234 567 8900'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.workExperience,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDemoField(localizations.jobTitle, 'Software Engineer'),
                    _buildDemoField(localizations.company, 'SolidCV Inc.'),
                    _buildDemoField(localizations.startDate, '2023-01-01'),
                    _buildDemoField(localizations.currentPosition, localizations.yes),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.education,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDemoField(localizations.degree, 'Computer Science'),
                    _buildDemoField(localizations.institution, 'Tech University'),
                    _buildDemoField(localizations.graduationYear, '2022'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.skills,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSkillChip('Flutter', localizations.advanced),
                    _buildSkillChip('Blockchain', localizations.intermediate),
                    _buildSkillChip('React', localizations.expert),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  LanguageSelectorButton(
                    onLanguageChanged: _changeLanguage,
                    currentLocale: _languageProvider.locale,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${localizations.success}! ${localizations.appTitle} ${localizations.welcomeMessage}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified),
                    label: Text(localizations.verifyCredentials),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Chip(
        label: Text('$skill - $level'),
        backgroundColor: Colors.blue.shade100,
      ),
    );
  }

  String _getCurrentLanguageName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = _languageProvider.locale ?? Localizations.localeOf(context);
    
    switch (locale.languageCode) {
      case 'es':
        return localizations.spanish;
      case 'fr':
        return localizations.french;
      case 'en':
      default:
        return localizations.english;
    }
  }
}
