import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:jwells/features/payment/presentation/view/screens/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentMethodScreen extends StatefulWidget {
  final VoidCallback onPurchaseSuccess;

  const PaymentMethodScreen({
    super.key,
    required this.onPurchaseSuccess,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {

  static const Color _bgColor = Color(0xFF031108);
  static const Color _cardColor = Color(0xFF111111);
  static const Color _accentColor = Color(0xFF3EDC7A);
  static const Color _mutedTextColor = Color(0xFFA7A7A7);

  Offerings? offerings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOfferings();
  }

  Future<void> loadOfferings() async {
    try {
     
      await RevenuecatService.syncSubscriptionStatusWithBackend();
      offerings = await RevenuecatService.getOfferings();
    } catch (e) {
      log("Error loading offerings: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> buyPackage(Package package) async {
    final success = await RevenuecatService.purchasePackage(package);
    if (!mounted) return;

    if (success) {
      widget.onPurchaseSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase failed or cancelled")),
      );
    }
  }

  Future<void> restore() async {
    final info = await RevenuecatService.restorePurchases();
    if (!mounted) return;


    if (info?.entitlements.all['premium']?.isActive ?? false) {
      widget.onPurchaseSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing to restore")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = offerings?.current?.availablePackages ?? [];

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text("Select Subscription Plan"),
        backgroundColor: const Color.fromARGB(255, 21, 52, 31),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _accentColor))
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Unlock the Full Power of SilentWhistle",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return _buildPackageCard(package);
                      },
                    ),
                  ),
                  _buildFooterSection(),
                ],
              ),
            ),
    );
  }


  Widget _buildPackageCard(Package package) {
    bool isAnnual = package.packageType == PackageType.annual;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAnnual ? _accentColor : _accentColor.withOpacity(0.2),
          width: isAnnual ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isAnnual)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: const Text(
                  "BEST VALUE",
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => buyPackage(package),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getPackageName(package),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          package.storeProduct.priceString,
                          style: const TextStyle(color: _accentColor, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPackageDescription(package),
                      style: const TextStyle(color: _mutedTextColor, fontSize: 13),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(color: Colors.white10),
                    ),
                    ..._buildFeatureItems(package),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _getPackageName(Package package) {
    switch (package.packageType) {
      case PackageType.monthly: return "1 Month Premium";
      case PackageType.threeMonth: return "3 Month Quarter Plan";
      case PackageType.sixMonth: return "6 Month Pro Access";
      case PackageType.annual: return "1 Year - Best Value";
      default: return "Free Trial";
    }
  }

 
  String _getPackageDescription(Package package) {
    switch (package.packageType) {
      case PackageType.monthly: return "Flexible monthly access to post freely, view location-based content, and enjoy premium essentials.";
      case PackageType.threeMonth: return "A balanced plan for consistent posting, wider location visibility, and stronger audience reach.";
      case PackageType.sixMonth: return "Professional access for active users who need better reach, deeper visibility, and more control.";
      case PackageType.annual: return "Our most complete premium package with full posting power, location access, and maximum account benefits.";
      default: return "Start exploring premium tools with better visibility, posting freedom, and location-based access.";
    }
  }


  List<Widget> _buildFeatureItems(Package package) {
    final List<String> features;

    switch (package.packageType) {
      case PackageType.monthly:
        features = [
          "Post shouts with premium access enabled",
          "View and explore location-based content",
          "Access nearby and extended location feeds",
          "Enjoy a smoother ad-free experience",
        ];
        break;
      case PackageType.threeMonth:
        features = [
          "Everything included in the Monthly plan",
          "Continue posting across supported locations",
          "Get broader visibility for your public shouts",
          "1.5x reach boost on every eligible post",
          "Standard performance insights access",
        ];
        break;
      case PackageType.sixMonth://
        features = [
          "Everything included in the 3-Month plan",
          "Professional posting access with location flexibility",
          "See more relevant content across locations",
          "3x stronger reach for premium shout distribution",
          "Priority support and premium account benefits",
        ];
        break;
      case PackageType.annual:
        features = [
          "Full access to all premium posting features",
          "Complete location visibility and discovery access",
          "Maximum reach support for high-priority shouts",
          "Advanced analytics and future premium upgrades",
          "Priority account status with long-term value",
        ];
        break;
      default:
        features = [
          "Basic posting access",
          "Limited local content discovery",
        ];
    }

    return features.map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    )).toList();
  }


  Widget _buildFooterSection() {
    return Column(
      children: [
        TextButton(
          onPressed: restore,
          child: const Text("Restore Purchases", style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _linkText("Terms of Use (EULA)", "https://silentwhistle.app/legal/eula"),
            const Text("  |  ", style: TextStyle(color: Colors.white24)),
            _linkText("Privacy Policy", "https://silentwhistle.app/legal/privacy-policy"),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _linkText(String text, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Text(text, style: const TextStyle(color: _mutedTextColor, fontSize: 11)),
    );
  }
}
