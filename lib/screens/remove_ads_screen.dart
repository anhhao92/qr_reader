import 'package:ai_barcode/providers/app_state.dart';
import 'package:ai_barcode/widgets/ads/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemoveAdsScreen extends StatefulWidget {
  static String routeName = '/remove-ads';

  const RemoveAdsScreen({Key? key}) : super(key: key);

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  void onPurchaseError() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Something wrong'),
        content: const Text('There was an error.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void onPurchaseCompleted() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Thank you'),
        content: const Text('You have been purchased successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              Navigator.of(context).pushNamed('/');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildListProduct() {
    var appState = Provider.of<AppState>(context);
    if (!appState.isStoreAvailable || appState.products.isEmpty) {
      return const ListTile(
          leading: Icon(Icons.close, color: Colors.red),
          title: Text('Google Play Store is not available'));
    }

    return ListView(
        children: appState.products
            .map((product) => ListTile(
                  tileColor: Colors.grey[100],
                  title: Text(
                    product.title,
                    maxLines: 1,
                  ),
                  subtitle: Text(product.description),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () {
                      Provider.of<AppState>(context, listen: false)
                          .buy(product, onSuccess: onPurchaseCompleted, onError: onPurchaseError);
                    },
                    child: Text(product.price),
                  ),
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Ads'),
      ),
      body: Column(children: [
        Expanded(child: _buildListProduct()),
        const AdBanner(),
      ]),
    );
  }
}
