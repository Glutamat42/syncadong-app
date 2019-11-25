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
  DateTime timestamp;

  LogEntry({
    this.id,
    this.timestamp,
  });

  factory LogEntry.fromJson(String str) => LogEntry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LogEntry.fromMap(Map<String, dynamic> json) {
    String timestamp = json["created_at"] ??json["updated_at"] ??json["deleted_at"];
    return LogEntry(
    id: json["id"] == null ? null : json["id"],
    timestamp: timestamp == null ? null : DateTime.parse(timestamp),
  );
  }

  Map<String, dynamic> toMap() => {
    "id": id == null ? null : id,
    "timestamp": timestamp == null ? null : timestamp.toIso8601String(),
  };
}
