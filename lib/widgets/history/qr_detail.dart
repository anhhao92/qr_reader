import 'package:ai_barcode/models/qr_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRDetail extends StatelessWidget {
  final BarcodeBase model;
  const QRDetail(this.model, {Key? key}) : super(key: key);

  IconData _getIcon(BarcodeType type) {
    switch (type) {
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

  Widget _buildBarcode() {
    switch (model.type) {
      case BarcodeType.wifi:
        var barcodeWifi = model as QRCodeWifi;
        var auth = { 0: 'No authentication', 1: 'WPA', 2: 'WPA2'};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('SSID: ',
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
                SelectableText('${barcodeWifi.ssid}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    )),
              ],
            ),
            Row(
              children: [
                const Text('Password: ',
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
                SelectableText('${barcodeWifi.password}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    )),
              ],
            ),
            Row(
              children: [
                const Text('Authentication: ',
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
                SelectableText('${auth[barcodeWifi.encryptionType]}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    )),
              ],
            ),
          ],
        );
      case BarcodeType.url:
        var barcodeUrl = model as QRCodeUrl;
        return InkWell(
          onTap: () => launch(barcodeUrl.url!),
          child: Text(barcodeUrl.url!,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 18,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              )),
        );
      case BarcodeType.email:
        QRCodeEmail barcodeEmail = model as QRCodeEmail;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address: ',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: SelectableText('${barcodeEmail.address}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subject: ',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: SelectableText('${barcodeEmail.subject}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Body: ',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: SelectableText('${barcodeEmail.body}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
          ],
        );

      case BarcodeType.sms:
        var barcodeSMS = model as QRCodeSMS;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone number: ',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: SelectableText('${barcodeSMS.phoneNumber}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Message: ',
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SelectableText('${barcodeSMS.message}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
          ],
        );
      case BarcodeType.geographicCoordinates:
        var barcodeGeo = model as QRCodeGeo;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${barcodeGeo.latitude}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                )),
            Text('Longitude: ${barcodeGeo.longitude}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                )),
          ],
        );
      case BarcodeType.calendarEvent:
        var evt = model as QRCodeCalenderEvent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SelectableText('${evt.summary}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SelectableText('${evt.description}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Start: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SelectableText(
                      evt.start != null ? DateFormat.MMMd().add_jm().format(evt.start!) : '',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('End: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SelectableText(
                      evt.end != null ? DateFormat.MMMd().add_jm().format(evt.end!) : '',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      )),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Organizer: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SelectableText('${evt.organizer}',
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      )),
                ),
              ],
            ),
          ],
        );
      case BarcodeType.contactInfo:
        var barcodeContact = model as QRCodeContact;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Contact Name: ',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                SelectableText('${barcodeContact.formattedName}',
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                const Text('Phone: ',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                SelectableText('${barcodeContact.phoneNumbers}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
              ],
            ),
            Row(
              children: [
                const Text('Website: ',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                SelectableText('${barcodeContact.url}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
              ],
            ),
            Row(
              children: [
                const Text('Address: ',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                SelectableText('${barcodeContact.address}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
              ],
            ),
            Row(
              children: [
                const Text('Company: ',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                SelectableText('${barcodeContact.organizationName}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
              ],
            ),
            Row(
              children: [
                const Text('Email: ',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                SelectableText('${barcodeContact.email}',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    )),
              ],
            ),
          ],
        );

      default:
        return SelectableText(
          model.value!,
          maxLines: 6,
          style: const TextStyle(fontSize: 18),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? title = barcodeLabel[describeEnum(model.type)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          tileColor: Colors.teal[50],
          leading: Icon(
            _getIcon(model.type),
            size: 40,
          ),
          title: Text(
            title ?? 'Unknown',
            maxLines: 2,
          ),
          subtitle: Text(
            DateFormat.MMMd().add_jm().format(DateTime.now()),
            maxLines: 2,
          ),
        ),
        Container(
            padding: const EdgeInsets.all(8.0), color: Colors.yellow[50], child: _buildBarcode()),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.content_copy_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: model.value));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Copied to clipboard"),
                ));
              },
              iconSize: 32,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(model.value!, subject: 'Sharing QR'),
              iconSize: 32,
            ),
          ],
        )
      ],
    );
  }
}
