import 'dart:convert';

class TransactionLog {
  List<LogEntry> created;
  List<LogEntry> updated;
  List<LogEntry> deleted;

  TransactionLog({
    this.created,
    this.updated,
    this.deleted,
  });

  factory TransactionLog.fromJson(String str) => TransactionLog.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TransactionLog.fromMap(Map<String, dynamic> json) => TransactionLog(
    created: json["created"] == null ? null : List<LogEntry>.from(json["created"].map((x) => LogEntry.fromMap(x))),
    updated: json["updated"] == null ? null : List<LogEntry>.from(json["updated"].map((x) => LogEntry.fromMap(x))),
    deleted: json["deleted"] == null ? null : List<LogEntry>.from(json["deleted"].map((x) => LogEntry.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "created": created == null ? null : List<dynamic>.from(created.map((x) => x.toMap())),
    "updated": updated == null ? null : List<dynamic>.from(updated.map((x) => x.toMap())),
    "deleted": deleted == null ? null : List<dynamic>.from(deleted.map((x) => x.toMap())),
  };
}

class LogEntry {
  int id;
  DateTime createdAt;

  LogEntry({
    this.id,
    this.createdAt,
  });

  factory LogEntry.fromJson(String str) => LogEntry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LogEntry.fromMap(Map<String, dynamic> json) => LogEntry(
    id: json["id"] == null ? null : json["id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id == null ? null : id,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
  };
}
