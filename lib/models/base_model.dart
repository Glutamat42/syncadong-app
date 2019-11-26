abstract class BaseModel {
  int id;
  DateTime createdAt, updatedAt, deletedAt;

  Map<String, dynamic> toMap();
}
