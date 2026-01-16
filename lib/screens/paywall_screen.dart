
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/subscription_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  PaywallScreenState createState() => PaywallScreenState();
}

class PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlanIndex = 1; // Default to yearly
  List<Package> _packages = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          _packages = offerings.current!.availablePackages;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final subscriptionService = Provider.of<SubscriptionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.upgrade_appbar_title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(localizations),
            const SizedBox(height: 32),
            if (_error != null) ...[
              Text(_error!),
            ] else ...[
              _buildPlanSelector(localizations),
            ],
            const SizedBox(height: 32),
            _buildSubscribeButton(localizations, subscriptionService),
            const SizedBox(height: 16),
            _buildRestoreButton(localizations, subscriptionService),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Column(
      children: [
        Text(
          localizations.upgrade_to_pro_title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.upgrade_to_pro_subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _FeatureIcon(icon: Icons.healing, label: 'Unlimited Meds'),
            _FeatureIcon(icon: Icons.description, label: 'Export Reports'),
            _FeatureIcon(icon: Icons.people, label: 'Family Profiles'),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanSelector(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_packages.length, (index) {
          final package = _packages[index];
          return _buildPriceCard(
            localizations,
            index,
            package.storeProduct.title,
            package.storeProduct.priceString,
            package.storeProduct.description,
            index == 1, // Assume yearly is popular
          );
        }),
    );
  }

  Widget _buildPriceCard(AppLocalizations localizations, int index,
      String title, String price, String subtitle, bool isPopular) {
    final isSelected = _selectedPlanIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: PriceCard(
        title: title,
        price: price,
        subtitle: subtitle,
        isSelected: isSelected,
        isPopular: isPopular,
        localizations: localizations,
      ),
    );
  }

  Widget _buildSubscribeButton(
      AppLocalizations localizations, SubscriptionService subscriptionService) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final purchaserInfo = await Purchases.purchasePackage(_packages[_selectedPlanIndex]);
          if (purchaserInfo.entitlements.all["premium"]!.isActive) {
            subscriptionService.setPremium(true);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.subscribed_to_premium)),
            );
            if (!mounted) return;
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(localizations.subscribe_button_label),
    );
  }

  Widget _buildRestoreButton(
      AppLocalizations localizations, SubscriptionService subscriptionService) {
    return TextButton(
      onPressed: () async {
        try {
          final purchaserInfo = await Purchases.restorePurchases();
          if (purchaserInfo.entitlements.all["premium"]!.isActive) {
            subscriptionService.setPremium(true);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.restore_purchases)),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      },
      child: Text(localizations.restore_purchases_button_label),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class PriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool isSelected;
  final bool isPopular;
  final AppLocalizations localizations;

  const PriceCard({
    super.key,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    required this.isPopular,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(price,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (isPopular)
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    localizations.popular, // Popular
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
