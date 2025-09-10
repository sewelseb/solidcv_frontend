import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 54, color: Color(0xFF7B3FE4)),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.logoutDialogTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.logoutDialogMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7B3FE4),
                          side: const BorderSide(color: Color(0xFF7B3FE4), width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(AppLocalizations.of(context)!.logoutDialogCancel,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B3FE4),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(AppLocalizations.of(context)!.logoutDialogConfirm,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return confirm == true;
}

Future<void> handleLogout(BuildContext context) async {
  final confirm = await showLogoutDialog(context);
  if (confirm) {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
