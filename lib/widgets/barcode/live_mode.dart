import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class LiveMode extends StatefulWidget {
  final Function switchScreenMode;
  final CustomPaint? customPaint;
  final CameraDescription camera;
  final Function(CameraImage) processCameraImage;

  @override
  State<LiveMode> createState() => _LiveModeState();

  const LiveMode({
    Key? key,
    required this.customPaint,
    required this.switchScreenMode,
    required this.camera,
    required this.processCameraImage,
  }) : super(key: key);
}

class _LiveModeState extends State<LiveMode> {
  FlashMode _mode = FlashMode.off;
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  initCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller.initialize();
    setState(() => _isInitialized = true);
    _controller.startImageStream(widget.processCameraImage);
  }

  Widget _buildCameraOverlay(
      {double padding = 0, double aspectRatio = 16 / 9, Color color = const Color(0x55000000)}) {
    return LayoutBuilder(builder: (context, constraints) {
      double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
      double horizontalPadding;
      double verticalPadding;

      if (parentAspectRatio < aspectRatio) {
        horizontalPadding = padding;
        verticalPadding =
            (constraints.maxHeight - ((constraints.maxWidth - 2 * padding) / aspectRatio)) / 2;
      } else {
        verticalPadding = padding;
        horizontalPadding =
            (constraints.maxWidth - ((constraints.maxHeight - 2 * padding) * aspectRatio)) / 2;
      }
      return Stack(fit: StackFit.expand, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(width: horizontalPadding, color: color)),
        Align(
            alignment: Alignment.centerRight,
            child: Container(width: horizontalPadding, color: color)),
        Align(
            alignment: Alignment.topCenter,
            child: Container(
                margin: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
                height: verticalPadding,
                color: color)),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
                height: verticalPadding,
                color: color)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3)),
        )
      ]);
    });
  }

  Widget _liveFeedBody() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller),
          if (widget.customPaint != null) widget.customPaint!,
          _buildCameraOverlay(padding: 50, aspectRatio: 1),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              iconSize: 30,
              onPressed: () => widget.switchScreenMode(),
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              iconSize: 30,
              onPressed: () {
                setState(() {
                  _mode = _mode == FlashMode.always ? FlashMode.off : FlashMode.auto;
                  _controller.setFlashMode(_mode);
                });
              },
              icon: _mode == FlashMode.always
                  ? const Icon(
                      Icons.flash_auto_sharp,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.flash_off,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return _liveFeedBody();
  }
}
