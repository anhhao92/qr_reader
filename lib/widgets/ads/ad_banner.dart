import 'package:ai_barcode/providers/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({Key? key}) : super(key: key);

  @override
  AdBannerState createState() => AdBannerState();
}

class AdBannerState extends State<AdBanner> {
  final String bannerAdUnitId = 'ca-app-pub-7998480824138602/7661098751';

  BannerAd? bannerAd;
  @override
  void initState() {
    super.initState();
    setState(() {
      bannerAd = BannerAd(
        adUnitId: kDebugMode ? BannerAd.testAdUnitId : bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      )..load();
    });
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAds = Provider.of<AppState>(context).showAds;
    if (showAds && bannerAd != null) {
      return SizedBox(
        height: 50,
        child: AdWidget(ad: bannerAd!),
      );
    }
    return Container();
  }
}
