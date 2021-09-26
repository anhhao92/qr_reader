import 'package:ai_barcode/models/qr_model.dart';
import 'package:ai_barcode/providers/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';

class QRItem extends StatelessWidget {
  final BarcodeBase model;
  const QRItem(this.model, {Key? key}) : super(key: key);

  IconData _getIcon(BarcodeType type) {
    switch (type) {
      case BarcodeType.unknown:
      case BarcodeType.isbn:
      case BarcodeType.text:
      case BarcodeType.product:
        return Icons.inventory_2_outlined;
      case BarcodeType.wifi:
        return Icons.wifi;
      case BarcodeType.url:
        return Icons.link;
      case BarcodeType.email:
        return Icons.email;
      case BarcodeType.phone:
        return Icons.phone;
      case BarcodeType.sms:
        return Icons.sms;
      case BarcodeType.geographicCoordinates:
        return Icons.location_on;
      case BarcodeType.driverLicense:
        return Icons.drive_eta;
      case BarcodeType.contactInfo:
        return Icons.contact_mail;
      case BarcodeType.calendarEvent:
        return Icons.event;
      default:
        return Icons.qr_code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? title = barcodeLabel[describeEnum(model.type)];
    final provider = Provider.of<AppState>(context, listen: false);

    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed('/result', arguments: [model]);
      },
      child: Card(
        color: Colors.blueGrey[50],
        child: ListTile(
            leading: Icon(
              _getIcon(model.type),
              size: 40,
            ),
            title: Text(
              title ?? 'Unknown',
              maxLines: 2,
            ),
            subtitle: Text(
              model.value!,
              maxLines: 2,
            ),
            trailing: IconButton(
                onPressed: () {
                  provider.removeItem(model);
                },
                icon: const Icon(Icons.delete))),
      ),
    );
  }
}
