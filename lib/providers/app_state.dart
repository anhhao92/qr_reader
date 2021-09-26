import 'dart:convert';
import 'package:ai_barcode/models/qr_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  List<BarcodeBase> _list = [];

  List<BarcodeBase> get list => _list;
  
  AppState() {
    initAppState();
  }


  Future<void> initAppState() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? jsonString = prefs.getStringList('list');
    if (jsonString != null) {
      _list = jsonString.map((json) => BarcodeBase.fromJson(jsonDecode(json))).toList();
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
