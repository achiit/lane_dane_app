import 'package:firebase_analytics/firebase_analytics.dart';

/// Class for reusable custom events inorder to maintain event name consistency
/// for same events occuring in different parts of the app. One such example is
/// Initiating the add transaction process that can happen from different
/// screens and buttons.
class AnalyticsEvents {
  static void languageChoice({required String languageCode}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'language-choice',
      parameters: {'choice': languageCode},
    );
  }
}
