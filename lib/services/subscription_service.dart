
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService with ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

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
      return false;
    }
  }
}
