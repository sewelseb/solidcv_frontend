import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormatDate {
  String formatDateForCertificate(BuildContext context, String? input) {
    try {
      if (input == null || input.isEmpty) return AppLocalizations.of(context)!.dateUnknown;
      final micros = int.parse(input);
      final date = DateTime.fromMicrosecondsSinceEpoch(micros);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return input ?? AppLocalizations.of(context)!.dateUnknown;
    }
  }

    String formatDateForExperience(BuildContext context, int? millis) {
    if (millis == null) return AppLocalizations.of(context)!.ongoing;
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day}/${date.month}/${date.year}';
  }
}