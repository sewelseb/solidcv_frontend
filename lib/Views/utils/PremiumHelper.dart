class PremiumHelper {
  /// Returns true if the premiumSubscriptionDate epoch timestamp is in the future.
  /// Supports both seconds and milliseconds since epoch.
  static bool isPremiumActive(int? premiumSubscriptionDate) {
    if (premiumSubscriptionDate == null) return false;
    final ts = premiumSubscriptionDate;
    final isSeconds = ts < 1000000000000; // < ~2001 in ms
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      isSeconds ? ts * 1000 : ts,
      isUtc: true,
    ).toUtc();
    return expiry.isAfter(DateTime.now().toUtc());
  }
}
