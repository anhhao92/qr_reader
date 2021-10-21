import 'dart:io';
import 'package:ai_barcode/widgets/ads/ad_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

const options = [
  'Text (Link)',
  'Wifi',
  'Geographic',
];

String? required(value) {
  if (value.isEmpty) {
    return 'Please enter required value.';
  }
  return null;
}

class CreateQRCode extends StatefulWidget {
  static String routeName = '/create';

  const CreateQRCode({Key? key}) : super(key: key);

  @override
  _CreateQRCodeState createState() => _CreateQRCodeState();
}

class _CreateQRCodeState extends State<CreateQRCode> {
  String dropdownValue = 'Text (Link)';
  String? _text = '';
  String? _ssid = '';
  String? _password = '';
  String? _la = '';
  String? _lo = '';
  String? _encrytionType = 'nopass';
  QrPainter? painter;

  final _formKey = GlobalKey<FormState>();

  void onSubmit() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      String? data = _text;
      switch (dropdownValue) {
        case 'Wifi':
          data = 'WIFI:T:$_encrytionType;S:$_ssid;P:$_password;;';
          break;
        case 'Geographic':
          data = 'geo:$_la,$_lo,';
          break;
        default:
          data = _text;
      }
      setState(() {
        painter = QrPainter(data: data!, version: QrVersions.auto);
      });
    }
  }

  void onSave() async {
    var tempDir = await getTemporaryDirectory();
    var imageBytes = await painter?.toImageData(300);
    var buffer = imageBytes!.buffer;
    var file = File('${tempDir.path}/temp.png');
    await file.writeAsBytes(buffer.asUint8List(imageBytes.offsetInBytes, imageBytes.lengthInBytes));
    Share.shareFiles(['${tempDir.path}/temp.png'], subject: 'QR Code');
  }

  Widget _buildQRType() {
    return Container(
      color: const Color(0xFFEEEFF6),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(
            Icons.qr_code_scanner_outlined,
            size: 40,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 40,
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()),
          )
        ],
      ),
    );
  }

  Widget _buildTextBody() {
    return TextFormField(
      key: const ValueKey('Text'),
      onSaved: (value) => _text = value,
      maxLines: 4,
      validator: required,
      decoration: const InputDecoration(
          labelText: 'Text',
          alignLabelWithHint: true,
          hintText: 'Enter text or link',
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
    );
  }

  Widget _buildWifiBody() {
    return Column(
      children: [
        TextFormField(
          key: const ValueKey('SSID'),
          onSaved: (value) => _ssid = value,
          validator: required,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              labelText: 'SSID',
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextFormField(
            key: const ValueKey('Password'),
            onSaved: (value) => _password = value,
            decoration: const InputDecoration(
                labelText: 'Password',
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
          ),
        ),
        Row(
          children: [
            Radio(
              value: 'nopass',
              visualDensity: VisualDensity.compact,
              groupValue: _encrytionType,
              onChanged: (String? value) => setState(() {
                _encrytionType = value;
              }),
            ),
            const Text('None'),
            Radio(
              value: 'WEP',
              visualDensity: VisualDensity.compact,
              groupValue: _encrytionType,
              onChanged: (String? value) => setState(() {
                _encrytionType = value;
              }),
            ),
            const Text('WEP'),
            Radio(
              value: 'WPA',
              visualDensity: VisualDensity.compact,
              groupValue: _encrytionType,
              onChanged: (String? value) => setState(() {
                _encrytionType = value;
              }),
            ),
            const Text('WPA/WPA2'),
          ],
        )
      ],
    );
  }

  Widget _buildGeoBody() {
    return Column(children: [
      TextFormField(
        key: const ValueKey('Latitude'),
        onSaved: (value) => _la = value,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            labelText: 'Latitute',
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          key: const ValueKey('Longitude'),
          onSaved: (value) => _lo = value,
          decoration: const InputDecoration(
              labelText: 'Longitude',
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
        ),
      ),
    ]);
  }

  Widget _buildForm() {
    late Widget body;
    switch (dropdownValue) {
      case 'Wifi':
        body = _buildWifiBody();
        break;
      case 'Geographic':
        body = _buildGeoBody();
        break;
      default:
        body = _buildTextBody();
    }
    return Form(
      key: _formKey,
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              body,
              _buildQRCode(),
              Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      child: const Text(
                        'Generate',
                      ),
                      onPressed: onSubmit,
                    ),
                    if (painter != null)
                      ElevatedButton(
                        child: const Text(
                          'Share',
                        ),
                        onPressed: onSave,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        child: painter != null
            ? CustomPaint(
                size: const Size.square(240),
                painter: painter,
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create QR Code')),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: ListView(
          children: [
            const AdBanner(),
            _buildQRType(),
            _buildForm(),
          ],
        ),
      ),
    );
  }
}
