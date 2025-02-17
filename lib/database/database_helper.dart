import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'poetica.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        profile_picture TEXT,
        bio TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Poems table
    await db.execute('''
      CREATE TABLE poems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id INTEGER NOT NULL,
        genre TEXT,
        cover_image TEXT,
        is_public INTEGER DEFAULT 1,
        is_draft INTEGER DEFAULT 0,
        views INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Comments table
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        poem_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        parent_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (poem_id) REFERENCES poems (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES comments (id) ON DELETE CASCADE
      )
    ''');

    // Likes table
    await db.execute('''
      CREATE TABLE poem_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        poem_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (poem_id) REFERENCES poems (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(poem_id, user_id)
      )
    ''');

    // Saved poems table
    await db.execute('''
      CREATE TABLE saved_poems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        poem_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (poem_id) REFERENCES poems (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(poem_id, user_id)
      )
    ''');

    // Followers table
    await db.execute('''
      CREATE TABLE followers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        follower_id INTEGER NOT NULL,
        followed_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (follower_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (followed_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(follower_id, followed_id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        target_user_id INTEGER NOT NULL,
        target_id INTEGER,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (target_user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_poems_author ON poems(author_id)');
    await db.execute('CREATE INDEX idx_comments_poem ON comments(poem_id)');
    await db.execute('CREATE INDEX idx_likes_poem ON poem_likes(poem_id)');
    await db.execute('CREATE INDEX idx_saves_poem ON saved_poems(poem_id)');
    await db.execute('CREATE INDEX idx_followers ON followers(followed_id)');
    await db.execute(
        'CREATE INDEX idx_notifications_target ON notifications(target_user_id)');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // User Methods
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('users');
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user);
  }

  Future<void> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Poem Methods
  Future<List<Map<String, dynamic>>> getForYouPoems(int userId,
      {int limit = 10, int offset = 0}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        p.*,
        u.username as author_name,
        u.profile_picture as author_image,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id) as likes_count,
        (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comments_count,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id AND user_id = ?) as is_liked,
        (SELECT COUNT(*) FROM saved_poems WHERE poem_id = p.id AND user_id = ?) as is_saved
      FROM poems p
      INNER JOIN users u ON p.author_id = u.id
      WHERE p.is_public = 1 AND p.is_draft = 0
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    ''', [userId, userId, limit, offset]);
  }

  Future<Map<String, dynamic>?> getPoem(int id) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        p.*,
        u.username as author_name,
        u.profile_picture as author_image,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id) as likes_count,
        (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comments_count
      FROM poems p
      INNER JOIN users u ON p.author_id = u.id
      WHERE p.id = ?
    ''', [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> createPoem(Map<String, dynamic> poem) async {
    final db = await database;
    return db.insert('poems', poem);
  }

  Future<void> updatePoem(int id, Map<String, dynamic> poem) async {
    final db = await database;
    await db.update(
      'poems',
      poem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePoem(int id) async {
    final db = await database;
    await db.delete(
      'poems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Comment Methods
  Future<List<Map<String, dynamic>>> getPoemComments(int poemId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        c.*,
        u.username,
        u.profile_picture as user_image
      FROM comments c
      INNER JOIN users u ON c.user_id = u.id
      WHERE c.poem_id = ?
      ORDER BY c.created_at DESC
    ''', [poemId]);
  }

  Future<int> createComment(Map<String, dynamic> comment) async {
    final db = await database;
    return db.insert('comments', comment);
  }

  // Like Methods
  Future<void> toggleLike(int poemId, int userId) async {
    final db = await database;
    await db.transaction((txn) async {
      final likes = await txn.query(
        'poem_likes',
        where: 'poem_id = ? AND user_id = ?',
        whereArgs: [poemId, userId],
      );

      if (likes.isEmpty) {
        await txn.insert('poem_likes', {
          'poem_id': poemId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Create notification for the poem author
        final poem = await txn.query(
          'poems',
          columns: ['author_id'],
          where: 'id = ?',
          whereArgs: [poemId],
        );

        if (poem.isNotEmpty && poem.first['author_id'] != userId) {
          await txn.insert('notifications', {
            'type': 'like',
            'user_id': userId,
            'target_user_id': poem.first['author_id'],
            'target_id': poemId,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } else {
        await txn.delete(
          'poem_likes',
          where: 'poem_id = ? AND user_id = ?',
          whereArgs: [poemId, userId],
        );
      }
    });
  }

  // Save Methods
  Future<void> toggleSave(int poemId, int userId) async {
    final db = await database;
    await db.transaction((txn) async {
      final saves = await txn.query(
        'saved_poems',
        where: 'poem_id = ? AND user_id = ?',
        whereArgs: [poemId, userId],
      );

      if (saves.isEmpty) {
        await txn.insert('saved_poems', {
          'poem_id': poemId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await txn.delete(
          'saved_poems',
          where: 'poem_id = ? AND user_id = ?',
          whereArgs: [poemId, userId],
        );
      }
    });
  }

  // Follow Methods
  Future<void> toggleFollow(int followerId, int followedId) async {
    final db = await database;
    await db.transaction((txn) async {
      final following = await txn.query(
        'followers',
        where: 'follower_id = ? AND followed_id = ?',
        whereArgs: [followerId, followedId],
      );

      if (following.isEmpty) {
        await txn.insert('followers', {
          'follower_id': followerId,
          'followed_id': followedId,
          'created_at': DateTime.now().toIso8601String(),
        });

        await txn.insert('notifications', {
          'type': 'follow',
          'user_id': followerId,
          'target_user_id': followedId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await txn.delete(
          'followers',
          where: 'follower_id = ? AND followed_id = ?',
          whereArgs: [followerId, followedId],
        );
      }
    });
  }

  // Notification Methods
  Future<List<Map<String, dynamic>>> getNotifications(int userId,
      {int limit = 20, int offset = 0}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        n.*,
        u.username,
        u.profile_picture as user_image,
        p.title as target_title
      FROM notifications n
      INNER JOIN users u ON n.user_id = u.id
      LEFT JOIN poems p ON n.target_id = p.id
      WHERE n.target_user_id = ?
      ORDER BY n.created_at DESC
      LIMIT ? OFFSET ?
    ''', [userId, limit, offset]);
  }

  Future<int> getUnreadNotificationsCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM notifications
      WHERE target_user_id = ? AND is_read = 0
    ''', [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markNotificationsAsRead(int userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'target_user_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
  }

  // Search Methods
  Future<List<Map<String, dynamic>>> searchPoems(
      String query, int currentUserId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        p.*,
        u.username as author_name,
        u.profile_picture as author_image,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id) as likes_count,
        (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comments_count,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id AND user_id = ?) as is_liked,
        (SELECT COUNT(*) FROM saved_poems WHERE poem_id = p.id AND user_id = ?) as is_saved
      FROM poems p
      INNER JOIN users u ON p.author_id = u.id
      WHERE p.is_public = 1 AND p.is_draft = 0
        AND (p.title LIKE ? OR p.content LIKE ?)
      ORDER BY p.created_at DESC
    ''', [currentUserId, currentUserId, '%$query%', '%$query%']);
  }

  Future<List<Map<String, dynamic>>> searchUsers(
      String query, int currentUserId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        u.*,
        (SELECT COUNT(*) FROM followers WHERE followed_id = u.id) as followers_count,
        (SELECT COUNT(*) FROM followers WHERE follower_id = u.id) as following_count,
        (SELECT COUNT(*) FROM followers 
         WHERE follower_id = ? AND followed_id = u.id) as is_following
      FROM users u
      WHERE u.username LIKE ?
      ORDER BY u.username ASC
    ''', [currentUserId, '%$query%']);
  }

  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> registerUser(
      String username, String password, String email) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'email': email,
      'password_hash': password,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isLikedByUser(int poemId, int userId) async {
    final db = await database;
    final results = await db.query(
      'poem_likes',
      where: 'poem_id = ? AND user_id = ?',
      whereArgs: [poemId, userId],
    );
    return results.isNotEmpty;
  }

  Future<bool> isSavedByUser(int poemId, int userId) async {
    final db = await database;
    final results = await db.query(
      'saved_poems',
      where: 'poem_id = ? AND user_id = ?',
      whereArgs: [poemId, userId],
    );
    return results.isNotEmpty;
  }

  Future<void> addComment(int poemId, int userId, String content) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('comments', {
        'poem_id': poemId,
        'user_id': userId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });

      final poem = await txn.query(
        'poems',
        columns: ['author_id'],
        where: 'id = ?',
        whereArgs: [poemId],
      );

      if (poem.isNotEmpty && poem.first['author_id'] != userId) {
        await txn.insert('notifications', {
          'type': 'comment',
          'user_id': userId,
          'target_user_id': poem.first['author_id'],
          'target_id': poemId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getFollowingPoems(int userId,
      {int limit = 10, int offset = 0}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        p.*,
        u.username as author_name,
        u.profile_picture as author_image,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id) as likes_count,
        (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comments_count,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id AND user_id = ?) as is_liked,
        (SELECT COUNT(*) FROM saved_poems WHERE poem_id = p.id AND user_id = ?) as is_saved
      FROM poems p
      INNER JOIN users u ON p.author_id = u.id
      INNER JOIN followers f ON p.author_id = f.followed_id
      WHERE f.follower_id = ? AND p.is_public = 1 AND p.is_draft = 0
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    ''', [userId, userId, userId, limit, offset]);
  }
}
