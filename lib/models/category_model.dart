class CategoryModel {
  int? id;
  String name;
  String colorHex;
  String? iconName;
  int sortOrder;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  CategoryModel({
    this.id,
    required this.name,
    this.colorHex = '#FF7043',
    this.iconName,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    name: json["name"],
    colorHex: json["colorHex"],
    iconName: json["iconName"],
    sortOrder: json["sortOrder"],
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : DateTime.now(),
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : DateTime.now(),
    deletedAt: json["deletedAt"] != null
        ? DateTime.parse(json["deletedAt"])
        : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "colorHex": colorHex,
    "iconName": iconName,
    "sortOrder": sortOrder,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "deletedAt": deletedAt,
  };
}
