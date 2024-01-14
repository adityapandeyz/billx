class Category {
  Category({
    this.id,
    required this.name,
    required this.categoryId,
    required this.firmId,
  });

  int? id;
  String name;
  String categoryId;
  String firmId;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      firmId: json['firmId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'firmId': firmId,
    };
  }
}
