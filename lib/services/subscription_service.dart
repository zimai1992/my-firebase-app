import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

class SubscriptionService with ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration("goog_fake_api_key"); 
    } else if (Platform.isIOS) {
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
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.all["premium"] != null && customerInfo.entitlements.all["premium"]!.isActive;
      setPremium(isPremium);
      return isPremium;
    } catch (e) {
      return _isPremium; // Return current local state if API fails
    }
  }
}
