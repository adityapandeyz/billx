class OnlineBill {
  OnlineBill({
    this.id,
    required this.firmId,
    required this.createdAt,
    required this.invoice,
    required this.items,
    required this.netAmount,
    required this.totalTax,
    required this.modeOfPayment,
    required this.totalQuantity,
    required this.discAmount,
  });

  int? id;

  String firmId;

  String createdAt;

  String invoice;

  String items;

  double netAmount;

  double totalTax;

  String modeOfPayment;

  int totalQuantity;

  double discAmount;

  factory OnlineBill.fromJson(Map<String, dynamic> json) {
    return OnlineBill(
      id: json['id'],
      firmId: json['firmId'],
      createdAt: DateTime.parse(json['createdAt']).toIso8601String(),
      invoice: json['invoice'],
      items: json['items'],
      netAmount: json['netAmount'] ?? 0,
      totalTax: json['totalTax'] ?? 0,
      modeOfPayment: json['modeOfPayment'],
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
      'netAmount': netAmount,
      'totalTax': totalTax,
      'modeOfPayment': modeOfPayment,
      'totalQuantity': totalQuantity,
      'discAmount': discAmount,
    };
  }
}
