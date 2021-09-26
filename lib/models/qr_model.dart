import 'package:google_ml_kit/google_ml_kit.dart';

const barcodeLabel = {
  'unknown': 'Unknown',
  'contactInfo': 'Contact Info',
  'email': 'Email',
  'isbn': 'ISBN',
  'phone': 'Phone',
  'product': 'Product',
  'sms': 'SMS',
  'text': 'Text',
  'url': 'Link',
  'wifi': 'Wifi',
  'geographicCoordinates': 'Geographic Coordinates',
  'calendarEvent': 'Event',
  'driverLicense': 'Driver License',
};

class BarcodeBase {
  BarcodeType type;
  DateTime? dateTime;
  String? value;

  BarcodeBase({
    this.dateTime,
    this.value,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'value': value,
        'type': type.index,
        'dateTime': dateTime?.toIso8601String(),
      };

  factory BarcodeBase.fromJson(Map<String, dynamic> json) {
    BarcodeType type = BarcodeType.values[json['type']];
    switch (type) {
      case BarcodeType.wifi:
        return QRCodeWifi(
          ssid: json['ssid'],
          password: json['password'],
          encryptionType: json['encryptionType'],
          dateTime: DateTime.parse(json['dateTime']),
          value: json['value'],
        );
      case BarcodeType.url:
        return QRCodeUrl(
            value: json['value'],
            url: json['url'],
            title: json['title'],
            dateTime: DateTime.parse(json['dateTime']));
      case BarcodeType.email:
        return QRCodeEmail(
          subject: json['subject'],
          body: json['body'],
          address: json['address'],
          dateTime: DateTime.parse(json['dateTime']),
          value: json['value'],
        );
      case BarcodeType.phone:
        return QRCodePhone(
            dateTime: DateTime.parse(json['dateTime']),
            value: json['value'],
            number: json['number']);
      case BarcodeType.sms:
        return QRCodeSMS(
          phoneNumber: json['phoneNumber'],
          message: json['message'],
          dateTime: DateTime.parse(json['dateTime']),
          value: json['value'],
        );
      case BarcodeType.geographicCoordinates:
        return QRCodeGeo(
          dateTime: DateTime.parse(json['dateTime']),
          value: json['value'],
          latitude: json['latitude'],
          longitude: json['longitude'],
        );
      case BarcodeType.contactInfo:
        return QRCodeContact(
          dateTime: DateTime.parse(json['dateTime']),
          value: json['value'],
          formattedName: json['formattedName'],
          address: json['address'],
          email: json['email'],
          phoneNumbers: json['phoneNumbers'],
          organizationName: json['organizationName'],
          url: json['url'],
        );
      case BarcodeType.calendarEvent:
        return QRCodeCalenderEvent(
          dateTime: DateTime.parse(json['dateTime']),
          value: json['value'],
          description: json['description'],
          location: json['location'],
          status: json['status'],
          summary: json['summary'],
          organizer: json['organizer'],
          start: DateTime.tryParse(json['start']),
          end: DateTime.tryParse(json['end']),
        );
      default:
        return BarcodeBase(
          value: json['value'],
          type: type,
          dateTime: DateTime.parse(json['dateTime']),
        );
    }
  }

  factory BarcodeBase.fromModel(Barcode model) {
    BarcodeType type = model.type;
    switch (type) {
      case BarcodeType.wifi:
        var wifi = model.value as BarcodeWifi;
        return QRCodeWifi(
          ssid: wifi.ssid,
          password: wifi.password,
          encryptionType: wifi.encryptionType,
          dateTime: DateTime.now(),
          value: wifi.rawValue,
        );
      case BarcodeType.url:
        var url = model.value as BarcodeUrl;
        return QRCodeUrl(
          url: url.url,
          title: url.title,
          dateTime: DateTime.now(),
          value: url.rawValue,
        );
      case BarcodeType.email:
        var email = model.value as BarcodeEmail;
        return QRCodeEmail(
          body: email.body,
          subject: email.subject,
          address: email.address,
          dateTime: DateTime.now(),
          value: email.rawValue,
        );
      case BarcodeType.phone:
        var phone = model.value as BarcodePhone;
        return QRCodePhone(
          number: phone.number,
          dateTime: DateTime.now(),
          value: phone.rawValue,
        );
      case BarcodeType.sms:
        var sms = model.value as BarcodeSMS;
        return QRCodeSMS(
          dateTime: DateTime.now(),
          value: sms.rawValue,
          phoneNumber: sms.phoneNumber,
          message: sms.message,
        );
      case BarcodeType.geographicCoordinates:
        var geo = model.value as BarcodeGeo;
        return QRCodeGeo(
            latitude: geo.latitude,
            longitude: geo.longitude,
            value: geo.rawValue,
            dateTime: DateTime.now());
      case BarcodeType.contactInfo:
        var contact = model.value as BarcodeContactInfo;
        return QRCodeContact(
            formattedName: contact.formattedName,
            organizationName: contact.organizationName,
            phoneNumbers: contact.phoneNumbers.isNotEmpty
                ? contact.phoneNumbers.map((e) => e.number).join(';')
                : '',
            address: contact.addresses.isNotEmpty ? contact.addresses[0].addressLines[0] : '',
            email: contact.emails.isNotEmpty ? contact.emails[0].address : '',
            url: contact.urls.isNotEmpty ? contact.urls[0] : '',
            value: contact.rawValue,
            dateTime: DateTime.now());
      case BarcodeType.calendarEvent:
        var event = model.value as BarcodeCalenderEvent;
        return QRCodeCalenderEvent(
            start: event.start,
            end: event.end,
            status: event.status,
            description: event.description,
            location: event.location,
            summary: event.summary,
            organizer: event.organizer,
            value: event.rawValue,
            dateTime: DateTime.now());
      // case BarcodeType.driverLicense:
      //   return Barcode._(
      //       value: BarcodeDriverLicense._(barcodeData), type: type);
      default:
        return BarcodeBase(value: model.value.rawValue, type: type);
    }
  }
}

class QRCodeWifi extends BarcodeBase {
  String? ssid;
  String? password;
  int? encryptionType;

  QRCodeWifi({
    this.ssid,
    this.password,
    this.encryptionType,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.wifi, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'ssid': ssid,
        'password': password,
        'encryptionType': encryptionType,
      };
}

class QRCodeUrl extends BarcodeBase {
  String? url;
  String? title;

  QRCodeUrl({
    this.url,
    this.title,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.url, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'url': url,
        'title': title,
      };
}

class QRCodeEmail extends BarcodeBase {
  String? subject;
  String? address;
  String? body;

  QRCodeEmail({
    this.subject,
    this.body,
    this.address,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.email, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'body': body,
        'subject': subject,
        'address': address,
      };
}

class QRCodePhone extends BarcodeBase {
  String? number;

  QRCodePhone({
    this.number,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.phone, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'number': number,
      };
}

class QRCodeSMS extends BarcodeBase {
  String? message;
  String? phoneNumber;
  QRCodeSMS({
    this.phoneNumber,
    this.message,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.sms, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'phoneNumber': phoneNumber,
        'message': message,
      };
}

class QRCodeGeo extends BarcodeBase {
  double? latitude;
  double? longitude;

  QRCodeGeo({
    this.latitude,
    this.longitude,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.geographicCoordinates, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'latitude': latitude,
        'longitude': longitude,
      };
}

class QRCodeContact extends BarcodeBase {
  final String? address;
  final String? email;
  final String? formattedName;
  final String? url;
  final String? phoneNumbers;
  final String? organizationName;

  QRCodeContact({
    this.formattedName,
    this.url,
    this.phoneNumbers,
    this.organizationName,
    this.address,
    this.email,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.contactInfo, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'formattedName': formattedName,
        'email': email,
        'address': address,
        'phoneNumbers': phoneNumbers,
        'url': url,
        'organizationName': organizationName,
      };
}

class QRCodeCalenderEvent extends BarcodeBase {
  final String? description;
  final String? location;
  final String? status;
  final String? summary;
  final String? organizer;
  final DateTime? start;
  final DateTime? end;

  QRCodeCalenderEvent({
    this.description,
    this.location,
    this.status,
    this.summary,
    this.organizer,
    this.start,
    this.end,
    DateTime? dateTime,
    String? value,
  }) : super(type: BarcodeType.calendarEvent, dateTime: dateTime, value: value);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'description': description,
        'location': location,
        'status': status,
        'summary': summary,
        'organizer': organizer,
        'start': start?.toIso8601String(),
        'end': end?.toIso8601String(),
      };
}
