// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MemoTableDao _memoDaoInstance;

  TagTableDao _tagDaoInstance;

  MemoTagDao _memoTagDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Memo` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `userEmail` TEXT, `userDisplayName` TEXT, `title` TEXT, `text` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Tag` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `tagText` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Memo_Tag` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `memoId` INTEGER, `tagId` INTEGER)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MemoTableDao get memoDao {
    return _memoDaoInstance ??= _$MemoTableDao(database, changeListener);
  }

  @override
  TagTableDao get tagDao {
    return _tagDaoInstance ??= _$TagTableDao(database, changeListener);
  }

  @override
  MemoTagDao get memoTagDao {
    return _memoTagDaoInstance ??= _$MemoTagDao(database, changeListener);
  }
}

class _$MemoTableDao extends MemoTableDao {
  _$MemoTableDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _memoTableInsertionAdapter = InsertionAdapter(
            database,
            'Memo',
            (MemoTable item) => <String, dynamic>{
                  'id': item.id,
                  'userEmail': item.userEmail,
                  'userDisplayName': item.userDisplayName,
                  'title': item.title,
                  'text': item.text
                }),
        _memoTableUpdateAdapter = UpdateAdapter(
            database,
            'Memo',
            ['id'],
            (MemoTable item) => <String, dynamic>{
                  'id': item.id,
                  'userEmail': item.userEmail,
                  'userDisplayName': item.userDisplayName,
                  'title': item.title,
                  'text': item.text
                }),
        _memoTableDeletionAdapter = DeletionAdapter(
            database,
            'Memo',
            ['id'],
            (MemoTable item) => <String, dynamic>{
                  'id': item.id,
                  'userEmail': item.userEmail,
                  'userDisplayName': item.userDisplayName,
                  'title': item.title,
                  'text': item.text
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MemoTable> _memoTableInsertionAdapter;

  final UpdateAdapter<MemoTable> _memoTableUpdateAdapter;

  final DeletionAdapter<MemoTable> _memoTableDeletionAdapter;

  @override
  Future<List<MemoTable>> findAllMemo() async {
    return _queryAdapter.queryList('SELECT * FROM Memo',
        mapper: (Map<String, dynamic> row) => MemoTable(
            id: row['id'] as int,
            userEmail: row['userEmail'] as String,
            userDisplayName: row['userDisplayName'] as String,
            title: row['title'] as String,
            text: row['text'] as String));
  }

  @override
  Future<List<MemoTable>> findAllMemoByTag(String tag) async {
    return _queryAdapter.queryList(
        'SELECT id, userEmail, userDisplayName, title, text FROM Memo AS MemoTable INNER JOIN (SELECT memoId FROM Memo_Tag WHERE Memo_Tag.tagId = (SELECT id FROM Tag WHERE Tag.tagText = ?)) AS TagTable WHERE MemoTable.id = TagTable.memoId',
        arguments: <dynamic>[tag],
        mapper: (Map<String, dynamic> row) => MemoTable(
            id: row['id'] as int,
            userEmail: row['userEmail'] as String,
            userDisplayName: row['userDisplayName'] as String,
            title: row['title'] as String,
            text: row['text'] as String));
  }

  @override
  Future<MemoTable> findLastMemoId() async {
    return _queryAdapter.query(
        'SELECT id FROM Memo WHERE Memo.id = (SELECT Max(id) FROM Memo)',
        mapper: (Map<String, dynamic> row) => MemoTable(
            id: row['id'] as int,
            userEmail: row['userEmail'] as String,
            userDisplayName: row['userDisplayName'] as String,
            title: row['title'] as String,
            text: row['text'] as String));
  }

  @override
  Future<void> deleteMemoById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Memo WHERE Memo.id = ?',
        arguments: <dynamic>[id]);
  }

  @override
  Future<void> insertMemo(MemoTable memo) async {
    await _memoTableInsertionAdapter.insert(memo, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertMemos(List<MemoTable> memos) async {
    await _memoTableInsertionAdapter.insertList(
        memos, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMemo(MemoTable memo) async {
    await _memoTableUpdateAdapter.update(memo, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMemo(MemoTable memo) async {
    await _memoTableDeletionAdapter.delete(memo);
  }
}

class _$TagTableDao extends TagTableDao {
  _$TagTableDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _tagTableInsertionAdapter = InsertionAdapter(
            database,
            'Tag',
            (TagTable item) =>
                <String, dynamic>{'id': item.id, 'tagText': item.tagText}),
        _tagTableUpdateAdapter = UpdateAdapter(
            database,
            'Tag',
            ['id'],
            (TagTable item) =>
                <String, dynamic>{'id': item.id, 'tagText': item.tagText}),
        _tagTableDeletionAdapter = DeletionAdapter(
            database,
            'Tag',
            ['id'],
            (TagTable item) =>
                <String, dynamic>{'id': item.id, 'tagText': item.tagText});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TagTable> _tagTableInsertionAdapter;

  final UpdateAdapter<TagTable> _tagTableUpdateAdapter;

  final DeletionAdapter<TagTable> _tagTableDeletionAdapter;

  @override
  Future<List<TagTable>> findAllTag() async {
    return _queryAdapter.queryList('SELECT * FROM Tag',
        mapper: (Map<String, dynamic> row) =>
            TagTable(id: row['id'] as int, tagText: row['tagText'] as String));
  }

  @override
  Future<List<TagTable>> findAllTagByMemoId(int id) async {
    return _queryAdapter.queryList(
        'SELECT id, tagText FROM Tag AS TagTable INNER JOIN (SELECT tagId FROM Memo_Tag INNER JOIN Memo WHERE Memo_Tag.memoId = ? GROUP BY Memo_Tag.tagId) AS TagIdTable ON TagTable.id = TagIdTable.tagId',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) =>
            TagTable(id: row['id'] as int, tagText: row['tagText'] as String));
  }

  @override
  Future<TagTable> findTagByTagText(String tag) async {
    return _queryAdapter.query('SELECT * FROM Tag WHERE Tag.tagText = ?',
        arguments: <dynamic>[tag],
        mapper: (Map<String, dynamic> row) =>
            TagTable(id: row['id'] as int, tagText: row['tagText'] as String));
  }

  @override
  Future<TagTable> findLastTagId() async {
    return _queryAdapter.query(
        'SELECT id FROM Tag WHERE Tag.id = (SELECT Max(id) FROM Tag)',
        mapper: (Map<String, dynamic> row) =>
            TagTable(id: row['id'] as int, tagText: row['tagText'] as String));
  }

  @override
  Future<void> insertTag(TagTable tag) async {
    await _tagTableInsertionAdapter.insert(tag, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertTags(List<TagTable> tags) async {
    await _tagTableInsertionAdapter.insertList(
        tags, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateTag(TagTable tag) async {
    await _tagTableUpdateAdapter.update(tag, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTag(TagTable tag) async {
    await _tagTableDeletionAdapter.delete(tag);
  }
}

class _$MemoTagDao extends MemoTagDao {
  _$MemoTagDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _memoTagTableInsertionAdapter = InsertionAdapter(
            database,
            'Memo_Tag',
            (MemoTagTable item) => <String, dynamic>{
                  'id': item.id,
                  'memoId': item.memoId,
                  'tagId': item.tagId
                }),
        _memoTagTableUpdateAdapter = UpdateAdapter(
            database,
            'Memo_Tag',
            ['id'],
            (MemoTagTable item) => <String, dynamic>{
                  'id': item.id,
                  'memoId': item.memoId,
                  'tagId': item.tagId
                }),
        _memoTagTableDeletionAdapter = DeletionAdapter(
            database,
            'Memo_Tag',
            ['id'],
            (MemoTagTable item) => <String, dynamic>{
                  'id': item.id,
                  'memoId': item.memoId,
                  'tagId': item.tagId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MemoTagTable> _memoTagTableInsertionAdapter;

  final UpdateAdapter<MemoTagTable> _memoTagTableUpdateAdapter;

  final DeletionAdapter<MemoTagTable> _memoTagTableDeletionAdapter;

  @override
  Future<List<MemoTagTable>> findAllMemoTag() async {
    return _queryAdapter.queryList('SELECT * FROM Memo_Tag',
        mapper: (Map<String, dynamic> row) => MemoTagTable(
            id: row['id'] as int,
            memoId: row['memoId'] as int,
            tagId: row['tagId'] as int));
  }

  @override
  Future<List<MemoTagTable>> findAllMemoTagByMemoId(int id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Memo_Tag WHERE Memo_Tag.memoId = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => MemoTagTable(
            id: row['id'] as int,
            memoId: row['memoId'] as int,
            tagId: row['tagId'] as int));
  }

  @override
  Future<MemoTagTable> findMemoTagByMemoIdAndTagid(
      int memoId, int tagId) async {
    return _queryAdapter.query(
        'SELECT * FROM Memo_Tag WHERE Memo_Tag.memoId = ? AND Memo_Tag.tagId = ?',
        arguments: <dynamic>[memoId, tagId],
        mapper: (Map<String, dynamic> row) => MemoTagTable(
            id: row['id'] as int,
            memoId: row['memoId'] as int,
            tagId: row['tagId'] as int));
  }

  @override
  Future<MemoTagTable> findLastMemoTagId() async {
    return _queryAdapter.query(
        'SELECT id FROM Memo_Tag WHERE Memo_Tag.id = (SELECT Max(id) FROM Memo_Tag)',
        mapper: (Map<String, dynamic> row) => MemoTagTable(
            id: row['id'] as int,
            memoId: row['memoId'] as int,
            tagId: row['tagId'] as int));
  }

  @override
  Future<void> insertMemoTag(MemoTagTable memoTag) async {
    await _memoTagTableInsertionAdapter.insert(
        memoTag, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertMemoTags(List<MemoTagTable> memoTags) async {
    await _memoTagTableInsertionAdapter.insertList(
        memoTags, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMemoTag(MemoTagTable memoTag) async {
    await _memoTagTableUpdateAdapter.update(memoTag, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMemoTag(MemoTagTable memoTag) async {
    await _memoTagTableDeletionAdapter.delete(memoTag);
  }
}
