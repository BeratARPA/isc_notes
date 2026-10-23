class NoteModel {
  int? id;
  int? categoryId;
  String title;
  String content;
  bool isPinned;
  bool isLocked;
  String? password;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  NoteModel({
    this.id,
    this.title = '',
    this.content = '',
    this.categoryId,
    this.isPinned = false,
    this.isLocked = false,
    this.password,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory NoteModel.fromMap(Map<String, dynamic> json) => NoteModel(
    id: json["id"],
    categoryId: json["categoryId"],
    title: json["title"] ?? "",
    content: json["content"] ?? "",
    isPinned: json["isPinned"] ?? false,
    isLocked: json["isLocked"] ?? false,
    password: json["password"],
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
    "categoryId": categoryId,
    "title": title,
    "content": content,
    "isPinned": isPinned,
    "isLocked": isLocked,
    "password": password,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "deletedAt": deletedAt,
  };
}
