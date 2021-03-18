import 'dart:async';
import 'package:floor/floor.dart';
import 'package:note/model/memo.dart';
import 'package:note/model/memo_tag.dart';
import 'package:note/model/tag.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [MemoTable, TagTable, MemoTagTable])
abstract class AppDatabase extends FloorDatabase {
  MemoTableDao get memoDao;
  TagTableDao get tagDao;
  MemoTagDao get memoTagDao;
}

// flutter packages pub run build_runner build
