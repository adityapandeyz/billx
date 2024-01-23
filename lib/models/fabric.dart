class Fabric {
  int? id;
  String name;
  String fabricId;
  double totalStock;
  double totalStockSold;
  double pricePerUnit;
  String manufacturer;
  String fabricType;
  String firmId;

  Fabric({
    this.id,
    required this.name,
    required this.fabricId,
    required this.totalStock,
    required this.totalStockSold,
    required this.pricePerUnit,
    required this.manufacturer,
    required this.fabricType,
    required this.firmId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fabricId': fabricId,
      'totalStock': totalStock,
      'totalStockSold': totalStockSold,
      'pricePerUnit': pricePerUnit,
      'manufacturer': manufacturer,
      'fabricType': fabricType,
      'firmId': firmId,
    };
  }

  factory Fabric.fromJson(Map<String, dynamic> json) {
    return Fabric(
      id: json['id'],
      name: json['name'],
      fabricId: json['fabricId'],
      totalStock: json['totalStock'],
      totalStockSold: json['totalStockSold'],
      pricePerUnit: json['pricePerUnit'],
      manufacturer: json['manufacturer'],
      fabricType: json['fabricType'],
      firmId: json['firmId'],
    );
  }
}
