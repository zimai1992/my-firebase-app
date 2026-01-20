import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';

class SubscriptionService with ChangeNotifier {
  bool _isPremium = true; // Default to TRUE for testing

  bool get isPremium => _isPremium;

  Future<void> init() async {
    if (kIsWeb) {
      // RevenueCat is not supported on Web, or requires specific web setup not present here.
      // Skipping configuration for Web.
      return;
    }

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (defaultTargetPlatform == TargetPlatform.android) {
      configuration = PurchasesConfiguration("goog_fake_api_key");
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      configuration = PurchasesConfiguration("appl_fake_api_key");
    }

    if (configuration != null) {
      try {
        await Purchases.configure(configuration);
        await isPremiumUser();
      } catch (e) {
        // Handle configuration error in environments without Play Services
      }
    }
  }

  // DEBUG METHOD FOR TESTING
  void togglePremiumDebug() {
    _isPremium = !_isPremium;
    notifyListeners();
  }

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  Future<bool> isPremiumUser() async {
    if (kIsWeb) return false;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.all["premium"] != null &&
          customerInfo.entitlements.all["premium"]!.isActive;
      setPremium(isPremium);
      return isPremium;
    } catch (e) {
      return _isPremium; // Return current local state if API fails
    }
  }
}
