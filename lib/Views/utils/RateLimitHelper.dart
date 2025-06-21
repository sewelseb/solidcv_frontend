import 'dart:async';
import 'package:flutter/foundation.dart';

class CooldownController extends ChangeNotifier {
  final int maxTries;
  final int cooldownSeconds;

  int _tries = 0;
  int _remaining = 0;
  Timer? _timer;

  int get tries => _tries;
  int get remaining => _remaining;
  bool get isCooldown => _remaining > 0;
  bool get canTry => _tries < maxTries || !isCooldown;

  CooldownController({required this.maxTries, required this.cooldownSeconds});

  void registerTry() {
    _tries += 1;
    if (_tries >= maxTries) {
      _startCooldown();
    }
    notifyListeners();
  }

  void _startCooldown() {
    _remaining = cooldownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remaining -= 1;
      notifyListeners();
      if (_remaining <= 0) {
        _timer?.cancel();
        _tries = 0;
        _remaining = 0;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
