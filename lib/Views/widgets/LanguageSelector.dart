import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/data_access_layer/helpers/APIConnectionHelper.dart';

class LanguageSelector extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Locale? currentLocale;

  const LanguageSelector({
    super.key,
    required this.onLanguageChanged,
    this.currentLocale,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final IUserBLL _userBll = UserBll();

  Future<void> _handleLanguageChange(Locale locale) async {
    // Update language locally first
    widget.onLanguageChanged(locale);
    
    // Check if user is authenticated and update preference on backend
    try {
      final token = await APIConnectionHelper.getJwtToken();
      if (token.isNotEmpty) {
        // User is authenticated, update language preference on backend
        await _userBll.updateLanguagePreference(locale.languageCode);
      }
    } catch (e) {
      // If backend call fails, we still want the local language change to work
      // The user will see a different UI language even if their preference isn't saved
      debugPrint('Failed to update language preference on backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: localizations.changeLanguage,
      onSelected: _handleLanguageChange,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en', ''),
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              Text(localizations.english),
              if (widget.currentLocale?.languageCode == 'en')
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
              if (widget.currentLocale?.languageCode == 'es')
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
              if (widget.currentLocale?.languageCode == 'fr')
                const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }
}

class LanguageSelectorButton extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Locale? currentLocale;

  const LanguageSelectorButton({
    super.key,
    required this.onLanguageChanged,
    this.currentLocale,
  });

  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  final IUserBLL _userBll = UserBll();

  Future<void> _handleLanguageChange(Locale locale) async {
    // Update language locally first
    widget.onLanguageChanged(locale);
    
    // Check if user is authenticated and update preference on backend
    try {
      final token = await APIConnectionHelper.getJwtToken();
      if (token.isNotEmpty) {
        // User is authenticated, update language preference on backend
        await _userBll.updateLanguagePreference(locale.languageCode);
      }
    } catch (e) {
      // If backend call fails, we still want the local language change to work
      debugPrint('Failed to update language preference on backend: $e');
    }
  }

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
                trailing: widget.currentLocale?.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  _handleLanguageChange(const Locale('en', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇪🇸'),
                title: Text(localizations.spanish),
                trailing: widget.currentLocale?.languageCode == 'es'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  _handleLanguageChange(const Locale('es', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇫🇷'),
                title: Text(localizations.french),
                trailing: widget.currentLocale?.languageCode == 'fr'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  _handleLanguageChange(const Locale('fr', ''));
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
