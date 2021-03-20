import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:floor/floor.dart';

import 'package:http/http.dart' as http;

/// HTTP GET REQUEST
Future<List<TagTable>> fetchTag(http.Client client) async {
  final response = await client.get('http://192.168.1.55:3000/tag');

  // Spawn an isolate to parse JSON data on background
  // https://flutter.dev/docs/cookbook/networking/background-parsing
  return compute(parseTag, response.body);
}

List<TagTable> parseTag(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<TagTable>((json) => TagTable.fromJson(json)).toList();
}

/// HTTP POST REQUEST
/// Body Request: (Tag)
/// tagText - (#memo) the Text of the Tag
Future<http.Response> createTag(String tag) {
  return http.post(
    'http://192.168.1.55:3000/tag',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{'tagText': tag}),
  );
}

@Entity(tableName: 'Tag')
class TagTable {
  @PrimaryKey(autoGenerate: true)
  final int id;
  String tagText;

  TagTable({int id, String tagText})
      : id = id,
        tagText = tagText;

  Map<String, dynamic> toMap() => {
        "tagText": this.tagText,
      };

  factory TagTable.fromJson(Map<String, dynamic> json) => new TagTable(
        id: json["id"],
        tagText: json["tagText"],
      );
}

@dao
abstract class TagTableDao {
  @Query('SELECT * FROM Tag')
  Future<List<TagTable>> findAllTag();

  @Query(
      'SELECT id, tagText FROM Tag AS TagTable INNER JOIN (SELECT tagId FROM Memo_Tag INNER JOIN Memo WHERE Memo_Tag.memoId = :id GROUP BY Memo_Tag.tagId) AS TagIdTable ON TagTable.id = TagIdTable.tagId')
  Future<List<TagTable>> findAllTagByMemoId(int id);

  @Query('SELECT * FROM Tag WHERE Tag.tagText = :tag')
  Future<TagTable> findTagByTagText(String tag);

  @Query('SELECT id FROM Tag WHERE Tag.id = (SELECT Max(id) FROM Tag)')
  Future<TagTable> findLastTagId();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTag(TagTable tag);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTags(List<TagTable> tags);

  @delete
  Future<void> deleteTag(TagTable tag);

  @update
  Future<void> updateTag(TagTable tag);
}

//
