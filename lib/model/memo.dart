import 'dart:convert';

import 'package:floor/floor.dart';

import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

/// HTTP GET REQUEST
Future<List<MemoTable>> fetchMemo(http.Client client) async {
  final response = await client.get('http://192.168.1.55:3000/memo');

  // Spawn an isolate to parse JSON data on background
  // https://flutter.dev/docs/cookbook/networking/background-parsing
  return compute(parseMemo, response.body);
}

List<MemoTable> parseMemo(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<MemoTable>((json) => MemoTable.fromJson(json)).toList();
}

/// HTTP POST REQUEST
/// Body Request: (Memo)
/// userEmail - Google user email
/// userDisplayName - Google user name credentials (Name Surname)
Future<http.Response> createMemo(GoogleSignInAccount user) {
  return http.post(
    'http://192.168.1.55:3000/memo',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'userEmail': user.email,
      'userDisplayName': user.displayName,
    }),
  );
}

/// HTTP DELETE REQUEST
/// Delete a memo by its id
Future<http.Response> deleteMemo(int id) {
  return http.delete(
    'http://192.168.1.55:3000/memo/$id',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

/// HTTP PUT REQUEST
/// /// Body Request: (Memo)
/// userEmail - Google user email
/// userDisplayName - Google user name credentials (Name Surname)
/// title - Title of the memo
/// text - Body text of the memo
Future<http.Response> updateMemo(MemoTable memo, String title, String text) {
  int id = memo.id;
  return http.put(
    'http://192.168.1.55:3000/memo/$id',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'userEmail': memo.userEmail,
      'userDisplayName': memo.userDisplayName,
      'title': title,
      'text': text
    }),
  );
}

@Entity(tableName: 'Memo')
class MemoTable {
  @PrimaryKey(autoGenerate: true)
  final int id;
  String userEmail;
  String userDisplayName;
  String title;
  String text;

  MemoTable(
      {int id,
      String userEmail,
      String userDisplayName,
      String title,
      String text})
      : id = id,
        userEmail = userEmail,
        userDisplayName = userDisplayName,
        title = title,
        text = text;

  Map<String, dynamic> toMap() => {
        "userEmail": this.userEmail,
        "userDisplayName": this.userDisplayName,
        "title": this.title,
        "text": this.text,
      };

  factory MemoTable.fromJson(Map<String, dynamic> json) => new MemoTable(
        id: json["id"],
        userEmail: json["userEmail"],
        userDisplayName: json["userDisplayName"],
        title: json["title"],
        text: json["text"],
      );
}

@dao
abstract class MemoTableDao {
  @Query('SELECT * FROM Memo')
  Future<List<MemoTable>> findAllMemo();

  @Query(
      'SELECT id, userEmail, userDisplayName, title, text FROM Memo AS MemoTable LEFT JOIN (SELECT Memo_Tag.memoId FROM Memo_Tag INNER JOIN Tag WHERE Tag.tagText = :tag GROUP BY Memo_Tag.memoId) AS TagTable ON TagTable.memoId = MemoTable.id')
  Future<List<MemoTable>> findAllMemoByTag(String tag);

  @Query('SELECT id FROM Memo WHERE Memo.id = (SELECT Max(id) FROM Memo)')
  Future<MemoTable> findLastMemoId();

  @Query('DELETE FROM Memo WHERE Memo.id = :id')
  Future<void> deleteMemoById(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMemo(MemoTable memo);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMemos(List<MemoTable> memos);

  @delete
  Future<void> deleteMemo(MemoTable memo);

  @update
  Future<void> updateMemo(MemoTable memo);
}
