import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  double _fontScale = 1.0;

  bool get isInitialized => _isInitialized;
  double get fontScale => _fontScale;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _fontScale = _prefs.getDouble('font_scale') ?? 1.0;
    _isInitialized = true;
    notifyListeners();
  }

  // --- Sauvegarde des scores ---
  int getBestScore(String exerciceId) {
    if (!_isInitialized) return 0;
    return _prefs.getInt('best_score_$exerciceId') ?? 0;
  }

  int getExerciseTotal(String exerciceId) {
    if (!_isInitialized) return 0;
    return _prefs.getInt('total_$exerciceId') ?? 0;
  }

  String? getLastAttemptDate(String exerciceId) {
    if (!_isInitialized) return null;
    return _prefs.getString('last_date_$exerciceId');
  }

  Future<void> saveScore({
    required String exerciceId,
    required String leconId,
    required int score,
    required int total,
  }) async {
    if (!_isInitialized) await init();

    final int currentBest = getBestScore(exerciceId);
    if (score > currentBest || !_prefs.containsKey('best_score_$exerciceId')) {
      await _prefs.setInt('best_score_$exerciceId', score);
      await _prefs.setInt('total_$exerciceId', total);
    }

    await _prefs.setString('last_date_$exerciceId', DateTime.now().toIso8601String());
    notifyListeners();
  }

  // Calcul du score global d'une leçon (somme des meilleurs scores de ses exercices)
  Map<String, dynamic> getLeconProgress(String leconId, List<String> exerciceIds) {
    if (exerciceIds.isEmpty) {
      return {'score': 0, 'total': 0, 'pct': 0.0, 'completed': false};
    }

    int totalScore = 0;
    int maxPossible = 0;
    int doneCount = 0;

    for (final exId in exerciceIds) {
      if (_prefs.containsKey('best_score_$exId')) {
        doneCount++;
        totalScore += getBestScore(exId);
        maxPossible += getExerciseTotal(exId);
      }
    }

    final double pct = maxPossible > 0 ? (totalScore / maxPossible) * 100.0 : 0.0;
    final bool completed = doneCount == exerciceIds.length && pct >= 80.0;

    return {
      'score': totalScore,
      'total': maxPossible,
      'pct': pct,
      'completed': completed,
      'attempted': doneCount > 0,
    };
  }

  // --- Réglage de taille de police (A- / A+) ---
  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.85, 1.35);
    await _prefs.setDouble('font_scale', _fontScale);
    notifyListeners();
  }

  Future<void> increaseFontSize() async {
    await setFontScale(_fontScale + 0.1);
  }

  Future<void> decreaseFontSize() async {
    await setFontScale(_fontScale - 0.1);
  }

  // --- Réinitialisation de la progression ---
  Future<void> resetAllProgress() async {
    if (!_isInitialized) await init();
    final keys = _prefs.getKeys();
    for (final k in keys) {
      if (k.startsWith('best_score_') ||
          k.startsWith('total_') ||
          k.startsWith('last_date_')) {
        await _prefs.remove(k);
      }
    }
    notifyListeners();
  }
}
