import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/history_screen.dart';
import 'screens/scan_result.dart';
import 'screens/scan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  var futures = await Future.wait([availableCameras(), Firebase.initializeApp()]);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp(
    cameras: futures[0] as List<CameraDescription>,
  ));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      builder: (ctx, _) => MaterialApp(
          title: 'AI QR & Barcode Reader',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: ScanScreen(cameras: cameras),
          routes: {
            HistoryScreen.routeName: (ctx) => const HistoryScreen(),
            ScanResultScreen.routeName: (ctx) => const ScanResultScreen(),
          }),
    );
  }
}
