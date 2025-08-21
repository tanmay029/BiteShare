// lib/app/data/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logRecipeView(String recipeId) async {
    await _analytics.logEvent(
      name: 'recipe_view',
      parameters: {'recipe_id': recipeId},
    );
  }
  
  static Future<void> logRecipeCreate() async {
    await _analytics.logEvent(name: 'recipe_create');
  }
  
  static Future<void> logSubscription(String creatorId) async {
    await _analytics.logEvent(
      name: 'subscription_purchase',
      parameters: {'creator_id': creatorId},
    );
  }
}
