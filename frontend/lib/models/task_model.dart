import 'dart:convert';
import 'dart:ui';

import '../core/constants/utils.dart';

class TaskModel {
  final String id;
  final String uid;
  final String title;
  final Color color;
  final String description;
  final DateTime created_at;
  final DateTime updated_at;
  final DateTime due_at;
  final int isSynced;

  TaskModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.created_at,
    required this.updated_at,
    required this.due_at,
    required this.color,
    required this.isSynced,
  });

  TaskModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    DateTime? created_at,
    DateTime? updated_at,
    DateTime? due_at,
    Color? color,
    int? isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      due_at: due_at ?? this.due_at,
      color: color ?? this.color,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'due_at': due_at.toIso8601String(),
      'color': rgbToHex(color),
      'isSynced': isSynced,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      created_at: DateTime.parse(map['created_at']),
      updated_at: DateTime.parse(map['updated_at']),
      due_at: DateTime.parse(map['due_at']),
      color: hexToRgb(map['color']),
      isSynced: map['isSynced'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TaskModel(id: $id, uid: $uid, title: $title, description: $description, created_at: $created_at, updated_at: $updated_at, due_at: $due_at, color: $color)';
  }

  @override
  bool operator ==(covariant TaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.title == title &&
        other.description == description &&
        other.created_at == created_at &&
        other.updated_at == updated_at &&
        other.due_at == due_at &&
        other.color == color &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        title.hashCode ^
        description.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode ^
        due_at.hashCode ^
        color.hashCode ^
        isSynced.hashCode;
  }
}
