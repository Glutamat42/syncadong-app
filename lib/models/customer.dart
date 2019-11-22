import 'dart:convert';

class Customer {
  int id;
  int companyId;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  int randomNumber;

  Customer({
    this.id,
    this.companyId,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.randomNumber,
  });

  factory Customer.fromJson(String str) => Customer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Customer.fromMap(Map<String, dynamic> json) => Customer(
    id: json["id"] == null ? null : json["id"],
    companyId: json["company_id"] == null ? null : json["company_id"],
    name: json["name"] == null ? null : json["name"],
    randomNumber: json["random_number"] == null ? null : json["random_number"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"] == null ? null : DateTime.parse(json["deleted_at"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id == null ? null : id,
    "company_id": companyId == null ? null : companyId,
    "name": name == null ? null : name,
    "random_number": randomNumber == null ? null : randomNumber,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
    "deleted_at": deletedAt == null ? null : deletedAt.toIso8601String(),
  };
}
