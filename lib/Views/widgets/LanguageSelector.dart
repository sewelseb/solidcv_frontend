import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final Locale? currentLocale;

  const LanguageSelector({
    super.key,
    required this.onLanguageChanged,
    this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: localizations.changeLanguage,
      onSelected: onLanguageChanged,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en', ''),
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              Text(localizations.english),
              if (currentLocale?.languageCode == 'en')
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('es', ''),
          child: Row(
            children: [
              const Text('🇪🇸'),
              const SizedBox(width: 8),
              Text(localizations.spanish),
              if (currentLocale?.languageCode == 'es')
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('fr', ''),
          child: Row(
            children: [
              const Text('🇫🇷'),
              const SizedBox(width: 8),
              Text(localizations.french),
              if (currentLocale?.languageCode == 'fr')
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }
}

class LanguageSelectorButton extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final Locale? currentLocale;

  const LanguageSelectorButton({
    super.key,
    required this.onLanguageChanged,
    this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return ElevatedButton.icon(
      onPressed: () => _showLanguageDialog(context),
      icon: const Icon(Icons.language),
      label: Text(localizations.changeLanguage),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸'),
                title: Text(localizations.english),
                trailing: currentLocale?.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  onLanguageChanged(const Locale('en', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇪🇸'),
                title: Text(localizations.spanish),
                trailing: currentLocale?.languageCode == 'es'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  onLanguageChanged(const Locale('es', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇫🇷'),
                title: Text(localizations.french),
                trailing: currentLocale?.languageCode == 'fr'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  onLanguageChanged(const Locale('fr', ''));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }
}
