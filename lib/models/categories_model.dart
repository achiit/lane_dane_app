import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class CategoriesModel {
  @Id()
  late int? id;
  final String message;

  late DateTime lastAccessed;
  late int? serverId;

  CategoriesModel({
    this.id,
    this.serverId,
    required this.lastAccessed,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
    };
  }

  factory CategoriesModel.fromMap(Map<String, dynamic> map) {
    return CategoriesModel(
      id: map['id'] != null ? map['id'] as int : null,
      message: map['message'] as String,
      lastAccessed: DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriesModel.fromJson(String source) =>
      CategoriesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  void updateServerId(int newServerId) {
    serverId = newServerId;
  }
}
