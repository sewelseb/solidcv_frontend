import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormatDate {
  String formatDateForCertificate(BuildContext context, String? input) {
    try {
      if (input == null || input.isEmpty)
        return AppLocalizations.of(context)!.dateUnknown;
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

  /// Formats a premium subscription epoch timestamp (seconds or milliseconds)
  /// as dd/MM/yyyy for display.
  String formatDateForPremiumDate(BuildContext context, int ts) {
    final isSeconds = ts < 1000000000000;
    final dt = DateTime.fromMillisecondsSinceEpoch(
      isSeconds ? ts * 1000 : ts,
      isUtc: true,
    ).toLocal();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }
}
