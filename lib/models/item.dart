class Item {
  Item({
    this.id,
    required this.name,
    required this.itemId,
    required this.size,
    required this.barcode,
    required this.price,
    required this.category,
    required this.firmId,
    required this.stock,
  });

  int? id;

  String name;

  String itemId;

  String size;

  String barcode;

  int price;

  String category;

  int stock;

  String firmId;
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      itemId: json['itemId'],
      size: json['size'],
      barcode: json['barcode'],
      price: json['price'],
      category: json['category'],
      firmId: json['firmId'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemId': itemId,
      'size': size,
      'barcode': barcode,
      'price': price,
      'category': category,
      'firmId': firmId,
      'stock': stock,
    };
  }
}
