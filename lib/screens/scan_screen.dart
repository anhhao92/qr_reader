import 'package:ai_barcode/models/qr_model.dart';
import 'package:ai_barcode/providers/app_state.dart';
import 'package:ai_barcode/widgets/ads/ad_banner.dart';
import 'package:ai_barcode/widgets/barcode/gallery_mode.dart';
import 'package:ai_barcode/widgets/barcode/live_mode.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';

enum ScreenMode { liveFeed, gallery }

class ScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ScanScreen({Key? key, required this.cameras}) : super(key: key);
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final BarcodeScanner barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  late CameraDescription camera;
  bool isBusy = false;
  ScreenMode _mode = ScreenMode.gallery;

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) {
      return;
    }
    isBusy = true;
    final barcodes = await barcodeScanner.processImage(inputImage);
    if (barcodes.isNotEmpty) {
      if (_mode == ScreenMode.liveFeed) {
        _switchScreenMode();
      }
      var list = barcodes.map((code) => BarcodeBase.fromModel(code));
      await Provider.of<AppState>(context, listen: false).addList(list);
      await Navigator.of(context).pushNamed('/result', arguments: list.toList());
    }
    isBusy = false;
  }

  @override
  void initState() {
    for (var i = 0; i < widget.cameras.length; i++) {
      if (widget.cameras[i].lensDirection == CameraLensDirection.back) {
        camera = widget.cameras[i];
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    barcodeScanner.close();
    super.dispose();
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.Rotation_0deg;
    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.NV21;
    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    processImage(inputImage);
  }

  void _switchScreenMode() {
    if (_mode == ScreenMode.liveFeed) {
      setState(() => _mode = ScreenMode.gallery);
    } else {
      setState(() => _mode = ScreenMode.liveFeed);
    }
  }

  Widget _buildBody() {
    Widget body;
    if (_mode == ScreenMode.liveFeed) {
      body = LiveMode(
        camera: camera,
        switchScreenMode: _switchScreenMode,
        processCameraImage: _processCameraImage,
      );
    } else {
      body = GalleryMode(processImage: processImage);
    }
    return body;
  }

  void ratingApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var appState = Provider.of<AppState>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('QR & Barcode AI Reader'),
        ),
        drawer: Drawer(
            child: ListView(
          children: [
            SizedBox(
              height: 50,
              child: DrawerHeader(
                margin: const EdgeInsets.all(0),
                child: Text(
                  'AI Scanner',
                  style: textTheme.headline6,
                ),
              ),
            ),
            ListTile(
                minLeadingWidth: 20,
                leading: const Icon(Icons.search),
                title: const Text('Scan'),
                onTap: () => Navigator.of(context).popAndPushNamed('/')),
            ListTile(
                minLeadingWidth: 20,
                leading: const Icon(Icons.qr_code_scanner_outlined),
                title: const Text('Create'),
                onTap: () => Navigator.of(context).popAndPushNamed('/create')),
            ListTile(
                minLeadingWidth: 20,
                leading: const Icon(Icons.history),
                title: const Text('History'),
                onTap: () => Navigator.of(context).popAndPushNamed('/history')),
            if (appState.showAds)
              ListTile(
                  minLeadingWidth: 20,
                  leading: const Icon(Icons.monetization_on),
                  title: const Text('Remove ads'),
                  onTap: () => Navigator.of(context).popAndPushNamed('/remove-ads')),
            ListTile(
              minLeadingWidth: 20,
              leading: const Icon(Icons.thumb_up),
              title: const Text('Rating'),
              onTap: ratingApp,
            ),
          ],
        )),
        body: Column(
          children: [
            Expanded(child: _buildBody()),
            if (_mode == ScreenMode.gallery) const AdBanner(),
          ],
        ),
        floatingActionButton: Visibility(
          visible: _mode == ScreenMode.gallery,
          child: FloatingActionButton(
            onPressed: () => _switchScreenMode(),
            child: const Icon(Icons.camera),
          ),
        ));
  }
}
