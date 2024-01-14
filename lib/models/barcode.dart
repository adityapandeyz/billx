class Barcode {
  Barcode({
    required this.barcode,
    required this.name,
    required this.category,
    required this.size,
    required this.quantity,
    required this.rate,
    required this.cgst,
    required this.sgst,
    required this.itemId,
  });

  String barcode;

  String name;

  String category;

  String size;

  int quantity;

  int rate;

  double cgst;

  double sgst;

  String itemId;

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'category': category,
      'size': size,
      'quantity': quantity,
      'rate': rate,
      'cgst': cgst,
      'sgst': sgst,
      'itemId': itemId,
    };
  }

  void calculateGst(Barcode bill) {
    if (bill.rate < 1000) {
      bill.cgst = bill.rate * 0.025 * bill.quantity; // 2.5%
      bill.sgst = bill.rate * 0.025 * bill.quantity; // 2.5%
    } else {
      bill.cgst = bill.rate * 0.06 * bill.quantity; // 6%
      bill.sgst = bill.rate * 0.06 * bill.quantity; // 6%
    }
  }
}
