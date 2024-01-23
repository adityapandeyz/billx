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
    required this.isBeingReturned,
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

  bool isBeingReturned;

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
      'isBeingReturned': isBeingReturned,
    };
  }
}
