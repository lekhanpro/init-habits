import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAppReady({required bool firebaseReady}) async {
    await _safeLog('app_ready', parameters: {'firebase_ready': firebaseReady});
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logHabitCreated(String type) async {
    await _safeLog('habit_created', parameters: {'type': type});
  }

  Future<void> logHabitCompleted({required bool completed}) async {
    await _safeLog(completed ? 'habit_completed' : 'habit_uncompleted');
  }

  Future<void> logModeChanged(String modeId) async {
    await _safeLog('mode_changed', parameters: {'mode_id': modeId});
  }

  Future<void> _safeLog(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Analytics should never interrupt core habit tracking flows.
    }
  }
}
