class FormatDate {
  String formatDateForCertificate(String? input) {
    try {
      if (input == null || input.isEmpty) return 'Date unknown';
      final micros = int.parse(input);
      final date = DateTime.fromMicrosecondsSinceEpoch(micros);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return input ?? 'Date unknown';
    }
  }

    String formatDateForExperience(int? millis) {
    if (millis == null) return 'Ongoing';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day}/${date.month}/${date.year}';
  }
}