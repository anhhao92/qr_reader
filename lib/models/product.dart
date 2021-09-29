class VerifiedProduct {
  VerifiedProduct({
    this.purchaseId,
    this.source,
    this.verificationData,
    required this.productId,
    required this.transactionDate,
  });

  String productId;
  String? purchaseId;
  String? transactionDate;
  String? source;
  String? verificationData;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'purchaseId': purchaseId,
        'transactionDate': transactionDate,
        'source': source,
        'verificationData': verificationData,
      };

  VerifiedProduct.fromJson(Map<String, dynamic> json)
      : productId = json['productId'],
        purchaseId = json['purchaseId'],
        transactionDate = json['transactionDate'],
        source = json['source'],
        verificationData = json['verificationData'];
}
