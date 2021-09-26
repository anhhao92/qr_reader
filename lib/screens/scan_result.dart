import 'package:ai_barcode/models/qr_model.dart';
import 'package:ai_barcode/widgets/ads/ad_banner.dart';
import 'package:ai_barcode/widgets/history/qr_detail.dart';
import 'package:flutter/material.dart';

class ScanResultScreen extends StatelessWidget {
  static String routeName = '/result';
  const ScanResultScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barcodes = ModalRoute.of(context)?.settings.arguments as List<BarcodeBase>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: barcodes.map((e) => QRDetail(e)).toList(),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}
