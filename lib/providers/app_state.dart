import 'dart:async';
import 'dart:convert';
import 'package:ai_barcode/models/product.dart';
import 'package:ai_barcode/models/qr_model.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Set<String> _kIds = {'remove_ads'};

class AppState with ChangeNotifier {
  final List<BarcodeBase> _list = [];
  bool showAds = true;
  // In app purchase
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> products = [];
  bool pendingPurchase = false;
  bool isStoreAvailable = false;
  Function? onPurchaseError;
  Function? onPurchaseCompleted;
  // Getter
  List<BarcodeBase> get list => _list;

  AppState() {
    initStore();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    _listenToPurchaseUpdated(purchaseDetailsList);
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    // print('Stream error');
  }

  void buy(ProductDetails product, {Function? onSuccess, Function? onError}) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    onPurchaseCompleted = onSuccess;
    onPurchaseError = onError;
  }

  Future<void> initStore() async {
    getPastPurchases();
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    isStoreAvailable = await _inAppPurchase.isAvailable();
    if (isStoreAvailable) {
      ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
      products = response.productDetails;
      notifyListeners();
    }
  }

  void restorePurchases() {
    InAppPurchase.instance.restorePurchases();
  }

  Future<VerifiedProduct?> getPastPurchases() async {
    var prefs = await SharedPreferences.getInstance();
    var jsonString = prefs.getString('purchasedProduct');
    if (jsonString != null) {
      var response = VerifiedProduct.fromJson(jsonDecode(jsonString));
      showAds = false;
      notifyListeners();
      return response;
    }
    return null;
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          pendingPurchase = true;
          notifyListeners();
          return;
        case PurchaseStatus.error:
          onPurchaseError!();
          return;
        case PurchaseStatus.purchased:
          var prefs = await SharedPreferences.getInstance();
          prefs.setString(
              'purchasedProduct',
              jsonEncode(VerifiedProduct(
                  productId: purchaseDetails.productID,
                  purchaseId: purchaseDetails.purchaseID,
                  transactionDate: purchaseDetails.transactionDate,
                  source: purchaseDetails.verificationData.source,
                  verificationData: purchaseDetails.verificationData.serverVerificationData)));

          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          //   deliverProduct(purchaseDetails);
          // } else {
          //   _handleInvalidPurchase(purchaseDetails);
          //   return;
          // }
          pendingPurchase = false;
          showAds = false;
          break;
        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
        onPurchaseCompleted!();
        notifyListeners();
      }
    }
  }

  Future<void> getHistoryScan() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? jsonString = prefs.getStringList('list');
    if (jsonString != null) {
      _list.addAll(jsonString.map((json) => BarcodeBase.fromJson(jsonDecode(json))));
    }
    notifyListeners();
  }

  Future<void> addList(
    Iterable<BarcodeBase> codes,
  ) async {
    var prefs = await SharedPreferences.getInstance();
    _list.insertAll(0, codes);
    prefs.setStringList('list', _list.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }

  Future<void> removeItem(
    BarcodeBase item,
  ) async {
    var prefs = await SharedPreferences.getInstance();
    _list.remove(item);
    prefs.setStringList('list', _list.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }
}
