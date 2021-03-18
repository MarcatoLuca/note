import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:floor/floor.dart';

import 'package:http/http.dart' as http;

import 'package:note/model/memo.dart';
import 'package:note/model/tag.dart';

/// HTTP GET REQUEST
Future<List<MemoTagTable>> fetchMemoTag(http.Client client) async {
  final response = await client.get('http://192.168.1.55:3000/memo_tag');

  // Spawn an isolate to parse JSON data on background
  // https://flutter.dev/docs/cookbook/networking/background-parsing
  return compute(parseMemoTag, response.body);
}

List<MemoTagTable> parseMemoTag(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<MemoTagTable>((json) => MemoTagTable.fromJson(json))
      .toList();
}

/// HTTP POST REQUEST
/// Body Request: (MemoTag)
/// memoId - id of the Memo
/// tagId - id of the Tag
Future<http.Response> createMemoTag(int memoId, int tagId) {
  return http.post(
    'http://192.168.1.55:3000/memo_tag',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{'memoId': memoId, 'tagId': tagId}),
  );
}

/// HTTP DELETE REQUEST
/// Delete a memo by its id
Future<http.Response> deleteMemoTag(int memoId) {
  return http.delete(
    'http://192.168.1.55:3000/memo_tag?memoId=$memoId',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

@Entity(tableName: 'Memo_Tag')
class MemoTagTable {
  @PrimaryKey(autoGenerate: true)
  final int id;
  @ForeignKey(
      childColumns: ["id", "memoId", "tagId"],
      parentColumns: ["id", "userEmail", "userDisplayName", "title", "text"],
      entity: MemoTable)
  final int memoId;
  @ForeignKey(
      childColumns: ["id", "memoId", "tagId"],
      parentColumns: ["id", "tagText"],
      entity: TagTable)
  final int tagId;

  MemoTagTable({int id, int memoId, int tagId})
      : id = id,
        memoId = memoId,
        tagId = tagId;

  Map<String, dynamic> toMap() => {"memoId": this.memoId, "tagId": this.tagId};

  factory MemoTagTable.fromJson(Map<String, dynamic> json) => new MemoTagTable(
        id: json["id"],
        memoId: json["memoId"],
        tagId: json["tagId"],
      );
}

@dao
abstract class MemoTagDao {
  @Query('SELECT * FROM Memo_Tag')
  Future<List<MemoTagTable>> findAllMemoTag();

  @Query('DELETE FROM Memo_Tag WHERE Memo_Tag.memoId = :id')
  Future<void> deleteMemoTagByMemoId(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMemoTag(MemoTagTable memoTag);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMemoTags(List<MemoTagTable> memoTags);

  @delete
  Future<void> deleteMemoTag(MemoTagTable memoTag);

  @update
  Future<void> updateMemoTag(MemoTagTable memoTag);
}
