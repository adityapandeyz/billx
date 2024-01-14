class Firm {
  Firm({
    this.id,
    required this.name,
    required this.firmId,
    required this.address,
    required this.gstin,
    required this.phone,
    required this.password,
  });

  int? id;

  String name;

  String firmId;

  String address;

  String gstin;

  String phone;

  String password;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firmId': firmId,
      'address': address,
      'gstin': gstin,
      'phone': phone,
      'passowrd': password,
    };
  }

  factory Firm.fromJson(Map<String, dynamic> json) {
    return Firm(
      id: json['id'],
      name: json['name'],
      firmId: json['firmId'],
      address: json['address'],
      gstin: json['gstin'],
      phone: json['phone'],
      password: json['password'],
    );
  }
}
