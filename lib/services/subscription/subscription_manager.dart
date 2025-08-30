// subscription_manager.dart

import 'package:four_secrets_wedding_app/services/subscription/revenuecat_subscription_service.dart';

class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  final RevenueCatService _revenueCatService = RevenueCatService();
  bool _hasActiveSubscription = false;

  Future<void> initialize(String userId) async {
    await _revenueCatService.initialize(userId);
    await checkSubscriptionStatus();
  }

  Future<bool> checkSubscriptionStatus() async {
    try {
      _hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      return _hasActiveSubscription;
    } catch (e) {
      print('❌ Error checking subscription status: $e');
      return _hasActiveSubscription; // Return cached value on error
    }
  }

  bool get hasActiveSubscription => _hasActiveSubscription;
}
