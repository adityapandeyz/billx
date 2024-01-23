class SplitBill {
  SplitBill({
    this.id,
    required this.firmId,
    required this.createdAt,
    required this.invoice,
    required this.items,
    required this.cashAmount,
    required this.onlineAmount,
    required this.netAmount,
    required this.totalTax,
    required this.onlinePaymentMode,
    required this.totalQuantity,
    required this.discAmount,
  });

  int? id;

  String firmId;

  String createdAt;

  String invoice;

  String items;

  double cashAmount;

  double onlineAmount;

  double netAmount;

  double totalTax;

  String onlinePaymentMode;

  int totalQuantity;

  double discAmount;

  factory SplitBill.fromJson(Map<String, dynamic> json) {
    return SplitBill(
      id: json['id'],
      firmId: json['firmId'],
      createdAt: DateTime.parse(json['createdAt']).toIso8601String(),
      invoice: json['invoice'],
      items: json['items'],
      cashAmount: json['cashAmount'],
      onlineAmount: json['onlineAmount'],
      netAmount: json['netAmount'] ?? 0,
      totalTax: json['totalTax'] ?? 0,
      onlinePaymentMode: json['onlinePaymentMode'],
      totalQuantity: json['totalQuantity'],
      discAmount: json['discAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firmId': firmId,
      'createdAt': createdAt,
      'invoice': invoice,
      'items': items,
      'cashAmount': cashAmount,
      'OnlineAmount': onlineAmount,
      'netAmount': netAmount,
      'totalTax': totalTax,
      'onlinePaymentMode': onlinePaymentMode,
      'totalQuantity': totalQuantity,
      'discAmount': discAmount,
    };
  }
}
