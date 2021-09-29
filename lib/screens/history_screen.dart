import 'package:ai_barcode/providers/app_state.dart';
import 'package:ai_barcode/widgets/ads/ad_banner.dart';
import 'package:ai_barcode/widgets/history/qr_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = '/history';

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    Provider.of<AppState>(context, listen: false).getHistoryScan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<AppState>(context).list;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AdBanner(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return QRItem(item);
              },
              childCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}
